# Database Architecture - Complete Overview

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         FLUTTER APPLICATION                                 │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │                    FirebaseService (Central Hub)                     │  │
│  │                                                                      │  │
│  │  • primaryFirestore (default)                                       │  │
│  │  • secondaryFirestore (rider)                                       │  │
│  │  • forthFirestore (loyalty)                                         │  │
│  │  • jobsDoneFirestore                                                │  │
│  │  • gcashPendingDoneFirestore                                        │  │
│  │  • employeeFirestore                                                │  │
│  │  • suppliesFirestore                                                │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                    ┌───────────────┼───────────────┐
                    │               │               │
                    ▼               ▼               ▼
        ┌─────────────────┐ ┌──────────────┐ ┌──────────────┐
        │  Database       │ │  Database    │ │  Database    │
        │  Classes        │ │  Classes     │ │  Classes     │
        │                 │ │              │ │              │
        │ • JobsDone      │ │ • GCash      │ │ • Employee   │
        │ • Supplies      │ │ • Funds      │ │ • Loyalty    │
        │ • Employee      │ │              │ │              │
        └─────────────────┘ └──────────────┘ └──────────────┘
                    │               │               │
                    ▼               ▼               ▼
        ┌─────────────────┐ ┌──────────────┐ ┌──────────────┐
        │  UI/Display     │ │  UI/Display  │ │  UI/Display  │
        │  Layers         │ │  Layers      │ │  Layers      │
        │                 │ │              │ │              │
        │ • readData*     │ │ • readData*  │ │ • readData*  │
        │ • show*         │ │ • show*      │ │ • show*      │
        └─────────────────┘ └──────────────┘ └──────────────┘
```

---

## Firebase Projects & Collections

### 1. PRIMARY DATABASE (wash-ko-lang-sit)
**Purpose**: Main application data  
**Collections**:
- Jobs_queue
- Jobs_ongoing
- Jobs_completed
- EmployeeSetup
- ItemsHist
- det_items, det_items_hist
- fab_items, fab_items_hist
- other_items, other_items_hist
- users
- counters
- coverage_records

**Access**: `FirebaseService.primaryFirestore`

---

### 2. SECONDARY DATABASE (zpos-d985c)
**Purpose**: Rider data  
**Collections**: (Rider-specific)

**Access**: `FirebaseService.secondaryFirestore`

---

### 3. REPORTS DATABASE (splannofb)
**Purpose**: Analytics and reporting  
**Collections**: (Migrated from all other databases)
- Jobs_done (from jobsDoneDb)
- GCash_pending, GCash_done (from gcashPendingDoneDB)
- EmployeeCurr, EmployeeHist (from employeeDB)
- SuppliesCurr, SuppliesHist (from suppliesDB)
- loyalty (from loyaltyCardDb)
- [Other collections from primaryFirestore]

**Access**: Direct initialization in `migrateToThird.dart`

---

### 4. LOYALTY CARD DATABASE (signuptest-53277)
**Purpose**: Loyalty card collections  
**Collections**:
- loyalty

**Access**: `FirebaseService.forthFirestore`

**Database Classes**:
- All loyalty operations use `FirebaseService.forthFirestore`

**Files Using This Database**:
- `lib/features/pages/body/Loyalty/loyalty_single.dart`
- `lib/features/pages/body/Loyalty/loyalty.dart`
- `lib/core/utils/batch_fix_promo_counter.dart`
- `lib/core/utils/loyalty_count_validator.dart`

---

### 5. JOBS DONE DATABASE (fir-hosting-7fa46)
**Purpose**: Jobs_done collection (isolated)  
**Collections**:
- Jobs_done

**Access**: `FirebaseService.jobsDoneFirestore`

**Database Classes**:
- `DatabaseJobsDone`

**Files Using This Database**:
- `lib/core/services/database_jobs.dart`
- `lib/features/pages/body/JobsDone/readDataJobsDone.dart`
- `lib/features/pages/header/Admin/subAdmin/batch_promo_review_page.dart`
- `lib/features/pages/header/Admin/subAdmin/batch_remove_promo_disabled_days.dart`
- `lib/core/utils/batch_fix_promo_counter.dart`
- `lib/core/utils/loyalty_count_validator.dart`

---

### 6. GCASH PENDING/DONE DATABASE (gcashpendingdoneonly)
**Purpose**: GCash collections (isolated)  
**Collections**:
- GCash_pending
- GCash_done

**Access**: `FirebaseService.gcashPendingDoneFirestore`

**Database Classes**:
- `DatabaseGCashPending`
- `DatabaseGCashDone`

**Files Using This Database**:
- `lib/core/services/database_gcash.dart`
- `lib/features/pages/body/GCash/readDataGCashPending.dart`
- `lib/features/pages/body/GCash/readDataGCashDone.dart`

**Note**: Supplies recording uses separate `suppliesDB`

---

### 7. EMPLOYEE DATABASE (employeeonly-a70b8)
**Purpose**: Employee collections (isolated)  
**Collections**:
- EmployeeCurr
- EmployeeHist

**Access**: `FirebaseService.employeeFirestore`

**Database Classes**:
- `DatabaseEmployeeCurrent`
- `DatabaseEmployeeHist`

**Files Using This Database**:
- `lib/core/services/database_employee_current.dart`
- `lib/core/services/database_employee_hist.dart`
- `lib/features/pages/body/Employee/readDataEmployeeCurr.dart`
- `lib/features/pages/body/Employee/readDataEmployeeHist.dart`

---

### 8. SUPPLIES DATABASE (suppliesonly-6ec46)
**Purpose**: Supplies collections (isolated)  
**Collections**:
- SuppliesCurr
- SuppliesHist

**Access**: `FirebaseService.suppliesFirestore`

**Database Classes**:
- `DatabaseSuppliesCurrent`
- `DatabaseFundsHist`

**Files Using This Database**:
- `lib/core/services/database_supplies_current.dart`
- `lib/core/services/database_funds_history.dart`
- `lib/features/pages/body/Supplies/readDataSuppliesCurrent.dart`
- `lib/features/pages/body/Supplies/readSuppliesHist.dart`
- `lib/features/pages/body/GCash/readDataGCashPending.dart` (for Supplies recording)
- `lib/features/pages/header/Funds/showFundsInFundsOut.dart` (for Supplies recording)

---

## Data Flow Diagrams

### Write Operations

```
User Action
    │
    ▼
UI Component (show*.dart, readData*.dart)
    │
    ▼
Database Class (Database*.dart)
    │
    ▼
FirebaseService.xxxFirestore
    │
    ▼
Isolated Firebase Database
```

### Read Operations

```
UI Component (readData*.dart)
    │
    ▼
Database Class (Database*.dart)
    │
    ▼
FirebaseService.xxxFirestore
    │
    ▼
Isolated Firebase Database
    │
    ▼
Stream/Future
    │
    ▼
UI Display
```

### Migration Operations

```
Isolated Database
    │
    ├─ Jobs_done (jobsDoneDb)
    ├─ GCash_pending/done (gcashPendingDoneDB)
    ├─ EmployeeCurr/Hist (employeeDB)
    ├─ SuppliesCurr/Hist (suppliesDB)
    └─ loyalty (loyaltyCardDb)
    │
    ▼
migrateToThird.dart (_getSourceDb routing)
    │
    ▼
Reports Database (splannofb)
    │
    ▼
Analytics & Reporting
```

---

## Collection Routing Matrix

| Collection | Primary | Secondary | Loyalty | JobsDone | GCash | Employee | Supplies | Reports |
|-----------|---------|-----------|---------|----------|-------|----------|----------|---------|
| Jobs_queue | ✅ | | | | | | | |
| Jobs_ongoing | ✅ | | | | | | | |
| Jobs_completed | ✅ | | | | | | | |
| Jobs_done | | | | ✅ | | | | ✅ (migrated) |
| EmployeeSetup | ✅ | | | | | | | |
| EmployeeCurr | | | | | | ✅ | | ✅ (migrated) |
| EmployeeHist | | | | | | ✅ | | ✅ (migrated) |
| GCash_pending | | | | | ✅ | | | ✅ (migrated) |
| GCash_done | | | | | ✅ | | | ✅ (migrated) |
| SuppliesCurr | | | | | | | ✅ | ✅ (migrated) |
| SuppliesHist | | | | | | | ✅ | ✅ (migrated) |
| loyalty | | | ✅ | | | | | ✅ (migrated) |
| ItemsHist | ✅ | | | | | | | |
| det_items* | ✅ | | | | | | | |
| fab_items* | ✅ | | | | | | | |
| other_items* | ✅ | | | | | | | |
| users | ✅ | | | | | | | |
| counters | ✅ | | | | | | | |
| coverage_records | ✅ | | | | | | | |

---

## Initialization Sequence

```
1. app.dart: main()
   │
   ▼
2. FirebaseService.initialize()
   │
   ├─ Firebase.initializeApp() [Primary]
   ├─ Firebase.initializeApp(name: 'secondary', options: riderDb)
   ├─ Firebase.initializeApp(name: 'forth', options: loyaltyCardDb)
   ├─ Firebase.initializeApp(name: 'jobsDone', options: jobsDoneDb)
   ├─ Firebase.initializeApp(name: 'gcashPendingDone', options: gcashPendingDoneDB)
   ├─ Firebase.initializeApp(name: 'employee', options: employeeDB)
   └─ Firebase.initializeApp(name: 'supplies', options: suppliesDB)
   │
   ▼
3. All Firestore instances ready
   │
   ▼
4. Application starts
```

---

## Security Considerations

### Firestore Security Rules
Each database should have appropriate security rules:

```
Primary DB: Full access for authenticated users
Secondary DB: Rider-specific access
Reports DB: Read-only for analytics
Loyalty DB: Loyalty-specific access
JobsDone DB: Jobs_done collection access
GCash DB: GCash collection access
Employee DB: Employee collection access
Supplies DB: Supplies collection access
```

### Data Isolation
- Collections are isolated by database
- No cross-database queries
- Each database has independent security rules
- Separate authentication per database (if needed)

---

## Performance Optimization

### Indexing Strategy
- Create composite indexes for frequently queried fields
- Primary indexes on LogDate, ItemId, Status
- Secondary indexes on UserId, EmployeeId

### Pagination
- Implement pagination for large collections
- Use `limit()` and `startAfterDocument()`
- Batch operations in groups of 500

### Caching
- Implement local caching for frequently accessed data
- Use Firestore offline persistence
- Cache analytics data in Reports DB

---

## Monitoring & Maintenance

### Quota Monitoring
- Monitor read/write operations per database
- Track storage usage
- Alert on quota approaching limits

### Performance Monitoring
- Track query latency
- Monitor index usage
- Identify slow queries

### Data Integrity
- Regular backups of all databases
- Verify data consistency across databases
- Test migration procedures

---

## Future Scalability

### Adding New Databases
1. Add credentials to `firebase_options.dart`
2. Initialize in `FirebaseService.initialize()`
3. Create database class
4. Update migration routing
5. Update UI components

### Sharding Strategy
- Consider sharding large collections
- Implement collection-level sharding
- Use document IDs for distribution

### Replication
- Implement cross-region replication
- Set up backup databases
- Implement failover procedures

---

**Last Updated**: April 25, 2026  
**Status**: ✅ Complete and Verified
