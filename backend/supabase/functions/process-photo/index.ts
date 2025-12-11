// TogetherLog - Photo Processing Worker
// Handles: EXIF extraction, thumbnail generation
// Note: V1 implementation - EXIF/thumbnail processing requires additional libraries

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

interface ProcessPhotoRequest {
  photo_id: string
  storage_path: string
}

serve(async (req: Request) => {
  try {
    const body: ProcessPhotoRequest = await req.json()

    // Validate input
    if (!body.photo_id || !body.storage_path) {
      return new Response(
        JSON.stringify({ error: 'photo_id and storage_path are required' }),
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
      .select('id, storage_path')
      .eq('id', body.photo_id)
      .single()

    if (photoError || !photo) {
      return new Response(
        JSON.stringify({ error: 'Photo not found' }),
        { status: 404, headers: { 'Content-Type': 'application/json' } }
      )
    }

    // TODO: V1 LIMITATION - Full EXIF extraction requires image processing libraries
    // For production, consider:
    // 1. Using external service (e.g., AWS Lambda with Sharp/ExifReader)
    // 2. Using Deno-compatible EXIF library when available
    // 3. Client-side EXIF extraction before upload

    // For now, we'll store basic metadata that can be provided by client
    const exifData = {
      processed_at: new Date().toISOString(),
      processor: 'TogetherLog-V1',
      note: 'Full EXIF extraction requires additional setup',
    }

    // TODO: V1 LIMITATION - Thumbnail generation requires image processing
    // For production, consider:
    // 1. Using Supabase Image Transformation (if available in your plan)
    // 2. External service like Cloudinary or imgix
    // 3. AWS Lambda with Sharp library

    // For now, use the original image URL as thumbnail (will be slow but functional)
    const { data: publicUrlData } = supabase.storage
      .from('photos')
      .getPublicUrl(body.storage_path)

    const url = publicUrlData.publicUrl
    const thumbnailUrl = url // V1: Same as original, to be enhanced

    // Update photo record
    const { error: updateError } = await supabase
      .from('photos')
      .update({
        url: url,
        thumbnail_url: thumbnailUrl,
        exif_data: exifData,
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
        url,
        thumbnail_url: thumbnailUrl,
        exif_data: exifData,
        note: 'V1: Basic processing complete. EXIF and thumbnail generation require additional setup.',
      }),
      { status: 200, headers: { 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Error processing photo:', error)
    return new Response(
      JSON.stringify({ error: error.message || 'Internal server error' }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    )
  }
})
