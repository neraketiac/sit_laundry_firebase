import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/features/admin/models/search_history_model.dart';
import 'package:laundry_firebase/features/admin/services/search_history_firestore_service.dart';
import 'package:laundry_firebase/core/global/variables.dart';

class SearchHistoryPage extends StatefulWidget {
  const SearchHistoryPage({super.key});

  @override
  State<SearchHistoryPage> createState() => _SearchHistoryPageState();
}

class _SearchHistoryPageState extends State<SearchHistoryPage> {
  late SearchHistoryFirestoreService _firestoreService;
  List<SearchHistoryModel> _searchHistory = [];
  bool _isLoading = true;
  String _filterStaffId = '';
  final TextEditingController _searchController = TextEditingController();

  // Pagination variables
  DocumentSnapshot? _lastDocument;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _firestoreService = SearchHistoryFirestoreService();
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    setState(() {
      _isLoading = true;
      _searchHistory = [];
      _lastDocument = null;
      _hasMoreData = true;
    });
    await _loadMoreSearchHistory();
  }

  Future<void> _loadMoreSearchHistory() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() => _isLoadingMore = true);

    try {
      final result = await _firestoreService.getSearchHistoryPageWithDoc(
        limit: _pageSize,
        startAfter: _lastDocument,
      );

      setState(() {
        final newHistory = result['items'] as List<SearchHistoryModel>;
        final lastDoc = result['lastDocument'] as DocumentSnapshot?;

        _searchHistory.addAll(newHistory);
        _lastDocument = lastDoc;
        _hasMoreData = newHistory.length == _pageSize;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  List<SearchHistoryModel> get _filteredHistory {
    List<SearchHistoryModel> filtered = _searchHistory;

    // Filter by staff ID if selected
    if (_filterStaffId.isNotEmpty) {
      filtered =
          filtered.where((item) => item.staffId == _filterStaffId).toList();
    }

    // Filter by search text (customer name or staff name)
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered
          .where((item) =>
              item.customerName.toLowerCase().contains(query) ||
              item.staffName.toLowerCase().contains(query))
          .toList();
    }

    return filtered;
  }

  // Get unique staff list for filter
  List<String> get _uniqueStaffIds {
    final staffIds = <String>{};
    for (var item in _searchHistory) {
      staffIds.add(item.staffId);
    }
    return staffIds.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSearchHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search box
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search customer or staff name...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 12),
                // Staff filter
                if (_uniqueStaffIds.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filter by Staff:',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            FilterChip(
                              label: const Text('All Staff'),
                              selected: _filterStaffId.isEmpty,
                              onSelected: (selected) {
                                setState(() {
                                  _filterStaffId = '';
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            ..._uniqueStaffIds.map((staffId) {
                              final staffName = mapEmpId[staffId] ?? staffId;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(staffName),
                                  selected: _filterStaffId == staffId,
                                  onSelected: (selected) {
                                    setState(() {
                                      _filterStaffId = selected ? staffId : '';
                                    });
                                  },
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                // Stats
                Text(
                  'Total: ${_filteredHistory.length} searches',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
          // Search history list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredHistory.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              'No search history found',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      )
                    : NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification is ScrollEndNotification &&
                              notification.metrics.extentAfter == 0) {
                            // User scrolled to the bottom
                            if (_hasMoreData && !_isLoadingMore) {
                              _loadMoreSearchHistory();
                            }
                          }
                          return false;
                        },
                        child: ListView.builder(
                          itemCount: _filteredHistory.length +
                              (_isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            // Show loading indicator at the end
                            if (index == _filteredHistory.length) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            }

                            final item = _filteredHistory[index];
                            return _buildSearchHistoryTile(item);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHistoryTile(SearchHistoryModel item) {
    final dateTime = item.searchedAt.toDate();
    final formattedDate = DateFormat('MMM dd, yyyy').format(dateTime);
    final formattedTime = DateFormat('hh:mm a').format(dateTime);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(
            Icons.search,
            color: Colors.blue.shade900,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.customerName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Customer ID: ${item.customerId}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        subtitle: Text(
          'By: ${item.staffName}',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formattedDate,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
            Text(
              formattedTime,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        onLongPress: () {
          _showDeleteConfirmation(item.docId);
        },
      ),
    );
  }

  void _showDeleteConfirmation(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              await _firestoreService.deleteSearchHistory(docId);
              _loadSearchHistory();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Entry deleted')),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
