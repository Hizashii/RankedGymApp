import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  const SupabaseConfig._();

  static const url = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  static Future<void> initIfConfigured() async {
    if (url.isEmpty || anonKey.isEmpty) {
      return;
    }
    await Supabase.initialize(url: url, anonKey: anonKey);
  }
}
