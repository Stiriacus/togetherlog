-- Update entries_with_photos_and_tags view to include layout_variant column
-- This is needed for the regenerate layout feature

DROP VIEW IF EXISTS public.entries_with_photos_and_tags;

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
    e.layout_variant,  -- Added for regenerate layout feature

    -- Attach Photos (aggregated in subquery to prevent duplicates)
    COALESCE(p_agg.photos_json, '[]'::json) AS photos,

    -- Attach Tags (aggregated in subquery to prevent duplicates)
    COALESCE(t_agg.tags_json, '[]'::json) AS tags

FROM public.entries e

-- Join Photos Subquery
LEFT JOIN (
    SELECT
        entry_id,
        json_agg(
            jsonb_build_object(
                'id', id,
                'entry_id', entry_id,
                'url', url,
                'thumbnail_url', thumbnail_url,
                'display_order', display_order,
                'width', width,
                'height', height,
                'dominant_colors', dominant_colors
            ) ORDER BY display_order ASC
        ) AS photos_json
    FROM public.photos
    GROUP BY entry_id
) p_agg ON p_agg.entry_id = e.id

-- Join Tags Subquery
LEFT JOIN (
    SELECT
        et.entry_id,
        json_agg(
            jsonb_build_object(
                'id', t.id,
                'name', t.name,
                'category', t.category,
                'icon', t.icon
            ) ORDER BY t.name ASC
        ) AS tags_json
    FROM public.entry_tags et
    JOIN public.tags t ON t.id = et.tag_id
    GROUP BY et.entry_id
) t_agg ON t_agg.entry_id = e.id;

COMMENT ON VIEW public.entries_with_photos_and_tags IS 'Complete entry view with photos and tags (used by frontend) - includes layout_variant';
