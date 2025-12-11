-- TogetherLog - Helper Views and Functions
-- Migration: 002_helper_views_and_functions
-- Description: Utility views and functions for easier data access

-- ============================================================================
-- VIEWS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- View: entries_with_tags
-- Purpose: Get entries with their associated tags in one query
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.entries_with_tags AS
SELECT
    e.id,
    e.log_id,
    e.created_at,
    e.updated_at,
    e.event_date,
    e.highlight_text,
    e.location_lat,
    e.location_lng,
    e.location_display_name,
    e.location_is_user_overridden,
    e.page_layout_type,
    e.color_theme,
    e.sprinkles,
    e.is_processed,
    COALESCE(
        json_agg(
            json_build_object(
                'id', t.id,
                'name', t.name,
                'category', t.category,
                'icon', t.icon
            )
        ) FILTER (WHERE t.id IS NOT NULL),
        '[]'::json
    ) AS tags
FROM public.entries e
LEFT JOIN public.entry_tags et ON et.entry_id = e.id
LEFT JOIN public.tags t ON t.id = et.tag_id
GROUP BY e.id;

-- ----------------------------------------------------------------------------
-- View: entries_with_photos_and_tags
-- Purpose: Complete entry view with photos and tags
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.entries_with_photos_and_tags AS
SELECT
    e.id,
    e.log_id,
    e.created_at,
    e.updated_at,
    e.event_date,
    e.highlight_text,
    e.location_lat,
    e.location_lng,
    e.location_display_name,
    e.location_is_user_overridden,
    e.page_layout_type,
    e.color_theme,
    e.sprinkles,
    e.is_processed,
    COALESCE(
        json_agg(
            DISTINCT jsonb_build_object(
                'id', p.id,
                'url', p.url,
                'thumbnail_url', p.thumbnail_url,
                'display_order', p.display_order,
                'width', p.width,
                'height', p.height,
                'dominant_colors', p.dominant_colors
            )
        ) FILTER (WHERE p.id IS NOT NULL) ORDER BY p.display_order,
        '[]'::json
    ) AS photos,
    COALESCE(
        json_agg(
            DISTINCT jsonb_build_object(
                'id', t.id,
                'name', t.name,
                'category', t.category,
                'icon', t.icon
            )
        ) FILTER (WHERE t.id IS NOT NULL),
        '[]'::json
    ) AS tags
FROM public.entries e
LEFT JOIN public.photos p ON p.entry_id = e.id
LEFT JOIN public.entry_tags et ON et.entry_id = e.id
LEFT JOIN public.tags t ON t.id = et.tag_id
GROUP BY e.id;

-- ----------------------------------------------------------------------------
-- View: logs_with_entry_count
-- Purpose: Get logs with count of entries
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.logs_with_entry_count AS
SELECT
    l.id,
    l.user_id,
    l.name,
    l.type,
    l.created_at,
    l.updated_at,
    COUNT(e.id) AS entry_count,
    MAX(e.event_date) AS latest_event_date
FROM public.logs l
LEFT JOIN public.entries e ON e.log_id = l.id
GROUP BY l.id;

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Function: get_log_entries
-- Purpose: Get all entries for a log with full data (photos, tags)
-- Usage: SELECT * FROM get_log_entries('<log-uuid>')
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_log_entries(log_uuid UUID)
RETURNS TABLE (
    id UUID,
    log_id UUID,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE,
    event_date TIMESTAMP WITH TIME ZONE,
    highlight_text TEXT,
    location_lat DOUBLE PRECISION,
    location_lng DOUBLE PRECISION,
    location_display_name TEXT,
    location_is_user_overridden BOOLEAN,
    page_layout_type TEXT,
    color_theme TEXT,
    sprinkles JSONB,
    is_processed BOOLEAN,
    photos JSON,
    tags JSON
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.id,
        e.log_id,
        e.created_at,
        e.updated_at,
        e.event_date,
        e.highlight_text,
        e.location_lat,
        e.location_lng,
        e.location_display_name,
        e.location_is_user_overridden,
        e.page_layout_type,
        e.color_theme,
        e.sprinkles,
        e.is_processed,
        ewpt.photos,
        ewpt.tags
    FROM public.entries e
    JOIN public.entries_with_photos_and_tags ewpt ON ewpt.id = e.id
    WHERE e.log_id = log_uuid
    ORDER BY e.event_date ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ----------------------------------------------------------------------------
-- Function: get_unprocessed_entries
-- Purpose: Get entries that need processing (for worker functions)
-- Usage: SELECT * FROM get_unprocessed_entries()
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_unprocessed_entries()
RETURNS TABLE (
    id UUID,
    log_id UUID,
    event_date TIMESTAMP WITH TIME ZONE,
    photo_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.id,
        e.log_id,
        e.event_date,
        COUNT(p.id) AS photo_count
    FROM public.entries e
    LEFT JOIN public.photos p ON p.entry_id = e.id
    WHERE e.is_processed = FALSE
    GROUP BY e.id
    ORDER BY e.created_at ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ----------------------------------------------------------------------------
-- Function: mark_entry_processed
-- Purpose: Mark an entry as processed
-- Usage: SELECT mark_entry_processed('<entry-uuid>')
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.mark_entry_processed(entry_uuid UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE public.entries
    SET is_processed = TRUE,
        updated_at = NOW()
    WHERE id = entry_uuid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ----------------------------------------------------------------------------
-- Function: get_tags_by_category
-- Purpose: Get tags grouped by category
-- Usage: SELECT * FROM get_tags_by_category()
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_tags_by_category()
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_object_agg(
            category,
            tags
        )
        FROM (
            SELECT
                t.category,
                json_agg(
                    json_build_object(
                        'id', t.id,
                        'name', t.name,
                        'icon', t.icon
                    )
                    ORDER BY t.name
                ) AS tags
            FROM public.tags t
            GROUP BY t.category
        ) grouped
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ----------------------------------------------------------------------------
-- Function: get_entry_tag_names
-- Purpose: Get array of tag names for an entry (useful for Smart Pages engine)
-- Usage: SELECT get_entry_tag_names('<entry-uuid>')
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_entry_tag_names(entry_uuid UUID)
RETURNS TEXT[] AS $$
BEGIN
    RETURN ARRAY(
        SELECT t.name
        FROM public.tags t
        JOIN public.entry_tags et ON et.tag_id = t.id
        WHERE et.entry_id = entry_uuid
        ORDER BY t.name
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ----------------------------------------------------------------------------
-- Function: search_entries
-- Purpose: Search entries by text, tags, or date range
-- Usage: SELECT * FROM search_entries(log_uuid, search_text, tag_ids, start_date, end_date)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.search_entries(
    log_uuid UUID DEFAULT NULL,
    search_text TEXT DEFAULT NULL,
    tag_ids UUID[] DEFAULT NULL,
    start_date TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    end_date TIMESTAMP WITH TIME ZONE DEFAULT NULL
)
RETURNS TABLE (
    id UUID,
    log_id UUID,
    event_date TIMESTAMP WITH TIME ZONE,
    highlight_text TEXT,
    location_display_name TEXT,
    page_layout_type TEXT,
    color_theme TEXT,
    photos JSON,
    tags JSON
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        ewpt.id,
        ewpt.log_id,
        ewpt.event_date,
        ewpt.highlight_text,
        ewpt.location_display_name,
        ewpt.page_layout_type,
        ewpt.color_theme,
        ewpt.photos,
        ewpt.tags
    FROM public.entries_with_photos_and_tags ewpt
    WHERE
        (log_uuid IS NULL OR ewpt.log_id = log_uuid)
        AND (search_text IS NULL OR ewpt.highlight_text ILIKE '%' || search_text || '%' OR ewpt.location_display_name ILIKE '%' || search_text || '%')
        AND (tag_ids IS NULL OR EXISTS (
            SELECT 1 FROM public.entry_tags et
            WHERE et.entry_id = ewpt.id
            AND et.tag_id = ANY(tag_ids)
        ))
        AND (start_date IS NULL OR ewpt.event_date >= start_date)
        AND (end_date IS NULL OR ewpt.event_date <= end_date)
    ORDER BY ewpt.event_date DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- INDEXES FOR VIEWS (MATERIALIZED VIEWS - Future Optimization)
-- ============================================================================

-- Note: For V1, we use regular views. In the future, if performance becomes
-- an issue, we can convert critical views to materialized views with refresh strategies.

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON VIEW public.entries_with_tags IS 'Entries with their associated tags (denormalized for easier querying)';
COMMENT ON VIEW public.entries_with_photos_and_tags IS 'Complete entry view with photos and tags (used by frontend)';
COMMENT ON VIEW public.logs_with_entry_count IS 'Logs with entry count and latest event date';

COMMENT ON FUNCTION public.get_log_entries IS 'Get all entries for a specific log with full data';
COMMENT ON FUNCTION public.get_unprocessed_entries IS 'Get entries that need background processing';
COMMENT ON FUNCTION public.mark_entry_processed IS 'Mark an entry as processed by workers';
COMMENT ON FUNCTION public.get_tags_by_category IS 'Get tags grouped by category (activity, event, emotion)';
COMMENT ON FUNCTION public.get_entry_tag_names IS 'Get tag names for an entry (used by Smart Pages engine)';
COMMENT ON FUNCTION public.search_entries IS 'Search entries by text, tags, or date range';
