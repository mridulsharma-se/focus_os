import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'services/storage_service.dart';
import 'services/filter_service.dart';
import 'models/memory.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  await FilterService.init();
  runApp(const FocusOSApp());
}

class FocusOSApp extends StatefulWidget {
  const FocusOSApp({Key? key}) : super(key: key);

  @override
  State<FocusOSApp> createState() => _FocusOSAppState();
}

class _FocusOSAppState extends State<FocusOSApp> {
  static const platform = MethodChannel('com.focusos.channel/notifications');

  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler(_handleNativeMethodCall);
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    try {
      final bool hasPermission = await platform.invokeMethod('checkNotificationPermission');
      if (!hasPermission) {
        await platform.invokeMethod('requestNotificationPermission');
      }
    } on PlatformException catch (e) {
      debugPrint("Failed to check permissions: '\${e.message}'.");
    }
  }

  Future<dynamic> _handleNativeMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onNotificationReceived':
        final data = call.arguments as Map<dynamic, dynamic>;
        _processNotification(data);
        break;
      default:
        throw MissingPluginException();
    }
  }

  Future<void> _processNotification(Map<dynamic, dynamic> data) async {
    final packageName = data['package_name'] as String;
    final title = data['title'] as String;
    final text = data['text'] as String;
    final timestamp = data['timestamp'] as int;

    if (!FilterService.isAppAllowed(packageName)) {
      return;
    }

    final content = "\$title: \$text";
    final isImportant = FilterService.isImportant(content);
    
    final memory = Memory(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      content: text,
      source: packageName,
      sender: title,
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp),
      tags: [],
      isImportant: isImportant,
    );

    if (isImportant) {
      await StorageService.saveMemory(memory);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FocusOS',
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
