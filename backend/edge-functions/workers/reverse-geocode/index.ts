// TogetherLog - Reverse Geocoding Worker
// Uses OpenStreetMap/Nominatim
// To be implemented in MILESTONE 6

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'

serve(async (req: Request) => {
  try {
    const { lat, lng } = await req.json()

    // Placeholder: In real implementation:
    // 1. Call Nominatim API with lat/lng
    // 2. Parse location data
    // 3. Return human-readable display_name
    // 4. Implement caching to respect rate limits

    return new Response(
      JSON.stringify({
        message: 'Reverse geocoding worker - Coming soon in MILESTONE 6',
        lat,
        lng,
      }),
      {
        status: 200,
        headers: { 'Content-Type': 'application/json' },
      }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        status: 500,
        headers: { 'Content-Type': 'application/json' },
      }
    )
  }
})
