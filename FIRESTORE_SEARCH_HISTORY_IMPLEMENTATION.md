# Firestore Search History Implementation

## Overview
The search history feature now saves all successful customer searches to Firestore, allowing admins to review which customers staff members are searching for. This helps track staff activity and identify frequently accessed customers.

## What Gets Saved

When a staff member selects a customer from the search results, the following is automatically saved to Firestore:

- **Customer Name** - The name of the customer searched
- **Customer ID** - The unique ID of the customer
- **Staff Name** - Name of the staff member who performed the search
- **Staff ID** - Unique ID of the staff member (e.g., #0707)
- **Timestamp** - Exact date and time of the search (searchedAt)

## Files Created

### 1. **Model** (`lib/features/admin/models/search_history_model.dart`)
- `SearchHistoryModel` - Data class representing a single search entry
- Handles conversion between Firestore documents and Dart objects

### 2. **Firestore Service** (`lib/features/admin/services/search_history_firestore_service.dart`)
- `SearchHistoryFirestoreService` - Singleton service for all Firestore operations
- Methods:
  - `saveSearchHistory()` - Save a new search
  - `getSearchHistoryStream()` - Get all searches as a stream (real-time updates)
  - `getSearchHistoryPage()` - Paginated search history retrieval
  - `getSearchHistoryByDate()` - Filter by specific date
  - `getSearchHistoryByStaff()` - Filter by staff member
  - `getSearchCountForCustomer()` - Count how many times a customer was searched
  - `deleteSearchHistory()` - Remove a single entry
  - `clearAllSearchHistory()` - Clear all history (use with caution)

### 3. **Admin Page** (`lib/features/pages/header/Admin/subAdmin/search_history_page.dart`)
- `SearchHistoryPage` - Beautiful UI for viewing all search history
- Features:
  - Real-time list of searches sorted by latest first
  - Search by customer name or staff name
  - Filter by staff member using chips
  - Display count of filtered results
  - Long-press to delete individual entries
  - Shows formatted date and time

### 4. **Modified Files**
- `lib/shared/widgets/jobdisplay/autocompletecustomer.dart` - Now saves to Firestore when customer selected
- `lib/features/pages/header/Admin/showAdminMainPage.dart` - Added Search History menu item

## Database Structure

### Collection: `search_history`
```json
{
  "customerId": "123",
  "customerName": "Juan dela Cruz",
  "staffName": "Rowell",
  "staffId": "#0707",
  "searchedAt": Timestamp(2024-08-18 14:30:00)
}
```

## How to Access

### For Users
1. Open the search dialog for customers
2. Select a customer - automatically saved!
3. No action needed

### For Admins
1. Go to **Tools** (Admin menu)
2. Scroll down to **"Search History"** (indigo colored card)
3. Click to open the search history viewer

## Features in Admin View

### Search & Filter
- **Search Box** - Type customer name or staff name to filter
- **Staff Filter Chips** - Click a staff member to see only their searches
- **Real-time Updates** - Shows total count of filtered searches

### View Details
- Customer name and ID
- Staff member who searched
- Exact date and time (formatted)
- Icon badge showing it's a search action

### Manage Entries
- **Long-press** any entry to delete it
- **Refresh button** (top right) to reload all data
- Automatic sorting by latest searches first

## Data Flow

```
User selects customer in search
    ↓
_onCustomerSelected() called
    ↓
Local storage saved (SearchHistoryService)
    ↓
Firestore saved (SearchHistoryFirestoreService)
    ↓
Admin can view in Tools > Search History
```

## Security Notes

- Only admins can view the Search History page
- Only successful selections are saved (not failed searches)
- Staff ID and name are automatically captured from `empIdGlobal`
- Deletes only remove from Firestore (local cache also updated)

## Usage Examples

### Save a Search (Automatic)
```dart
// Called automatically in AutoCompleteCustomer
SearchHistoryFirestoreService().saveSearchHistory(
  customerId: 123,
  customerName: "Juan dela Cruz",
  staffName: "Rowell",
  staffId: "#0707",
);
```

### Get All Recent Searches
```dart
final service = SearchHistoryFirestoreService();
final searches = await service.getSearchHistoryPage(limit: 50);
```

### Get Searches by Staff
```dart
final service = SearchHistoryFirestoreService();
final staffSearches = await service.getSearchHistoryByStaff("#0707");
```

### Get Searches for Specific Date
```dart
final service = SearchHistoryFirestoreService();
final todaySearches = await service.getSearchHistoryByDate(DateTime.now());
```

### Count Customer Searches
```dart
final service = SearchHistoryFirestoreService();
final count = await service.getSearchCountForCustomer(123);
print("Customer searched $count times");
```

## Future Enhancements

Possible additions:
- Search analytics (most searched customers, peak search times)
- Export to CSV/PDF for reports
- Search history by date range
- Search suggestions based on history
- Audit trail for data changes
- Integration with salary/performance metrics

## Troubleshooting

### Searches not appearing in Firestore?
- Check that `empIdGlobal` is set correctly
- Verify that `mapEmpId` contains the staff ID mapping
- Check Firestore permissions allow writes to `search_history` collection

### Admin can't see the page?
- Ensure `isAdmin` flag is set to true
- Check that you're logged in as admin
- Verify the import is included in showAdminMainPage.dart
