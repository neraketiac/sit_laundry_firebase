# Supplies Collections Access Summary

## Collections Overview

### **SuppliesCurr** (Current Supplies/Funds Data)
- **Database**: primaryFirestore (main)
- **Reference**: `SUPPLIES_CURR_REF = "SuppliesCurr"`
- **Service Class**: `DatabaseSuppliesCurrent`
- **Purpose**: Tracks current balance/stock of supplies, funds, items

### **SuppliesHist** (Supplies/Funds History/Transactions)
- **Database**: primaryFirestore (main)
- **Reference**: `FUNDS_HIS_REF = "SuppliesHist"` (note: named FUNDS_HIS_REF but references SuppliesHist)
- **Service Class**: `DatabaseFundsHist`
- **Purpose**: Tracks all historical transactions of supplies, funds, items

---

## Files That Access These Collections

### 1. **UI Display Pages**

#### `lib/features/pages/body/Supplies/readSuppliesCurrent.dart`
- **Purpose**: Display current supplies/funds data
- **Collections Used**: SuppliesCurr
- **Operations**: READ (streaming)
- **Database**: primaryFirestore
- **Key Methods**:
  - `DatabaseSuppliesCurrent.getSuppliesCurrent()` - streams all current supplies
  - Displays item names, current stocks, balances
  - Shows dark mode support

#### `lib/features/pages/body/Supplies/readSuppliesHist.dart`
- **Purpose**: Display supplies/funds transaction history with pagination
- **Collections Used**: SuppliesHist
- **Operations**: READ (streaming + pagination)
- **Database**: primaryFirestore
- **Key Methods**:
  - `DatabaseFundsHist.getSuppliesHistory()` - live stream
  - `DatabaseFundsHist.getSuppliesHistoryPaginated()` - paginated queries
  - Loads 50 records per page
  - Live listener for real-time updates

#### `lib/features/pages/body/main_laundry_body.dart`
- **Purpose**: Main body page that displays both supplies widgets
- **Collections Used**: SuppliesCurr, SuppliesHist
- **Operations**: DISPLAY (calls both readDataSuppliesCurrent and readDataSuppliesHist)
- **Database**: primaryFirestore

---

### 2. **Database Service Classes**

#### `lib/core/services/database_supplies_current.dart`
- **Class**: `DatabaseSuppliesCurrent`
- **Collection**: SuppliesCurr
- **Database**: primaryFirestore
- **Operations**:
  - `getSuppliesCurrent()` - Stream all current supplies
  - `computeCurrentStocks()` - Calculate current balance
  - `addSuppliesCurr()` - Add/update supplies current record
  - `addItemsCurr()` - Add items current record

#### `lib/core/services/database_funds_history.dart`
- **Class**: `DatabaseFundsHist`
- **Collection**: SuppliesHist
- **Database**: primaryFirestore
- **Operations**:
  - `getSuppliesHistory()` - Stream supplies history
  - `getSuppliesHistoryPaginated()` - Paginated query for history
  - `addSuppliesHist()` - Add supplies history record

---

### 3. **Shared Methods & Repositories**

#### `lib/core/utils/sharedmethodsdatabase.dart`
- **Purpose**: Shared database operations
- **Collections Used**: SuppliesCurr, SuppliesHist
- **Operations**: INSERT
- **Database**: primaryFirestore
- **Key Functions**:
  - `callDatabaseSuppliesCurrentAdd()` - Main function to add supplies records
  - Handles both SuppliesCurr and SuppliesHist insertion
  - Applies negation for Cash-Out and Funds-Out
  - Calls `DatabaseSuppliesCurrent.addSuppliesCurr()`

#### `lib/core/utils/sharedMethods.dart`
- **Purpose**: Shared utility methods
- **Collections Used**: SuppliesCurr, SuppliesHist (via repository)
- **Operations**: SETUP/PREPARE
- **Key Functions**:
  - `setSuppliesRepository()` - Prepares supplies data before insertion
  - `recordCashPaymentToSupplies()` - Records cash payment delta
  - `revertLaundryPaymentSuppliesHistory()` - Reverts laundry payment
  - Uses `SuppliesHistRepository` to prepare data

#### `lib/features/items/repository/supplies_hist_repository.dart`
- **Class**: `SuppliesHistRepository` (singleton)
- **Purpose**: Repository pattern for supplies data
- **Operations**: PREPARE/STAGE data before database insertion
- **Database**: N/A (in-memory staging)

---

### 4. **Feature Pages Using Supplies**

#### `lib/features/pages/header/Items/showItemsInOut.dart`
- **Purpose**: Add items in/out
- **Collections Used**: SuppliesCurr
- **Operations**: INSERT
- **Database**: primaryFirestore
- **Key Method**:
  - `DatabaseSuppliesCurrent().addItemsCurr()` - Add items current record

#### `lib/features/pages/body/GCash/readDataGCashPending.dart`
- **Purpose**: Generate supplies records for GCash Cash-Out
- **Collections Used**: SuppliesCurr, SuppliesHist
- **Operations**: INSERT
- **Database**: primaryFirestore
- **Key Function**:
  - `_generateCashOutSuppliesRecords()` - Creates supplies records when GCash Cash-Out completes
  - Uses `SuppliesHistRepository` to prepare data
  - Calls `callDatabaseSuppliesCurrentAdd()`

#### `lib/features/pages/header/Funds/showFundsInFundsOut.dart`
- **Purpose**: Add funds in/out
- **Collections Used**: SuppliesCurr, SuppliesHist
- **Operations**: INSERT
- **Database**: primaryFirestore
- **Key Function**:
  - Uses `SuppliesHistRepository` to prepare data
  - Calls `callDatabaseSuppliesCurrentAdd()`

#### `lib/shared/widgets/jobdisplay/autocompletecustomer.dart`
- **Purpose**: Auto-complete customer selection
- **Collections Used**: SuppliesHist (via repository)
- **Operations**: SETUP
- **Database**: N/A (staging only)

---

### 5. **Admin/Analytics Pages**

#### `lib/features/pages/header/Admin/reports/monthly_analytics/monthly_analytics_page.dart`
- **Purpose**: Monthly analytics dashboard
- **Collections Used**: SuppliesHist
- **Operations**: READ
- **Database**: reportsDb (reads from reports database, not primary)
- **Key Method**:
  - Queries SuppliesHist from reportsDb for analytics

#### `lib/features/pages/header/Admin/subAdmin/monthlyAnalytics.dart`
- **Purpose**: Monthly analytics (alternative view)
- **Collections Used**: SuppliesHist
- **Operations**: READ
- **Database**: reportsDb (reads from reports database, not primary)

---

### 6. **Migration**

#### `lib/features/pages/header/Admin/subAdmin/migrateToThird.dart`
- **Purpose**: Migrate collections to reports database
- **Collections Included**: SuppliesCurr, SuppliesHist
- **Source Database**: primaryFirestore
- **Destination Database**: reportsDb (thirdWeb)
- **Operations**: Full collection migration with optional delete-first option

---

## Access Pattern Summary

```
┌─────────────────────────────────────────────────────────────┐
│                    PRIMARY FIRESTORE                         │
│                                                              │
│  ┌──────────────────┐         ┌──────────────────┐          │
│  │  SuppliesCurr    │         │  SuppliesHist    │          │
│  └────────┬─────────┘         └────────┬─────────┘          │
│           │                            │                    │
│  ┌────────▼──────────────────────────────▼────────┐         │
│  │  DatabaseSuppliesCurrent                       │         │
│  │  DatabaseFundsHist                             │         │
│  └────────┬──────────────────────────────┬────────┘         │
│           │                              │                  │
│  ┌────────▼──────────────┐      ┌────────▼──────────────┐   │
│  │readDataSuppliesCurr   │      │readDataSuppliesHist   │   │
│  │.dart                  │      │.dart                  │   │
│  └────────┬──────────────┘      └────────┬──────────────┘   │
│           │                              │                  │
│  ┌────────▼──────────────────────────────▼────────┐         │
│  │  main_laundry_body.dart (Display)              │         │
│  └──────────────────────────────────────────────────┘       │
│                                                              │
│  ┌──────────────────────────────────────────────────┐       │
│  │  sharedmethodsdatabase.dart (Insert)            │       │
│  │  sharedMethods.dart (Setup/Prepare)             │       │
│  │  SuppliesHistRepository (Staging)               │       │
│  └──────────────────────────────────────────────────┘       │
│                                                              │
│  ┌──────────────────────────────────────────────────┐       │
│  │  showItemsInOut.dart (Insert Items)             │       │
│  │  readDataGCashPending.dart (Insert GCash)       │       │
│  │  showFundsInFundsOut.dart (Insert Funds)        │       │
│  └──────────────────────────────────────────────────┘       │
│                                                              │
│  ┌──────────────────────────────────────────────────┐       │
│  │  migrateToThird.dart (Migrate to reportsDb)     │       │
│  └──────────────────────────────────────────────────┘       │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    REPORTS DATABASE                          │
│                                                              │
│  ┌──────────────────┐         ┌──────────────────┐          │
│  │  SuppliesCurr    │         │  SuppliesHist    │          │
│  │  (migrated)      │         │  (migrated)      │          │
│  └────────┬─────────┘         └────────┬─────────┘          │
│           │                            │                    │
│  ┌────────▼──────────────────────────────▼────────┐         │
│  │  monthly_analytics_page.dart (Read)            │         │
│  │  monthlyAnalytics.dart (Read)                  │         │
│  └──────────────────────────────────────────────────┘       │
└─────────────────────────────────────────────────────────────┘
```

---

## Current Database Location

| Collection | Database | Status |
|-----------|----------|--------|
| SuppliesCurr | primaryFirestore | ✅ Active |
| SuppliesHist | primaryFirestore | ✅ Active |

---

## Access Summary Table

| File | Collection | Operation | Database | Purpose |
|------|-----------|-----------|----------|---------|
| readSuppliesCurrent.dart | SuppliesCurr | READ | primaryFirestore | Display current supplies |
| readSuppliesHist.dart | SuppliesHist | READ | primaryFirestore | Display supplies history |
| main_laundry_body.dart | Both | DISPLAY | primaryFirestore | Main UI page |
| database_supplies_current.dart | SuppliesCurr | CRUD | primaryFirestore | Service layer |
| database_funds_history.dart | SuppliesHist | READ/INSERT | primaryFirestore | Service layer |
| sharedmethodsdatabase.dart | Both | INSERT | primaryFirestore | Shared operations |
| sharedMethods.dart | Both | SETUP | primaryFirestore | Utility methods |
| supplies_hist_repository.dart | Both | STAGE | N/A | Data staging |
| showItemsInOut.dart | SuppliesCurr | INSERT | primaryFirestore | Add items |
| readDataGCashPending.dart | Both | INSERT | primaryFirestore | GCash Cash-Out |
| showFundsInFundsOut.dart | Both | INSERT | primaryFirestore | Add funds |
| monthly_analytics_page.dart | SuppliesHist | READ | reportsDb | Analytics |
| monthlyAnalytics.dart | SuppliesHist | READ | reportsDb | Analytics |
| migrateToThird.dart | Both | MIGRATE | primaryFirestore → reportsDb | Migration tool |

---

## Notes

- Both collections are currently on **primaryFirestore**
- No separation to different databases yet (unlike GCash, Jobs_done, Loyalty, Employee)
- Supplies data is heavily used for:
  - Tracking funds in/out
  - Tracking items in/out
  - Tracking cash payments
  - Analytics and reporting
- SuppliesHist is also read from **reportsDb** for analytics purposes
- Both collections are included in migration to reports database
- `SuppliesHistRepository` is a singleton that stages data in memory before database insertion
