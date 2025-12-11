// TogetherLog - Smart Pages Computation Worker
// Deterministic, rule-based Smart Page engine (V1)
// Computes: page_layout_type, color_theme, sprinkles

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

interface ComputeSmartPageRequest {
  entry_id: string
}

// Layout types based on photo count
type LayoutType = 'single_full' | 'grid_2x2' | 'grid_2x3' | 'grid_3x2' | 'collage_4'

// Color theme identifiers (Emotion-Color-Engine V1)
type ColorTheme = 'warm_red' | 'soft_rose' | 'earth_green' | 'ocean_blue' | 'deep_purple' | 'neutral' | 'warm_earth'

// Sprinkle icons
type SprinkleIcon = 'heart' | 'mountain' | 'tree' | 'beach' | 'wave' | 'sun' | 'star' | 'airplane' | 'camera' | 'utensils' | 'gift' | 'balloon'

serve(async (req: Request) => {
  try {
    const body: ComputeSmartPageRequest = await req.json()

    // Validate input
    if (!body.entry_id) {
      return new Response(
        JSON.stringify({ error: 'entry_id is required' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      )
    }

    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Fetch entry with photos and tags using the optimized view
    const { data: entry, error: entryError } = await supabase
      .from('entries_with_photos_and_tags')
      .select('*')
      .eq('id', body.entry_id)
      .single()

    if (entryError || !entry) {
      return new Response(
        JSON.stringify({ error: 'Entry not found' }),
        { status: 404, headers: { 'Content-Type': 'application/json' } }
      )
    }

    // Extract inputs for Smart Page logic
    const photoCount = entry.photos?.length || 0
    const tagNames = entry.tags?.map((t: any) => t.name) || []
    const highlightTextLength = entry.highlight_text?.length || 0
    const hasLocation = !!(entry.location_lat && entry.location_lng)

    // ============================================================================
    // RULE 1: Compute Layout Type (based on photo count)
    // ============================================================================
    const layoutType = computeLayoutType(photoCount)

    // ============================================================================
    // RULE 2: Compute Color Theme (Emotion-Color-Engine V1)
    // ============================================================================
    const colorTheme = computeColorTheme(tagNames, entry.photos)

    // ============================================================================
    // RULE 3: Compute Sprinkles (decorative icons based on tags)
    // ============================================================================
    const sprinkles = computeSprinkles(tagNames, hasLocation)

    // Update entry with Smart Page data
    const { error: updateError } = await supabase
      .from('entries')
      .update({
        page_layout_type: layoutType,
        color_theme: colorTheme,
        sprinkles: sprinkles,
        is_processed: true, // Mark as processed
        updated_at: new Date().toISOString(),
      })
      .eq('id', body.entry_id)

    if (updateError) {
      throw new Error(`Failed to update entry: ${updateError.message}`)
    }

    return new Response(
      JSON.stringify({
        success: true,
        entry_id: body.entry_id,
        smart_page: {
          page_layout_type: layoutType,
          color_theme: colorTheme,
          sprinkles: sprinkles,
        },
        inputs: {
          photo_count: photoCount,
          tag_count: tagNames.length,
          tags: tagNames,
          has_location: hasLocation,
          highlight_length: highlightTextLength,
        },
      }),
      { status: 200, headers: { 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Error computing Smart Page:', error)
    return new Response(
      JSON.stringify({ error: error.message || 'Internal server error' }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    )
  }
})

// ============================================================================
// Smart Page Rules Engine
// ============================================================================

/**
 * RULE 1: Layout Type Selection
 * Based on photo count (v1Spez.md section 6.4)
 */
function computeLayoutType(photoCount: number): LayoutType {
  if (photoCount === 0) {
    return 'single_full' // Text-only entry
  } else if (photoCount === 1) {
    return 'single_full' // Hero/single layout
  } else if (photoCount === 2) {
    return 'grid_2x2' // Side by side
  } else if (photoCount === 3 || photoCount === 4) {
    return 'grid_2x2' // Grid layout
  } else if (photoCount === 5 || photoCount === 6) {
    return 'grid_3x2' // Larger grid
  } else {
    // More than 6 photos: limit to 6 displayed
    return 'grid_3x2'
  }
}

/**
 * RULE 2: Color Theme Selection (Emotion-Color-Engine V1)
 * Based on tags (v1Spez.md section 6.5)
 */
function computeColorTheme(tagNames: string[], photos: any[]): ColorTheme {
  // Priority order: Check tags from most specific to least specific

  // Romantic themes (highest priority for emotional connection)
  if (tagNames.some(tag => ['Romantic Moments', 'In Love', 'Anniversary'].includes(tag))) {
    return 'warm_red'
  }

  // Nature themes
  if (tagNames.some(tag => ['Nature & Hiking', 'Adventure / Sports'].includes(tag))) {
    return 'earth_green'
  }

  // Water/Beach themes
  if (tagNames.some(tag => ['Lake / Beach'].includes(tag))) {
    return 'ocean_blue'
  }

  // Nightlife themes
  if (tagNames.some(tag => ['Nightlife'].includes(tag))) {
    return 'deep_purple'
  }

  // Food/Home themes (warm and cozy)
  if (tagNames.some(tag => ['Food & Restaurant', 'Home & Everyday Life'].includes(tag))) {
    return 'warm_earth'
  }

  // Travel themes (soft and elegant)
  if (tagNames.some(tag => ['Travel', 'Roadtrip', 'City & Sightseeing'].includes(tag))) {
    return 'soft_rose'
  }

  // Fallback: Use dominant color from first photo if available
  if (photos && photos.length > 0 && photos[0].dominant_colors) {
    const dominantColor = photos[0].dominant_colors[0]
    if (dominantColor) {
      // Simple heuristic: warm colors vs cool colors
      const rgb = dominantColor.rgb
      if (rgb && rgb.length === 3) {
        const [r, g, b] = rgb
        if (r > g && r > b) return 'warm_red' // Reddish
        if (g > r && g > b) return 'earth_green' // Greenish
        if (b > r && b > g) return 'ocean_blue' // Blueish
      }
    }
  }

  // Default: Neutral theme
  return 'neutral'
}

/**
 * RULE 3: Sprinkles Selection (Decorative Icons)
 * Based on tags (v1Spez.md section 6.6)
 */
function computeSprinkles(tagNames: string[], hasLocation: boolean): SprinkleIcon[] {
  const sprinkles: SprinkleIcon[] = []

  // Map tags to sprinkle icons
  const tagToSprinkle: Record<string, SprinkleIcon> = {
    'Romantic Moments': 'heart',
    'In Love': 'heart',
    'Anniversary': 'heart',
    'Nature & Hiking': 'mountain',
    'Lake / Beach': 'beach',
    'Travel': 'airplane',
    'Roadtrip': 'airplane',
    'Food & Restaurant': 'utensils',
    'Surprise / Gift': 'gift',
    'Birthday': 'balloon',
    'Happy': 'star',
    'Adventure / Sports': 'mountain',
  }

  // Add sprinkles based on tags (max 3 to avoid clutter)
  for (const tag of tagNames) {
    if (tagToSprinkle[tag] && !sprinkles.includes(tagToSprinkle[tag])) {
      sprinkles.push(tagToSprinkle[tag])
      if (sprinkles.length >= 3) break
    }
  }

  // Add camera icon if multiple photos
  // (This is handled by layout, so we can skip for now)

  // Add sun for beach/outdoor themes if not already present
  if (tagNames.some(tag => ['Lake / Beach', 'Nature & Hiking'].includes(tag))) {
    if (!sprinkles.includes('sun')) {
      sprinkles.push('sun')
    }
  }

  return sprinkles
}
