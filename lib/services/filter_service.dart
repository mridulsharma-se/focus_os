import 'package:shared_preferences/shared_preferences.dart';

class FilterService {
  static const _appTogglesPrefix = 'appToggle_';
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Importance Detection
  static bool isImportant(String content) {
    final lower = content.toLowerCase();
    
    // Simple rule-based logic
    final keywords = [
      'tomorrow', 'today', 'tonight', 'morning', 'evening',
      '5pm', 'am', 'pm',
      'i will', "let's", 'meet', 'call', 'remind',
      '\$', '₹', 'deadline', 'urgent', 'asap', 'payment', 'paid'
    ];

    return keywords.any((kw) => lower.contains(kw));
  }

  // App Filtering
  static bool isAppAllowed(String packageName) {
    if (_prefs == null) return true; 
    
    // Default to track, user can opt-out.
    return _prefs!.getBool('$_appTogglesPrefix$packageName') ?? true;
  }

  static Future<void> toggleApp(String packageName, bool isAllowed) async {
    await _prefs?.setBool('$_appTogglesPrefix$packageName', isAllowed);
  }

  static bool getAppToggleState(String packageName) {
    return _prefs?.getBool('$_appTogglesPrefix$packageName') ?? true;
  }
}
