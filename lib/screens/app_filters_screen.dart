import 'package:flutter/material.dart';
import '../services/filter_service.dart';

class AppFiltersScreen extends StatefulWidget {
  const AppFiltersScreen({Key? key}) : super(key: key);

  @override
  State<AppFiltersScreen> createState() => _AppFiltersScreenState();
}

class _AppFiltersScreenState extends State<AppFiltersScreen> {
  final List<Map<String, String>> _trackedApps = [
    {"name": "WhatsApp", "package": "com.whatsapp"},
    {"name": "Instagram", "package": "com.instagram.android"},
    {"name": "Gmail", "package": "com.google.android.gm"},
    {"name": "Messages", "package": "com.google.android.apps.messaging"},
    {"name": "Slack", "package": "com.Slack"},
    {"name": "Telegram", "package": "org.telegram.messenger"},
    {"name": "Discord", "package": "com.discord"},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 24.0, top: 8),
          child: Text(
            "Toggle which apps FocusOS should track for important information. System notifications and sensitive info are always automatically ignored.",
            style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.4),
          ),
        ),
        ..._trackedApps.map((app) {
          final isAllowed = FilterService.getAppToggleState(app['package']!);
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(app['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Text(app['package']!, style: const TextStyle(color: Colors.white54, fontSize: 13)),
              value: isAllowed,
              onChanged: (value) async {
                await FilterService.toggleApp(app['package']!, value);
                setState(() {}); // refresh UI
              },
            ),
          );
        }).toList(),
      ],
    );
  }
}
