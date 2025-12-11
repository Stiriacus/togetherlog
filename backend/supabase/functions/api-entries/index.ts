// TogetherLog - Entries API Endpoint
// Handles CRUD operations for entries (memories) with photos and tags

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { corsHeaders, errorResponse, successResponse } from '../_shared/cors.ts'
import { getAuthContext } from '../_shared/auth.ts'
import { validateString, validateUUID, ValidationException } from '../_shared/validation.ts'

interface CreateEntryRequest {
  event_date: string
  highlight_text?: string
  location_lat?: number
  location_lng?: number
  location_display_name?: string
  location_is_user_overridden?: boolean
  tag_ids?: string[]
  photo_ids?: string[] // Photos uploaded separately, referenced here
}

interface UpdateEntryRequest {
  event_date?: string
  highlight_text?: string
  location_lat?: number
  location_lng?: number
  location_display_name?: string
  location_is_user_overridden?: boolean
  tag_ids?: string[]
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

    // Parse paths like /logs/:logId/entries or /entries/:id
    const isLogEntries = pathParts.includes('logs')
    const logId = isLogEntries ? pathParts[pathParts.indexOf('logs') + 1] : null
    const entryId = pathParts.includes('entries') ? pathParts[pathParts.indexOf('entries') + 1] : null

    // Route handler
    switch (req.method) {
      case 'GET':
        if (pathParts.includes('tags')) {
          // GET /tags - List all tags
          return await listTags(supabase)
        } else if (entryId && entryId !== 'entries') {
          // GET /entries/:id - Get specific entry
          return await getEntry(supabase, user.id, entryId)
        } else if (logId) {
          // GET /logs/:logId/entries - List entries for a log
          return await listEntries(supabase, user.id, logId)
        } else {
          return errorResponse('Invalid endpoint', 400)
        }

      case 'POST':
        if (logId) {
          // POST /logs/:logId/entries - Create entry
          return await createEntry(supabase, user.id, logId, req)
        } else {
          return errorResponse('Log ID is required to create entry', 400)
        }

      case 'PATCH':
        if (entryId && entryId !== 'entries') {
          // PATCH /entries/:id - Update entry
          return await updateEntry(supabase, user.id, entryId, req)
        } else {
          return errorResponse('Entry ID is required for update', 400)
        }

      case 'DELETE':
        if (entryId && entryId !== 'entries') {
          // DELETE /entries/:id - Delete entry
          return await deleteEntry(supabase, user.id, entryId)
        } else {
          return errorResponse('Entry ID is required for delete', 400)
        }

      default:
        return errorResponse(`Method ${req.method} not allowed`, 405)
    }
  } catch (error) {
    console.error('Error in entries API:', error)

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

async function listTags(supabase: any) {
  const { data, error } = await supabase
    .from('tags')
    .select('id, name, category, icon')
    .order('category', { ascending: true })
    .order('name', { ascending: true })

  if (error) {
    console.error('Error fetching tags:', error)
    throw new Error('Failed to fetch tags')
  }

  // Group by category
  const tagsByCategory: Record<string, any[]> = {}
  data.forEach((tag: any) => {
    if (!tagsByCategory[tag.category]) {
      tagsByCategory[tag.category] = []
    }
    tagsByCategory[tag.category].push({
      id: tag.id,
      name: tag.name,
      icon: tag.icon,
    })
  })

  return successResponse({ tags: data, tags_by_category: tagsByCategory })
}

async function listEntries(supabase: any, userId: string, logId: string) {
  // Validate UUID
  try {
    validateUUID(logId, 'logId')
  } catch (error) {
    if (error instanceof ValidationException) {
      return errorResponse('Invalid log ID format', 400)
    }
    throw error
  }

  // Verify log ownership
  const { data: log, error: logError } = await supabase
    .from('logs')
    .select('id')
    .eq('id', logId)
    .eq('user_id', userId)
    .single()

  if (logError || !log) {
    return errorResponse('Log not found', 404)
  }

  // Get entries using the optimized view
  const { data, error } = await supabase
    .from('entries_with_photos_and_tags')
    .select('*')
    .eq('log_id', logId)
    .order('event_date', { ascending: true })

  if (error) {
    console.error('Error fetching entries:', error)
    throw new Error('Failed to fetch entries')
  }

  return successResponse({ entries: data })
}

async function getEntry(supabase: any, userId: string, entryId: string) {
  // Validate UUID
  try {
    validateUUID(entryId, 'entryId')
  } catch (error) {
    if (error instanceof ValidationException) {
      return errorResponse('Invalid entry ID format', 400)
    }
    throw error
  }

  // Get entry with photos and tags
  const { data, error } = await supabase
    .from('entries_with_photos_and_tags')
    .select('*')
    .eq('id', entryId)
    .single()

  if (error) {
    if (error.code === 'PGRST116') {
      return errorResponse('Entry not found', 404)
    }
    console.error('Error fetching entry:', error)
    throw new Error('Failed to fetch entry')
  }

  // Verify ownership through log
  const { data: log, error: logError } = await supabase
    .from('logs')
    .select('id')
    .eq('id', data.log_id)
    .eq('user_id', userId)
    .single()

  if (logError || !log) {
    return errorResponse('Entry not found', 404)
  }

  return successResponse({ entry: data })
}

async function createEntry(supabase: any, userId: string, logId: string, req: Request) {
  // Validate log ID
  try {
    validateUUID(logId, 'logId')
  } catch (error) {
    if (error instanceof ValidationException) {
      return errorResponse('Invalid log ID format', 400)
    }
    throw error
  }

  // Verify log ownership
  const { data: log, error: logError } = await supabase
    .from('logs')
    .select('id')
    .eq('id', logId)
    .eq('user_id', userId)
    .single()

  if (logError || !log) {
    return errorResponse('Log not found', 404)
  }

  const body: CreateEntryRequest = await req.json()

  // Validate required fields
  if (!body.event_date) {
    return errorResponse('event_date is required', 400)
  }

  // Validate highlight text if provided
  if (body.highlight_text !== undefined) {
    validateString(body.highlight_text, 'highlight_text', 0, 500)
  }

  // Validate location data
  if ((body.location_lat !== undefined && body.location_lng === undefined) ||
      (body.location_lat === undefined && body.location_lng !== undefined)) {
    return errorResponse('Both location_lat and location_lng must be provided together', 400)
  }

  if (body.location_lat !== undefined) {
    if (body.location_lat < -90 || body.location_lat > 90) {
      return errorResponse('location_lat must be between -90 and 90', 400)
    }
    if (body.location_lng! < -180 || body.location_lng! > 180) {
      return errorResponse('location_lng must be between -180 and 180', 400)
    }
  }

  // Create entry
  const { data: entry, error: entryError } = await supabase
    .from('entries')
    .insert({
      log_id: logId,
      event_date: body.event_date,
      highlight_text: body.highlight_text || '',
      location_lat: body.location_lat,
      location_lng: body.location_lng,
      location_display_name: body.location_display_name,
      location_is_user_overridden: body.location_is_user_overridden || false,
      // Smart Page defaults (will be computed by workers in MILESTONE 7)
      page_layout_type: 'single_full',
      color_theme: 'neutral',
      sprinkles: [],
      is_processed: false,
    })
    .select()
    .single()

  if (entryError) {
    console.error('Error creating entry:', entryError)
    throw new Error('Failed to create entry')
  }

  // Assign tags if provided
  if (body.tag_ids && body.tag_ids.length > 0) {
    const tagInserts = body.tag_ids.map(tagId => ({
      entry_id: entry.id,
      tag_id: tagId,
    }))

    const { error: tagsError } = await supabase
      .from('entry_tags')
      .insert(tagInserts)

    if (tagsError) {
      console.error('Error assigning tags:', tagsError)
      // Non-fatal: entry created but tags failed
    }
  }

  // Link photos if provided
  if (body.photo_ids && body.photo_ids.length > 0) {
    const photoUpdates = body.photo_ids.map((photoId, index) => ({
      id: photoId,
      entry_id: entry.id,
      display_order: index,
    }))

    for (const photo of photoUpdates) {
      const { error: photoError } = await supabase
        .from('photos')
        .update({ entry_id: photo.entry_id, display_order: photo.display_order })
        .eq('id', photo.id)

      if (photoError) {
        console.error('Error linking photo:', photoError)
      }
    }
  }

  // Fetch complete entry with photos and tags
  const { data: completeEntry } = await supabase
    .from('entries_with_photos_and_tags')
    .select('*')
    .eq('id', entry.id)
    .single()

  return successResponse({ entry: completeEntry || entry }, 201)
}

async function updateEntry(supabase: any, userId: string, entryId: string, req: Request) {
  // Validate UUID
  try {
    validateUUID(entryId, 'entryId')
  } catch (error) {
    if (error instanceof ValidationException) {
      return errorResponse('Invalid entry ID format', 400)
    }
    throw error
  }

  // Verify ownership
  const { data: entry, error: entryError } = await supabase
    .from('entries')
    .select('log_id')
    .eq('id', entryId)
    .single()

  if (entryError) {
    return errorResponse('Entry not found', 404)
  }

  const { data: log, error: logError } = await supabase
    .from('logs')
    .select('id')
    .eq('id', entry.log_id)
    .eq('user_id', userId)
    .single()

  if (logError || !log) {
    return errorResponse('Entry not found', 404)
  }

  const body: UpdateEntryRequest = await req.json()

  // Validate input
  if (body.highlight_text !== undefined) {
    validateString(body.highlight_text, 'highlight_text', 0, 500)
  }

  // Validate location data
  if ((body.location_lat !== undefined && body.location_lng === undefined) ||
      (body.location_lat === undefined && body.location_lng !== undefined)) {
    return errorResponse('Both location_lat and location_lng must be provided together', 400)
  }

  if (body.location_lat !== undefined) {
    if (body.location_lat < -90 || body.location_lat > 90) {
      return errorResponse('location_lat must be between -90 and 90', 400)
    }
    if (body.location_lng! < -180 || body.location_lng! > 180) {
      return errorResponse('location_lng must be between -180 and 180', 400)
    }
  }

  // Build update object
  const updates: any = {}
  if (body.event_date !== undefined) updates.event_date = body.event_date
  if (body.highlight_text !== undefined) updates.highlight_text = body.highlight_text
  if (body.location_lat !== undefined) updates.location_lat = body.location_lat
  if (body.location_lng !== undefined) updates.location_lng = body.location_lng
  if (body.location_display_name !== undefined) updates.location_display_name = body.location_display_name
  if (body.location_is_user_overridden !== undefined) updates.location_is_user_overridden = body.location_is_user_overridden

  if (Object.keys(updates).length > 0) {
    const { error: updateError } = await supabase
      .from('entries')
      .update(updates)
      .eq('id', entryId)

    if (updateError) {
      console.error('Error updating entry:', updateError)
      throw new Error('Failed to update entry')
    }
  }

  // Update tags if provided
  if (body.tag_ids !== undefined) {
    // Delete existing tags
    await supabase
      .from('entry_tags')
      .delete()
      .eq('entry_id', entryId)

    // Insert new tags
    if (body.tag_ids.length > 0) {
      const tagInserts = body.tag_ids.map(tagId => ({
        entry_id: entryId,
        tag_id: tagId,
      }))

      const { error: tagsError } = await supabase
        .from('entry_tags')
        .insert(tagInserts)

      if (tagsError) {
        console.error('Error updating tags:', tagsError)
      }
    }
  }

  // Fetch updated entry
  const { data: updatedEntry } = await supabase
    .from('entries_with_photos_and_tags')
    .select('*')
    .eq('id', entryId)
    .single()

  return successResponse({ entry: updatedEntry })
}

async function deleteEntry(supabase: any, userId: string, entryId: string) {
  // Validate UUID
  try {
    validateUUID(entryId, 'entryId')
  } catch (error) {
    if (error instanceof ValidationException) {
      return errorResponse('Invalid entry ID format', 400)
    }
    throw error
  }

  // Verify ownership
  const { data: entry, error: entryError } = await supabase
    .from('entries')
    .select('log_id')
    .eq('id', entryId)
    .single()

  if (entryError) {
    return errorResponse('Entry not found', 404)
  }

  const { data: log, error: logError } = await supabase
    .from('logs')
    .select('id')
    .eq('id', entry.log_id)
    .eq('user_id', userId)
    .single()

  if (logError || !log) {
    return errorResponse('Entry not found', 404)
  }

  // Delete entry (CASCADE will delete photos and entry_tags)
  const { error: deleteError } = await supabase
    .from('entries')
    .delete()
    .eq('id', entryId)

  if (deleteError) {
    console.error('Error deleting entry:', deleteError)
    throw new Error('Failed to delete entry')
  }

  return successResponse({ message: 'Entry deleted successfully' })
}
