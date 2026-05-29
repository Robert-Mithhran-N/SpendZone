import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';

/// Provider for the AppDatabase singleton instance
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  
  // Clean up database resources when the provider is destroyed (if ever)
  ref.onDispose(() {
    db.close();
  });
  
  return db;
});
