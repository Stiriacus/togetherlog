-- Add layout_variant column to entries table
-- Used for visual variation seed (rotation, stagger positioning in flipbook)

ALTER TABLE public.entries
ADD COLUMN IF NOT EXISTS layout_variant INTEGER DEFAULT 0 NOT NULL;

COMMENT ON COLUMN public.entries.layout_variant IS 'Visual variation seed for frontend layout randomization (rotation, stagger). Incremented when user regenerates layout.';
