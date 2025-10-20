import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://mssaspqdthfqbsiykkbx.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1zc2FzcHFkdGhmcWJzaXlra2J4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA4OTI4NjYsImV4cCI6MjA3NjQ2ODg2Nn0.T6eMHkTeS3izaRrAhIzNYrCpaM2Kjt0UJp8migC49dI';

  static Future<void> init() async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      debug: true,
    );
  }
}
