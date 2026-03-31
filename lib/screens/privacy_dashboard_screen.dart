import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class PrivacyDashboardScreen extends StatefulWidget {
  const PrivacyDashboardScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyDashboardScreen> createState() => _PrivacyDashboardScreenState();
}

class _PrivacyDashboardScreenState extends State<PrivacyDashboardScreen> {
  int _memoryCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    setState(() {
      _memoryCount = StorageService.getStorageCount();
    });
  }

  void _deleteAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete All Data"),
        content: const Text("Are you sure? This will instantly delete all captured memories from this device. This cannot be undone.", style: TextStyle(color: Colors.white70)),
        backgroundColor: const Color(0xFF1A1A1A),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StorageService.clearAll();
      _loadStats();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("All local data deleted successfully.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Icon(Icons.shield, size: 80, color: Color(0xFF03DAC6)),
        const SizedBox(height: 16),
        const Text(
          "Zero-Trust Privacy",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        const Text(
          "Your data is fully encrypted and stays only on this device. We don't have access to it.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
        const SizedBox(height: 32),
        Card(
          color: const Color(0xFF1E1E1E),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text("Stored Memories", style: TextStyle(color: Colors.white54, fontSize: 16)),
                const SizedBox(height: 8),
                Text("\$_memoryCount", style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: _deleteAllData,
          icon: const Icon(Icons.delete_forever),
          label: const Text("Delete All Data Instantly"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error.withOpacity(0.8),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
