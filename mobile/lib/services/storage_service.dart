import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// Local-only persistence for now (single device). Swap this class's
/// internals for API calls to a NestJS backend later if you add sync —
/// nothing outside this file needs to change.
class StorageService {
  static const _key = 'studentos_data';

  static Future<AppData?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      return AppData.decode(raw);
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(AppData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, data.encode());
  }
}
