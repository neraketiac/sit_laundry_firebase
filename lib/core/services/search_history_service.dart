import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class SearchHistoryItem {
  final String name;
  final String address;
  final int customerId;
  final DateTime timestamp;

  SearchHistoryItem({
    required this.name,
    required this.address,
    required this.customerId,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'customerId': customerId,
        'timestamp': timestamp.toIso8601String(),
      };

  factory SearchHistoryItem.fromJson(Map<String, dynamic> json) =>
      SearchHistoryItem(
        name: json['name'] ?? '',
        address: json['address'] ?? '',
        customerId: json['customerId'] ?? 0,
        timestamp: DateTime.parse(
            json['timestamp'] ?? DateTime.now().toIso8601String()),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchHistoryItem &&
          runtimeType == other.runtimeType &&
          customerId == other.customerId;

  @override
  int get hashCode => customerId.hashCode;
}

class SearchHistoryService {
  static final SearchHistoryService _instance =
      SearchHistoryService._internal();

  factory SearchHistoryService() => _instance;

  SearchHistoryService._internal();

  static const String _filename = 'search_history.json';
  static const int _maxHistoryItems = 10;
  List<SearchHistoryItem>? _cachedHistory;

  Future<String> _getHistoryFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$_filename';
  }

  /// Load search history from local storage
  Future<List<SearchHistoryItem>> getHistory() async {
    // Return cached history if available
    if (_cachedHistory != null) {
      return _cachedHistory!;
    }

    try {
      final filePath = await _getHistoryFilePath();
      final file = File(filePath);

      if (!file.existsSync()) {
        _cachedHistory = [];
        return [];
      }

      final contents = await file.readAsString();
      if (contents.isEmpty) {
        _cachedHistory = [];
        return [];
      }

      final jsonData = jsonDecode(contents) as List;
      _cachedHistory = jsonData
          .map((item) =>
              SearchHistoryItem.fromJson(item as Map<String, dynamic>))
          .toList();

      return _cachedHistory!;
    } catch (e) {
      print('Error loading search history: $e');
      _cachedHistory = [];
      return [];
    }
  }

  /// Save a search item to history
  Future<void> addToHistory(SearchHistoryItem item) async {
    try {
      // Load current history
      var history = await getHistory();

      // Remove if already exists (to move it to top)
      history.removeWhere((h) => h.customerId == item.customerId);

      // Add new item at the beginning
      history.insert(0, item);

      // Keep only the most recent N items
      if (history.length > _maxHistoryItems) {
        history = history.sublist(0, _maxHistoryItems);
      }

      // Save to file
      final filePath = await _getHistoryFilePath();
      final file = File(filePath);
      final jsonData = jsonEncode(history.map((h) => h.toJson()).toList());
      await file.writeAsString(jsonData);

      // Update cache
      _cachedHistory = history;
    } catch (e) {
      print('Error saving to search history: $e');
    }
  }

  /// Clear all search history
  Future<void> clearHistory() async {
    try {
      final filePath = await _getHistoryFilePath();
      final file = File(filePath);

      if (file.existsSync()) {
        await file.delete();
      }

      _cachedHistory = [];
    } catch (e) {
      print('Error clearing search history: $e');
    }
  }

  /// Get recent searches (used for displaying in UI)
  Future<List<SearchHistoryItem>> getRecentSearches({int limit = 5}) async {
    final history = await getHistory();
    return history.take(limit).toList();
  }
}
