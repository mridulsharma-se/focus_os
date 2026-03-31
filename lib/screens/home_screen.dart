import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/memory.dart';
import 'search_screen.dart';
import 'app_filters_screen.dart';
import 'privacy_dashboard_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Memory> _memories = [];

  @override
  void initState() {
    super.initState();
    _loadMemories();
  }

  void _loadMemories() {
    setState(() {
      _memories = StorageService.getAllMemories();
    });
  }

  Widget _buildMemoryFeed() {
    if (_memories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            Text(
              "No memories captured yet.\nFocus on your work, we'll track the rest.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white54),
            )
          ],
        )
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _memories.length,
      itemBuilder: (context, index) {
        final memory = _memories[index];
        final timeString = DateFormat('MMM d, h:mm a').format(memory.timestamp);
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(memory.source.replaceAll('com.', '').toUpperCase(), 
                         style: Theme.of(context).textTheme.bodySmall?.copyWith(
                           color: Theme.of(context).colorScheme.secondary,
                           fontWeight: FontWeight.bold,
                         )),
                    Text(timeString, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white38)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(memory.sender.isNotEmpty ? memory.sender : "Unknown", style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(memory.content, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        );
      },
    );
  }

  final List<Widget> _screens = [
    const SizedBox.shrink(), // placeholder for feed
    const SearchScreen(),
    const AppFiltersScreen(),
    const PrivacyDashboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    _screens[0] = _buildMemoryFeed(); 
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0 ? "FocusOS" :
          _currentIndex == 1 ? "Search" :
          _currentIndex == 2 ? "App Filters" : "Privacy"
        ),
        actions: [
          if (_currentIndex == 0)
            IconButton(icon: const Icon(Icons.refresh), onPressed: _loadMemories)
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 0) _loadMemories();
          setState(() => _currentIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0D0D0D),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.timeline), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.filter_list), label: 'Filters'),
          BottomNavigationBarItem(icon: Icon(Icons.security), label: 'Privacy'),
        ],
      ),
    );
  }
}
