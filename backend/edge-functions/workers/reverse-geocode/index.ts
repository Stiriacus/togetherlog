// TogetherLog - Reverse Geocoding Worker
// Converts GPS coordinates to human-readable location names using OpenStreetMap Nominatim

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

interface ReverseGeocodeRequest {
  entry_id: string
  lat: number
  lng: number
}

// Nominatim API rate limit: 1 request per second
const NOMINATIM_DELAY_MS = 1100 // Slightly over 1 second to be safe
let lastRequestTime = 0

serve(async (req: Request) => {
  try {
    const body: ReverseGeocodeRequest = await req.json()

    // Validate input
    if (!body.entry_id || body.lat === undefined || body.lng === undefined) {
      return new Response(
        JSON.stringify({ error: 'entry_id, lat, and lng are required' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      )
    }

    // Validate coordinates
    if (body.lat < -90 || body.lat > 90 || body.lng < -180 || body.lng > 180) {
      return new Response(
        JSON.stringify({ error: 'Invalid coordinates' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      )
    }

    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Check if entry exists and not user-overridden
    const { data: entry, error: entryError } = await supabase
      .from('entries')
      .select('id, location_is_user_overridden')
      .eq('id', body.entry_id)
      .single()

    if (entryError || !entry) {
      return new Response(
        JSON.stringify({ error: 'Entry not found' }),
        { status: 404, headers: { 'Content-Type': 'application/json' } }
      )
    }

    // Don't override user-provided location
    if (entry.location_is_user_overridden) {
      return new Response(
        JSON.stringify({
          message: 'Location is user-overridden, skipping geocoding',
          entry_id: body.entry_id,
        }),
        { status: 200, headers: { 'Content-Type': 'application/json' } }
      )
    }

    // Rate limiting: Ensure we don't exceed Nominatim's 1 req/sec limit
    const now = Date.now()
    const timeSinceLastRequest = now - lastRequestTime
    if (timeSinceLastRequest < NOMINATIM_DELAY_MS) {
      await new Promise(resolve => setTimeout(resolve, NOMINATIM_DELAY_MS - timeSinceLastRequest))
    }
    lastRequestTime = Date.now()

    // Call Nominatim reverse geocoding API
    const nominatimUrl = `https://nominatim.openstreetmap.org/reverse?format=json&lat=${body.lat}&lon=${body.lng}&zoom=14&addressdetails=1`

    const nominatimResponse = await fetch(nominatimUrl, {
      headers: {
        'User-Agent': 'TogetherLog/1.0',
        'Accept-Language': 'en',
      },
    })

    if (!nominatimResponse.ok) {
      throw new Error(`Nominatim API error: ${nominatimResponse.status}`)
    }

    const nominatimData = await nominatimResponse.json()

    // Parse location name
    let displayName = nominatimData.display_name || 'Unknown Location'

    // Try to create a shorter, more readable name
    const address = nominatimData.address
    if (address) {
      const parts = []
      if (address.city) parts.push(address.city)
      else if (address.town) parts.push(address.town)
      else if (address.village) parts.push(address.village)

      if (address.state) parts.push(address.state)
      if (address.country) parts.push(address.country)

      if (parts.length > 0) {
        displayName = parts.join(', ')
      }
    }

    // Update entry with location
    const { error: updateError } = await supabase
      .from('entries')
      .update({
        location_lat: body.lat,
        location_lng: body.lng,
        location_display_name: displayName,
        location_is_user_overridden: false,
      })
      .eq('id', body.entry_id)

    if (updateError) {
      throw new Error(`Failed to update entry: ${updateError.message}`)
    }

    return new Response(
      JSON.stringify({
        success: true,
        entry_id: body.entry_id,
        location: {
          lat: body.lat,
          lng: body.lng,
          display_name: displayName,
          raw_data: nominatimData,
        },
      }),
      { status: 200, headers: { 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Error in reverse geocoding:', error)
    return new Response(
      JSON.stringify({ error: error.message || 'Internal server error' }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    )
  }
})
