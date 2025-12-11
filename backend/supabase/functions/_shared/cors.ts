// Shared utilities for Supabase Edge Functions
// Used across all API endpoints

export const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'GET, POST, PATCH, DELETE, OPTIONS',
}

export function corsResponse(body: unknown, status = 200) {
  return new Response(
    JSON.stringify(body),
    {
      status,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    }
  )
}

export function errorResponse(message: string, status = 500) {
  return corsResponse({ error: message }, status)
}

export function successResponse(data: unknown, status = 200) {
  return corsResponse(data, status)
}
