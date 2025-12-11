// TogetherLog - Supabase Client Singleton
// Provides access to Supabase client throughout the app

import 'package:supabase_flutter/supabase_flutter.dart';

/// Global Supabase client instance
/// Initialized in main.dart before runApp()
SupabaseClient get supabase => Supabase.instance.client;
