// TogetherLog - Logs API Endpoint
// Handles CRUD operations for logs (memory books)

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { corsHeaders, errorResponse, successResponse } from '../_shared/cors.ts'
import { getAuthContext } from '../_shared/auth.ts'
import { validateString, validateEnum, validateUUID, ValidationException } from '../_shared/validation.ts'

const LOG_TYPES = ['Couple', 'Friends', 'Family', 'Solo', 'Other'] as const
type LogType = typeof LOG_TYPES[number]

interface CreateLogRequest {
  name: string
  type?: LogType
}

interface UpdateLogRequest {
  name?: string
  type?: LogType
}

serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Get authenticated user and Supabase client
    const { user, supabase } = await getAuthContext(req)

    const url = new URL(req.url)
    const pathParts = url.pathname.split('/').filter(Boolean)
    const logId = pathParts[pathParts.length - 1] // Last part might be log ID

    // Route handler
    switch (req.method) {
      case 'GET':
        if (logId && logId !== 'logs') {
          // GET /logs/:id - Get specific log
          return await getLog(supabase, user.id, logId)
        } else {
          // GET /logs - List all logs
          return await listLogs(supabase, user.id)
        }

      case 'POST':
        // POST /logs - Create new log
        return await createLog(supabase, user.id, req)

      case 'PATCH':
        // PATCH /logs/:id - Update log
        if (!logId || logId === 'logs') {
          return errorResponse('Log ID is required for update', 400)
        }
        return await updateLog(supabase, user.id, logId, req)

      case 'DELETE':
        // DELETE /logs/:id - Delete log
        if (!logId || logId === 'logs') {
          return errorResponse('Log ID is required for delete', 400)
        }
        return await deleteLog(supabase, user.id, logId)

      default:
        return errorResponse(`Method ${req.method} not allowed`, 405)
    }
  } catch (error) {
    console.error('Error in logs API:', error)

    if (error instanceof ValidationException) {
      return errorResponse(error.message, 400)
    }

    if (error.message === 'Missing authorization header' || error.message === 'Invalid or expired token') {
      return errorResponse(error.message, 401)
    }

    return errorResponse(error.message || 'Internal server error', 500)
  }
})

// ============================================================================
// Handler Functions
// ============================================================================

async function listLogs(supabase: any, userId: string) {
  const { data, error } = await supabase
    .from('logs')
    .select(`
      id,
      name,
      type,
      created_at,
      updated_at,
      entry_count:entries(count)
    `)
    .eq('user_id', userId)
    .order('created_at', { ascending: false })

  if (error) {
    console.error('Error fetching logs:', error)
    throw new Error('Failed to fetch logs')
  }

  // Format the response to include entry_count
  const logs = data.map((log: any) => ({
    id: log.id,
    name: log.name,
    type: log.type,
    created_at: log.created_at,
    updated_at: log.updated_at,
    entry_count: log.entry_count?.[0]?.count || 0,
  }))

  return successResponse({ logs })
}

async function getLog(supabase: any, userId: string, logId: string) {
  // Validate UUID
  try {
    validateUUID(logId, 'logId')
  } catch (error) {
    if (error instanceof ValidationException) {
      return errorResponse('Invalid log ID format', 400)
    }
    throw error
  }

  const { data, error } = await supabase
    .from('logs')
    .select(`
      id,
      name,
      type,
      created_at,
      updated_at,
      entry_count:entries(count)
    `)
    .eq('id', logId)
    .eq('user_id', userId)
    .single()

  if (error) {
    if (error.code === 'PGRST116') {
      return errorResponse('Log not found', 404)
    }
    console.error('Error fetching log:', error)
    throw new Error('Failed to fetch log')
  }

  // Format the response
  const log = {
    id: data.id,
    name: data.name,
    type: data.type,
    created_at: data.created_at,
    updated_at: data.updated_at,
    entry_count: data.entry_count?.[0]?.count || 0,
  }

  return successResponse({ log })
}

async function createLog(supabase: any, userId: string, req: Request) {
  const body: CreateLogRequest = await req.json()

  // Validate input
  validateString(body.name, 'name', 1, 100)
  if (body.type) {
    validateEnum(body.type, 'type', [...LOG_TYPES])
  }

  // Create log
  const { data, error } = await supabase
    .from('logs')
    .insert({
      user_id: userId,
      name: body.name,
      type: body.type || 'Couple',
    })
    .select()
    .single()

  if (error) {
    console.error('Error creating log:', error)
    throw new Error('Failed to create log')
  }

  return successResponse({ log: data }, 201)
}

async function updateLog(supabase: any, userId: string, logId: string, req: Request) {
  // Validate UUID
  try {
    validateUUID(logId, 'logId')
  } catch (error) {
    if (error instanceof ValidationException) {
      return errorResponse('Invalid log ID format', 400)
    }
    throw error
  }

  const body: UpdateLogRequest = await req.json()

  // Validate input
  if (body.name !== undefined) {
    validateString(body.name, 'name', 1, 100)
  }
  if (body.type !== undefined) {
    validateEnum(body.type, 'type', [...LOG_TYPES])
  }

  // Build update object
  const updates: any = {}
  if (body.name !== undefined) updates.name = body.name
  if (body.type !== undefined) updates.type = body.type

  if (Object.keys(updates).length === 0) {
    return errorResponse('No fields to update', 400)
  }

  // Update log
  const { data, error} = await supabase
    .from('logs')
    .update(updates)
    .eq('id', logId)
    .eq('user_id', userId)
    .select()
    .single()

  if (error) {
    if (error.code === 'PGRST116') {
      return errorResponse('Log not found', 404)
    }
    console.error('Error updating log:', error)
    throw new Error('Failed to update log')
  }

  return successResponse({ log: data })
}

async function deleteLog(supabase: any, userId: string, logId: string) {
  // Validate UUID
  try {
    validateUUID(logId, 'logId')
  } catch (error) {
    if (error instanceof ValidationException) {
      return errorResponse('Invalid log ID format', 400)
    }
    throw error
  }

  // Delete log (CASCADE will delete entries and photos)
  const { error } = await supabase
    .from('logs')
    .delete()
    .eq('id', logId)
    .eq('user_id', userId)

  if (error) {
    console.error('Error deleting log:', error)
    throw new Error('Failed to delete log')
  }

  return successResponse({ message: 'Log deleted successfully' })
}
