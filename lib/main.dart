import 'package:flutter/material.dart';
import 'package:ranked_gym/app/app.dart';
import 'package:ranked_gym/core/data/hive_service.dart';
import 'package:ranked_gym/core/data/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  await SupabaseConfig.initIfConfigured();
  runApp(const RankedGymApp());
}
