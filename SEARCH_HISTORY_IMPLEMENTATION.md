# Search History Implementation

## Overview
The search history feature automatically saves customer searches to local storage and displays recent searches when the search field is empty.

## How It Works

### Automatic Saving
- **Triggered on**: Customer selection (when user clicks a customer from the dropdown)
- **Frequency**: Only saves successful selections, not every keystroke
- **Storage**: JSON file saved to the app's documents directory (`search_history.json`)
- **Max items**: Keeps the 10 most recent unique searches
- **Deduplication**: If a customer is searched again, they move to the top of the history

### Displaying Recent Searches
- When you open the search dialog and the search field is empty, the dropdown shows your 5 most recent searches
- Once you start typing, it filters from all customers as usual
- Recent searches are loaded fresh each time the dialog opens

## Files

### New Files Created
- `lib/core/services/search_history_service.dart` - Core service for managing search history
  - `SearchHistoryItem` - Data class for a search entry
  - `SearchHistoryService` - Singleton service for CRUD operations

### Modified Files
- `lib/shared/widgets/jobdisplay/autocompletecustomer.dart` - Integrated history saving on selection

## Usage

The implementation is automatic. When users search for and select a customer:

```dart
// This happens automatically in _onCustomerSelected()
_historyService.addToHistory(
  SearchHistoryItem(
    name: selected.name,
    address: selected.address,
    customerId: selected.customerId,
    timestamp: DateTime.now(),
  ),
);
```

## Implementation Details

### SearchHistoryService Features

**getHistory()** - Load all search history from storage
```dart
final history = await SearchHistoryService().getHistory();
```

**getRecentSearches(limit)** - Get N most recent searches (default: 5)
```dart
final recent = await SearchHistoryService().getRecentSearches(limit: 5);
```

**addToHistory(item)** - Save a search (automatic deduplication)
```dart
await SearchHistoryService().addToHistory(item);
```

**clearHistory()** - Delete all search history
```dart
await SearchHistoryService().clearHistory();
```

## Design Decisions

1. **When to Save**: Saves only on successful selection, not on keystroke or query changes
   - Reduces I/O operations
   - Only saves intentional searches

2. **Caching**: Caches history in memory after first load
   - Faster subsequent access
   - Clears when new items added

3. **Max Items**: Keeps 10 items (shows 5 recent)
   - Balance between usefulness and storage
   - Automatic cleanup

4. **Deduplication**: Same customer appearing multiple times moves to top
   - User knows their most common searches
   - Cleaner history

5. **Storage Location**: App documents directory
   - Backed up with app data on most devices
   - Cleared when app is uninstalled

## Future Enhancements

If you want to extend this, consider:
- Add a clear button next to the search field
- Show search frequency (how many times a customer was searched)
- Time-based filtering (search from last 30 days)
- Export/import history
- Search history analytics (most searched customers, peak search times)
