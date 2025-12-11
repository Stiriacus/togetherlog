// Authentication utilities for Supabase Edge Functions

import { createClient, SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2'

export interface AuthContext {
  user: {
    id: string
    email?: string
  }
  supabase: SupabaseClient
}

export async function getAuthContext(req: Request): Promise<AuthContext> {
  // Get authorization header
  const authHeader = req.headers.get('Authorization')
  if (!authHeader) {
    throw new Error('Missing authorization header')
  }

  // Create Supabase client with user's token
  const supabaseUrl = Deno.env.get('SUPABASE_URL')!
  const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY')!

  const supabase = createClient(supabaseUrl, supabaseAnonKey, {
    global: {
      headers: { Authorization: authHeader },
    },
  })

  // Get user from token
  const { data: { user }, error } = await supabase.auth.getUser()

  if (error || !user) {
    throw new Error('Invalid or expired token')
  }

  return {
    user: {
      id: user.id,
      email: user.email,
    },
    supabase,
  }
}
