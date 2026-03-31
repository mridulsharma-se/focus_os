import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/memory.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Memory> _searchResults = [];
  Timer? _debounce;

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          if (query.isEmpty) {
            _searchResults = [];
          } else {
            _searchResults = StorageService.searchMemories(query);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search memories, keywords, sources...',
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear, color: Colors.white54),
                onPressed: () {
                  _searchController.clear();
                  _onSearchChanged('');
                },
              ),
            ),
          ),
        ),
        Expanded(
          child: _searchResults.isEmpty
              ? Center(child: Text(_searchController.text.isEmpty ? "Type to search..." : "No results found.", style: const TextStyle(color: Colors.white54)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final memory = _searchResults[index];
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
                                     style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.secondary)),
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
                ),
        ),
      ],
    );
  }
}
