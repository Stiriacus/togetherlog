-- TogetherLog - Initial Database Schema (V1)
-- Migration: 001_initial_schema
-- Description: Core tables for logs, entries, photos, and tags with RLS policies

-- ============================================================================
-- EXTENSIONS
-- ============================================================================

-- Note: gen_random_uuid() is built into PostgreSQL 13+, no extension needed
-- Enable pgcrypto for additional crypto functions (if needed in future)
-- CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- TABLES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- LOGS (Memory Books)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    type TEXT NOT NULL DEFAULT 'Couple', -- Couple, Friends, Family
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    CONSTRAINT logs_name_length CHECK (char_length(name) >= 1 AND char_length(name) <= 100),
    CONSTRAINT logs_type_valid CHECK (type IN ('Couple', 'Friends', 'Family', 'Solo', 'Other'))
);

-- Index for user_id lookups
CREATE INDEX IF NOT EXISTS idx_logs_user_id ON public.logs(user_id);
CREATE INDEX IF NOT EXISTS idx_logs_created_at ON public.logs(created_at DESC);

-- ----------------------------------------------------------------------------
-- TAGS (Predefined Categories)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    category TEXT NOT NULL, -- activity, event, emotion
    icon TEXT, -- Icon identifier for future use
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    CONSTRAINT tags_name_length CHECK (char_length(name) >= 1 AND char_length(name) <= 50)
);

-- Index for tag lookups
CREATE INDEX IF NOT EXISTS idx_tags_category ON public.tags(category);

-- ----------------------------------------------------------------------------
-- ENTRIES (Individual Memories)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    log_id UUID NOT NULL REFERENCES public.logs(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    event_date TIMESTAMP WITH TIME ZONE NOT NULL,
    highlight_text TEXT NOT NULL DEFAULT '',

    -- Location data
    location_lat DOUBLE PRECISION,
    location_lng DOUBLE PRECISION,
    location_display_name TEXT,
    location_is_user_overridden BOOLEAN DEFAULT FALSE,

    -- Smart Page outputs (computed by backend)
    page_layout_type TEXT DEFAULT 'single_full',
    color_theme TEXT DEFAULT 'neutral',
    sprinkles JSONB DEFAULT '[]'::jsonb,

    -- Processing status
    is_processed BOOLEAN DEFAULT FALSE,

    CONSTRAINT entries_highlight_text_length CHECK (char_length(highlight_text) >= 0 AND char_length(highlight_text) <= 500),
    CONSTRAINT entries_location_valid CHECK (
        (location_lat IS NULL AND location_lng IS NULL) OR
        (location_lat IS NOT NULL AND location_lng IS NOT NULL AND
         location_lat >= -90 AND location_lat <= 90 AND
         location_lng >= -180 AND location_lng <= 180)
    )
);

-- Indexes for entries
CREATE INDEX IF NOT EXISTS idx_entries_log_id ON public.entries(log_id);
CREATE INDEX IF NOT EXISTS idx_entries_event_date ON public.entries(event_date DESC);
CREATE INDEX IF NOT EXISTS idx_entries_created_at ON public.entries(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_entries_is_processed ON public.entries(is_processed) WHERE is_processed = FALSE;

-- ----------------------------------------------------------------------------
-- PHOTOS
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.photos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entry_id UUID NOT NULL REFERENCES public.entries(id) ON DELETE CASCADE,

    -- Storage paths (Supabase Storage)
    storage_path TEXT NOT NULL,
    thumbnail_path TEXT,

    -- URLs (generated)
    url TEXT,
    thumbnail_url TEXT,

    -- EXIF and metadata
    exif_data JSONB DEFAULT '{}'::jsonb,
    dominant_colors JSONB DEFAULT '[]'::jsonb,
    width INTEGER,
    height INTEGER,
    file_size BIGINT,
    mime_type TEXT,

    -- Ordering within entry
    display_order INTEGER DEFAULT 0,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    CONSTRAINT photos_display_order_positive CHECK (display_order >= 0)
);

-- Indexes for photos
CREATE INDEX IF NOT EXISTS idx_photos_entry_id ON public.photos(entry_id);
CREATE INDEX IF NOT EXISTS idx_photos_display_order ON public.photos(entry_id, display_order);

-- ----------------------------------------------------------------------------
-- ENTRY_TAGS (Many-to-Many Relationship)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.entry_tags (
    entry_id UUID NOT NULL REFERENCES public.entries(id) ON DELETE CASCADE,
    tag_id UUID NOT NULL REFERENCES public.tags(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    PRIMARY KEY (entry_id, tag_id)
);

-- Indexes for entry_tags
CREATE INDEX IF NOT EXISTS idx_entry_tags_entry_id ON public.entry_tags(entry_id);
CREATE INDEX IF NOT EXISTS idx_entry_tags_tag_id ON public.entry_tags(tag_id);

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Update updated_at timestamp automatically
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach trigger to logs
CREATE TRIGGER update_logs_updated_at
    BEFORE UPDATE ON public.logs
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- Attach trigger to entries
CREATE TRIGGER update_entries_updated_at
    BEFORE UPDATE ON public.entries
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- Attach trigger to photos
CREATE TRIGGER update_photos_updated_at
    BEFORE UPDATE ON public.photos
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE public.logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.entry_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tags ENABLE ROW LEVEL SECURITY;

-- ----------------------------------------------------------------------------
-- LOGS Policies
-- ----------------------------------------------------------------------------

-- Users can view their own logs
CREATE POLICY "Users can view own logs"
    ON public.logs FOR SELECT
    USING (auth.uid() = user_id);

-- Users can insert their own logs
CREATE POLICY "Users can insert own logs"
    ON public.logs FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Users can update their own logs
CREATE POLICY "Users can update own logs"
    ON public.logs FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Users can delete their own logs
CREATE POLICY "Users can delete own logs"
    ON public.logs FOR DELETE
    USING (auth.uid() = user_id);

-- ----------------------------------------------------------------------------
-- ENTRIES Policies
-- ----------------------------------------------------------------------------

-- Users can view entries in their own logs
CREATE POLICY "Users can view entries in own logs"
    ON public.entries FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.logs
            WHERE logs.id = entries.log_id
            AND logs.user_id = auth.uid()
        )
    );

-- Users can insert entries in their own logs
CREATE POLICY "Users can insert entries in own logs"
    ON public.entries FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.logs
            WHERE logs.id = entries.log_id
            AND logs.user_id = auth.uid()
        )
    );

-- Users can update entries in their own logs
CREATE POLICY "Users can update entries in own logs"
    ON public.entries FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.logs
            WHERE logs.id = entries.log_id
            AND logs.user_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.logs
            WHERE logs.id = entries.log_id
            AND logs.user_id = auth.uid()
        )
    );

-- Users can delete entries in their own logs
CREATE POLICY "Users can delete entries in own logs"
    ON public.entries FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.logs
            WHERE logs.id = entries.log_id
            AND logs.user_id = auth.uid()
        )
    );

-- ----------------------------------------------------------------------------
-- PHOTOS Policies
-- ----------------------------------------------------------------------------

-- Users can view photos in their own entries
CREATE POLICY "Users can view photos in own entries"
    ON public.photos FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.entries
            JOIN public.logs ON logs.id = entries.log_id
            WHERE entries.id = photos.entry_id
            AND logs.user_id = auth.uid()
        )
    );

-- Users can insert photos in their own entries
CREATE POLICY "Users can insert photos in own entries"
    ON public.photos FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.entries
            JOIN public.logs ON logs.id = entries.log_id
            WHERE entries.id = photos.entry_id
            AND logs.user_id = auth.uid()
        )
    );

-- Users can update photos in their own entries
CREATE POLICY "Users can update photos in own entries"
    ON public.photos FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.entries
            JOIN public.logs ON logs.id = entries.log_id
            WHERE entries.id = photos.entry_id
            AND logs.user_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.entries
            JOIN public.logs ON logs.id = entries.log_id
            WHERE entries.id = photos.entry_id
            AND logs.user_id = auth.uid()
        )
    );

-- Users can delete photos in their own entries
CREATE POLICY "Users can delete photos in own entries"
    ON public.photos FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.entries
            JOIN public.logs ON logs.id = entries.log_id
            WHERE entries.id = photos.entry_id
            AND logs.user_id = auth.uid()
        )
    );

-- ----------------------------------------------------------------------------
-- ENTRY_TAGS Policies
-- ----------------------------------------------------------------------------

-- Users can view entry_tags for their own entries
CREATE POLICY "Users can view entry_tags for own entries"
    ON public.entry_tags FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.entries
            JOIN public.logs ON logs.id = entries.log_id
            WHERE entries.id = entry_tags.entry_id
            AND logs.user_id = auth.uid()
        )
    );

-- Users can insert entry_tags for their own entries
CREATE POLICY "Users can insert entry_tags for own entries"
    ON public.entry_tags FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.entries
            JOIN public.logs ON logs.id = entries.log_id
            WHERE entries.id = entry_tags.entry_id
            AND logs.user_id = auth.uid()
        )
    );

-- Users can delete entry_tags for their own entries
CREATE POLICY "Users can delete entry_tags for own entries"
    ON public.entry_tags FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.entries
            JOIN public.logs ON logs.id = entries.log_id
            WHERE entries.id = entry_tags.entry_id
            AND logs.user_id = auth.uid()
        )
    );

-- ----------------------------------------------------------------------------
-- TAGS Policies (Read-only for all authenticated users)
-- ----------------------------------------------------------------------------

-- All authenticated users can view tags
CREATE POLICY "Authenticated users can view tags"
    ON public.tags FOR SELECT
    TO authenticated
    USING (true);

-- ============================================================================
-- SEED DATA - TAGS (from v1Spez.md)
-- ============================================================================

INSERT INTO public.tags (name, category, icon) VALUES
    -- Activity & Theme Tags
    ('Nature & Hiking', 'activity', 'mountain'),
    ('Lake / Beach', 'activity', 'beach'),
    ('City & Sightseeing', 'activity', 'city'),
    ('Food & Restaurant', 'activity', 'restaurant'),
    ('Home & Everyday Life', 'activity', 'home'),
    ('Adventure / Sports', 'activity', 'sports'),
    ('Nightlife', 'activity', 'nightlife'),
    ('Roadtrip', 'activity', 'car'),
    ('Romantic Moments', 'activity', 'heart'),

    -- Event Tags
    ('Anniversary', 'event', 'anniversary'),
    ('Birthday', 'event', 'birthday'),
    ('Holiday / Celebration', 'event', 'celebration'),
    ('Travel', 'event', 'travel'),
    ('Surprise / Gift', 'event', 'gift'),

    -- Emotion Tags
    ('Happy', 'emotion', 'happy'),
    ('Relaxed', 'emotion', 'relaxed'),
    ('Proud', 'emotion', 'proud'),
    ('In Love', 'emotion', 'love'),
    ('Silly / Fun', 'emotion', 'fun')
ON CONFLICT (name) DO NOTHING;

-- ============================================================================
-- STORAGE BUCKETS (Supabase Storage configuration)
-- ============================================================================

-- Note: Storage buckets are typically created via Supabase UI or CLI
-- These INSERT statements are for reference and may need to be run separately

-- Create photos bucket (if not exists)
INSERT INTO storage.buckets (id, name, public)
VALUES ('photos', 'photos', false)
ON CONFLICT (id) DO NOTHING;

-- Create thumbnails bucket (if not exists)
INSERT INTO storage.buckets (id, name, public)
VALUES ('thumbnails', 'thumbnails', false)
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- STORAGE POLICIES (RLS for Supabase Storage)
-- ============================================================================

-- Users can upload photos to their own logs
CREATE POLICY "Users can upload photos"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'photos' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

-- Users can view their own photos
CREATE POLICY "Users can view own photos"
    ON storage.objects FOR SELECT
    USING (
        bucket_id = 'photos' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

-- Users can delete their own photos
CREATE POLICY "Users can delete own photos"
    ON storage.objects FOR DELETE
    USING (
        bucket_id = 'photos' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

-- Similar policies for thumbnails
CREATE POLICY "Users can upload thumbnails"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'thumbnails' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can view own thumbnails"
    ON storage.objects FOR SELECT
    USING (
        bucket_id = 'thumbnails' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can delete own thumbnails"
    ON storage.objects FOR DELETE
    USING (
        bucket_id = 'thumbnails' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE public.logs IS 'Memory books - each user can have multiple logs';
COMMENT ON TABLE public.entries IS 'Individual memory entries within a log';
COMMENT ON TABLE public.photos IS 'Photos attached to entries with EXIF and metadata';
COMMENT ON TABLE public.tags IS 'Predefined categories for tagging entries';
COMMENT ON TABLE public.entry_tags IS 'Many-to-many relationship between entries and tags';

COMMENT ON COLUMN public.entries.page_layout_type IS 'Smart Page layout type (computed by backend)';
COMMENT ON COLUMN public.entries.color_theme IS 'Smart Page color theme (computed by Emotion-Color-Engine V1)';
COMMENT ON COLUMN public.entries.sprinkles IS 'Decorative icons/symbols (computed by backend)';
COMMENT ON COLUMN public.entries.is_processed IS 'Whether entry has been processed by workers (EXIF, Smart Pages, etc.)';
