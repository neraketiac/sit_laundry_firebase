# Search History - Architecture & Data Flow

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    LAUNDRY APP                              │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  User Interface Layer                                │   │
│  ├──────────────────────────────────────────────────────┤   │
│  │                                                        │   │
│  │  JobsDone Page  →  Search Button  →  AutoComplete    │   │
│  │                       (🔍)            Customer       │   │
│  │                                     Search Dialog    │   │
│  │                                                        │   │
│  └──────────────────────────────────────────────────────┘   │
│                            ↓                                  │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  AutoCompleteCustomer Widget                         │   │
│  ├──────────────────────────────────────────────────────┤   │
│  │                                                        │   │
│  │  • optionsBuilder():                                 │   │
│  │    - Shows 10 recent searches (when empty)           │   │
│  │    - Filters all customers (when typing)            │   │
│  │                                                        │   │
│  │  • _onCustomerSelected():                           │   │
│  │    - Saves to Local Storage (SearchHistoryService)  │   │
│  │    - Saves to Firestore (Audit Trail)               │   │
│  │                                                        │   │
│  └──────────────────────────────────────────────────────┘   │
│         ↓                                    ↓               │
│    ┌─────────────────┐          ┌──────────────────────┐   │
│    │ LOCAL STORAGE   │          │ FIRESTORE DATABASE   │   │
│    │ (Device Level)  │          │ (Cloud)              │   │
│    └─────────────────┘          └──────────────────────┘   │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## Component Diagram

```
AutoCompleteCustomer (StatefulWidget)
│
├── _buildField()
│   └── Shows search input with focus animations
│
├── optionsBuilder()
│   ├── Empty input → Show 10 recent from local storage
│   └── Has input → Filter all customers from repository
│
├── _onCustomerSelected()
│   ├── Save to Local Storage
│   │   └── SearchHistoryService.addToHistory()
│   │       └── File: search_history.json (in app docs)
│   │
│   └── Save to Firestore
│       └── SearchHistoryFirestoreService.saveSearchHistory()
│           └── Firestore Collection: search_history
│
└── Search History Admin UI
    └── SearchHistoryPage
        ├── Displays all searches (Firestore stream)
        ├── Search box (filters by name)
        ├── Staff filter chips
        └── Delete functionality
```

## Data Flow Diagram

```
USER INTERACTION FLOW
═════════════════════════════════════════════════════════════

1. User Opens JobsDone Page
   │
   ├─→ readDataJobsDone() widget loads
   │   └─→ Displays job data and action buttons
   │
   └─→ User clicks Search Button (🔍)

2. Search Dialog Opens
   │
   ├─→ showSearchDialog() invoked
   │   └─→ Creates AlertDialog with AutoCompleteCustomer
   │
   └─→ AutoCompleteCustomer widget initialized

3. AutoCompleteCustomer Displays Options
   │
   ├─→ TextField is empty
   │   ├─→ optionsBuilder() called
   │   ├─→ _recentSearches loaded from local storage
   │   └─→ UI shows 10 recent searches in dropdown
   │
   ├─→ User types something
   │   ├─→ optionsBuilder() called again
   │   ├─→ Filters CustomerRepository by query
   │   └─→ UI shows matching customers
   │
   └─→ UI shows results in dropdown

4. User Selects Customer
   │
   ├─→ _onCustomerSelected() called
   │
   ├─→ LOCAL SAVE PATH:
   │   ├─→ SearchHistoryService.addToHistory()
   │   ├─→ Remove if exists (dedup)
   │   ├─→ Add to top of list
   │   ├─→ Keep only 10 most recent
   │   └─→ Save to search_history.json (device)
   │
   ├─→ FIRESTORE SAVE PATH:
   │   ├─→ SearchHistoryFirestoreService.saveSearchHistory()
   │   ├─→ Collect: customerId, customerName, staffName, staffId
   │   ├─→ Add: searchedAt timestamp
   │   └─→ Save to Firestore search_history collection
   │
   ├─→ UPDATE UI:
   │   ├─→ _loadRecentSearches() called
   │   ├─→ Reloads recent searches for next session
   │   └─→ setState() updates dropdown
   │
   └─→ Selection processed (customer data set in jobRepo)

5. Next Time User Searches
   │
   ├─→ AutoCompleteCustomer re-initialized
   ├─→ initState() → _loadRecentSearches()
   ├─→ Recent searches loaded from local storage
   └─→ Shows at top of dropdown


ADMIN VIEW FLOW
═════════════════════════════════════════════════════════════

1. Admin Opens Tools Menu
   │
   └─→ Shows admin dashboard (showAdminMainPage)

2. Admin Clicks "Search History"
   │
   ├─→ SearchHistoryPage opened
   ├─→ initState() called
   │   └─→ _loadSearchHistory() fetches from Firestore
   │
   └─→ UI renders with all searches

3. Admin Searches/Filters
   │
   ├─→ Types in search box
   │   ├─→ onChanged() → setState()
   │   └─→ _filteredHistory getter recalculates
   │
   ├─→ Clicks staff filter chip
   │   ├─→ _filterStaffId updated
   │   └─→ setState() → _filteredHistory recalculates
   │
   └─→ UI updates in real-time

4. Admin Long-Presses Entry
   │
   ├─→ _showDeleteConfirmation() called
   ├─→ AlertDialog shown
   ├─→ Admin confirms delete
   │   ├─→ SearchHistoryFirestoreService.deleteSearchHistory()
   │   └─→ Document removed from Firestore
   │
   └─→ _loadSearchHistory() refreshes list
```

## Service Layer Architecture

```
┌─────────────────────────────────────────────────────────────┐
│           SEARCH HISTORY SERVICES                            │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  LOCAL STORAGE SERVICE                                       │
│  ──────────────────────────────────────────────────────────  │
│  SearchHistoryService (Singleton)                            │
│  │                                                            │
│  ├── SearchHistoryItem (Model)                               │
│  │   ├── name: String                                        │
│  │   ├── address: String                                     │
│  │   ├── customerId: int                                     │
│  │   └── timestamp: DateTime                                 │
│  │                                                            │
│  ├── getHistory() → List<SearchHistoryItem>                 │
│  ├── addToHistory(item) → Future                            │
│  ├── getRecentSearches(limit) → Future<List>                │
│  └── clearHistory() → Future                                │
│                                                               │
│  └── Storage: search_history.json (App Documents)           │
│                                                               │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  FIRESTORE SERVICE                                           │
│  ──────────────────────────────────────────────────────────  │
│  SearchHistoryFirestoreService (Singleton)                   │
│  │                                                            │
│  ├── SearchHistoryModel (Model)                              │
│  │   ├── customerId: String                                  │
│  │   ├── customerName: String                                │
│  │   ├── staffName: String                                   │
│  │   ├── staffId: String                                     │
│  │   └── searchedAt: Timestamp                               │
│  │                                                            │
│  ├── saveSearchHistory() → Future                            │
│  ├── getSearchHistoryStream() → Stream<List>                │
│  ├── getSearchHistoryPage(limit) → Future<List>             │
│  ├── getSearchHistoryByDate(date) → Future<List>            │
│  ├── getSearchHistoryByStaff(staffId) → Future<List>        │
│  ├── getSearchCountForCustomer(id) → Future<int>            │
│  ├── deleteSearchHistory(docId) → Future                    │
│  └── clearAllSearchHistory() → Future                       │
│                                                               │
│  └── Storage: Firestore DB (search_history collection)      │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## Database Schema

### Local Storage (JSON)
```json
[
  {
    "name": "Juan dela Cruz",
    "address": "123 Main St",
    "customerId": 100,
    "timestamp": "2024-08-18T14:30:00.000Z"
  },
  {
    "name": "Maria Garcia",
    "address": "456 Oak Ave",
    "customerId": 101,
    "timestamp": "2024-08-18T14:25:00.000Z"
  }
]
// Max 10 items, newest first
```

### Firestore Database
```
search_history/
├── autoGeneratedId001
│   ├── customerId: "100"
│   ├── customerName: "Juan dela Cruz"
│   ├── staffName: "Rowell"
│   ├── staffId: "#0707"
│   └── searchedAt: Timestamp(seconds=1724070600, nanoseconds=0)
│
├── autoGeneratedId002
│   ├── customerId: "101"
│   ├── customerName: "Maria Garcia"
│   ├── staffName: "Ella"
│   ├── staffId: "#0808"
│   └── searchedAt: Timestamp(seconds=1724070300, nanoseconds=0)
│
└── ... more entries
```

## Class Relationships

```
    ┌─────────────────────────┐
    │  AutoCompleteCustomer   │
    │ (StatefulWidget)        │
    └────────┬────────────────┘
             │
             ├─ uses → SearchHistoryService
             │         (Local storage)
             │
             ├─ uses → SearchHistoryFirestoreService
             │         (Firestore audit trail)
             │
             └─ contains → SearchHistoryItem (local)
                           SearchHistoryModel (Firestore)


    ┌────────────────────────┐
    │  SearchHistoryPage     │
    │ (Admin View)           │
    └────────┬───────────────┘
             │
             └─ uses → SearchHistoryFirestoreService
                      (Read and delete from Firestore)
```

## File Organization

```
lib/
├── features/
│   ├── admin/
│   │   ├── models/
│   │   │   └── search_history_model.dart         ← Firestore model
│   │   │
│   │   └── services/
│   │       └── search_history_firestore_service.dart  ← Firestore ops
│   │
│   ├── pages/
│   │   └── header/
│   │       └── Admin/
│   │           ├── showAdminMainPage.dart        ← Menu (updated)
│   │           └── subAdmin/
│   │               └── search_history_page.dart  ← Admin UI
│   │
│   └── shared/
│       └── widgets/
│           └── jobdisplay/
│               └── autocompletecustomer.dart     ← Search UI (updated)
│
└── core/
    └── services/
        └── search_history_service.dart            ← Local storage
```

## Technology Stack

| Layer | Technology |
|-------|-----------|
| **UI Framework** | Flutter |
| **Local Storage** | File (JSON) + path_provider |
| **Cloud Storage** | Firestore (NoSQL) |
| **Data Models** | Dart classes |
| **State Management** | StatefulWidget + setState |
| **Timestamps** | Firestore Timestamp + DateTime |

## Performance Considerations

- **Local Storage**: < 10 items, JSON file ~1KB
- **Firestore**: Unlimited documents (consider pagination)
- **Caching**: In-memory cache in SearchHistoryService
- **Network**: Async operations, doesn't block UI
- **Pagination**: 50 items per page by default

## Security Considerations

✅ Only saves on successful selection  
✅ Staff ID captured from empIdGlobal (no user input)  
✅ Admin-only view (isAdmin check)  
✅ No sensitive data exposure  
✅ Delete capability for cleanup  
✅ Firestore rules should restrict access  

## Scalability

- **Small scale**: Works perfectly for < 10k searches
- **Medium scale**: Consider pagination for > 50k searches
- **Large scale**: Add Firestore indexing and date range queries

---

This architecture provides a clean separation between local caching (for quick access) and cloud persistence (for audit trail), with a professional admin interface for viewing and managing the data.
