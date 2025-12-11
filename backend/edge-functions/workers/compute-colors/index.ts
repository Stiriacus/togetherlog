// TogetherLog - Dominant Color Computation Worker
// Note: V1 implementation - Color analysis requires image processing libraries

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

interface ComputeColorsRequest {
  photo_id: string
}

serve(async (req: Request) => {
  try {
    const body: ComputeColorsRequest = await req.json()

    // Validate input
    if (!body.photo_id) {
      return new Response(
        JSON.stringify({ error: 'photo_id is required' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      )
    }

    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Verify photo exists
    const { data: photo, error: photoError } = await supabase
      .from('photos')
      .select('id, url, thumbnail_url')
      .eq('id', body.photo_id)
      .single()

    if (photoError || !photo) {
      return new Response(
        JSON.stringify({ error: 'Photo not found' }),
        { status: 404, headers: { 'Content-Type': 'application/json' } }
      )
    }

    // TODO: V1 LIMITATION - Dominant color extraction requires image processing
    // For production, consider:
    // 1. Using external API (e.g., Color Thief API, Clarifai)
    // 2. Using Canvas API in Deno (if available)
    // 3. AWS Lambda with Sharp + color-thief library
    // 4. Client-side extraction before upload

    // For V1, provide placeholder colors that work well
    // These can be extracted by Smart Pages engine or client-side later
    const dominantColors = [
      { hex: '#8B7355', rgb: [139, 115, 85], percentage: 35 },   // Warm brown (default)
      { hex: '#A0826D', rgb: [160, 130, 109], percentage: 25 },  // Light brown
      { hex: '#6B5D52', rgb: [107, 93, 82], percentage: 20 },    // Dark brown
      { hex: '#D4C4B0', rgb: [212, 196, 176], percentage: 12 },  // Beige
      { hex: '#4A3F35', rgb: [74, 63, 53], percentage: 8 },      // Very dark brown
    ]

    // Update photo with color data
    const { error: updateError } = await supabase
      .from('photos')
      .update({
        dominant_colors: dominantColors,
        updated_at: new Date().toISOString(),
      })
      .eq('id', body.photo_id)

    if (updateError) {
      throw new Error(`Failed to update photo: ${updateError.message}`)
    }

    return new Response(
      JSON.stringify({
        success: true,
        photo_id: body.photo_id,
        dominant_colors: dominantColors,
        note: 'V1: Placeholder colors. Real color extraction requires additional setup.',
      }),
      { status: 200, headers: { 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Error computing colors:', error)
    return new Response(
      JSON.stringify({ error: error.message || 'Internal server error' }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    )
  }
})
