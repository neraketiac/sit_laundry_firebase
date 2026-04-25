# Database Migration - Quick Reference Guide

## How to Access Each Collection

### Jobs_done Collection
```dart
// Read/Write
import 'package:laundry_firebase/core/services/database_jobs.dart';

final db = DatabaseJobsDone();
final docs = await db.fetchPaginated();
```

### GCash Collections (GCash_pending, GCash_done)
```dart
// Read/Write
import 'package:laundry_firebase/core/services/database_gcash.dart';

final dbPending = DatabaseGCashPending();
final dbDone = DatabaseGCashDone();

// Note: Supplies recording uses separate database
import 'package:laundry_firebase/core/services/database_supplies_current.dart';
```

### Employee Collections (EmployeeCurr, EmployeeHist)
```dart
// Read/Write
import 'package:laundry_firebase/core/services/database_employee_current.dart';
import 'package:laundry_firebase/core/services/database_employee_hist.dart';

final dbCurr = DatabaseEmployeeCurrent();
final dbHist = DatabaseEmployeeHist();
```

### Supplies Collections (SuppliesCurr, SuppliesHist)
```dart
// Read/Write
import 'package:laundry_firebase/core/services/database_supplies_current.dart';
import 'package:laundry_firebase/core/services/database_funds_history.dart';

final dbCurr = DatabaseSuppliesCurrent();
final dbHist = DatabaseFundsHist();
```

### Loyalty Collections
```dart
// Read/Write - Use loyaltyCardDb
import 'package:laundry_firebase/core/services/firebase_service.dart';

final loyaltyFirestore = FirebaseFirestore.instanceFor(
  app: Firebase.app('forth'),
);

final snap = await loyaltyFirestore.collection('loyalty').get();
```

---

## Database Instances Available

```dart
import 'package:laundry_firebase/core/services/firebase_service.dart';

// Primary Database (default)
FirebaseService.primaryFirestore

// Secondary Database (Rider)
FirebaseService.secondaryFirestore

// Forth Database (Loyalty)
FirebaseService.forthFirestore

// Jobs Done Database
FirebaseService.jobsDoneFirestore

// GCash Pending/Done Database
FirebaseService.gcashPendingDoneFirestore

// Employee Database
FirebaseService.employeeFirestore

// Supplies Database
FirebaseService.suppliesFirestore
```

---

## Migration to Reports DB

To migrate collections to the reports database:

1. Open Admin → Migrate to Third DB
2. Select collections to migrate
3. Optionally check "Delete destination before migrating"
4. Click "Migrate Selected"

The migration automatically routes collections to their correct source databases:
- Jobs_done → from jobsDoneDb
- GCash_pending/done → from gcashPendingDoneDB
- EmployeeCurr/Hist → from employeeDB
- SuppliesCurr/Hist → from suppliesDB
- Other collections → from primaryFirestore

---

## Adding a New Isolated Database

To add a new isolated database:

1. **Add Firebase credentials** to `lib/firebase_options.dart`:
   ```dart
   static const FirebaseOptions newDb = FirebaseOptions(
     apiKey: "...",
     appId: "...",
     // ... other fields
   );
   ```

2. **Initialize in FirebaseService**:
   ```dart
   static late FirebaseApp newApp;
   static late FirebaseFirestore newFirestore;
   
   // In initialize() method:
   newApp = await Firebase.initializeApp(
     name: 'newDb',
     options: DefaultFirebaseOptions.newDb,
   );
   newFirestore = FirebaseFirestore.instanceFor(app: newApp);
   ```

3. **Update database classes** to use `FirebaseService.newFirestore`

4. **Update migration routing** in `migrateToThird.dart`:
   ```dart
   FirebaseFirestore _getSourceDb(String collection, FirebaseFirestore main) {
     if (collection == 'NewCollection') {
       return FirebaseService.newFirestore;
     }
     // ... other cases
   }
   ```

---

## Common Patterns

### Reading from a Collection
```dart
// Using database class
final db = DatabaseSuppliesCurrent();
final stream = db.getSuppliesCurrent();

// Direct Firestore access
final docs = await FirebaseService.suppliesFirestore
    .collection('SuppliesCurr')
    .get();
```

### Writing to a Collection
```dart
// Using database class
final db = DatabaseSuppliesCurrent();
await db.addSuppliesCurr(model);

// Direct Firestore access
await FirebaseService.suppliesFirestore
    .collection('SuppliesCurr')
    .add(data);
```

### Listening to Changes
```dart
// Using database class
final db = DatabaseFundsHist();
final stream = db.getSuppliesHistory(false);

// Direct Firestore access
FirebaseService.suppliesFirestore
    .collection('SuppliesHist')
    .orderBy('LogDate', descending: true)
    .snapshots()
    .listen((snapshot) {
      // Handle changes
    });
```

---

## Troubleshooting

### "Missing or insufficient permissions" Error
- Check Firestore security rules in Firebase Console
- Ensure the database has proper rules configured
- Verify the app has access to the database

### Collection Not Found
- Verify the collection exists in the target database
- Check the collection name spelling
- Use Firebase Console to browse collections

### Data Not Appearing
- Verify data was written to the correct database
- Check Firestore security rules
- Ensure the app is reading from the correct database instance

### Slow Performance
- Check if composite indexes are created
- Monitor database quota usage
- Consider pagination for large datasets

---

## Database Credentials

All database credentials are stored in `lib/firebase_options.dart`:

| Database | Project ID | Purpose |
|----------|-----------|---------|
| Primary | wash-ko-lang-sit | Main application |
| Secondary | zpos-d985c | Rider data |
| Reports | splannofb | Analytics |
| Loyalty | signuptest-53277 | Loyalty cards |
| Jobs Done | fir-hosting-7fa46 | Jobs_done collection |
| GCash | gcashpendingdoneonly | GCash collections |
| Employee | employeeonly-a70b8 | Employee collections |
| Supplies | suppliesonly-6ec46 | Supplies collections |

---

## Files to Know

- `lib/core/services/firebase_service.dart` - Central Firebase initialization
- `lib/firebase_options.dart` - Database credentials
- `lib/features/pages/header/Admin/subAdmin/migrateToThird.dart` - Migration UI
- `lib/core/services/database_*.dart` - Database access classes
- `lib/features/pages/body/*/readData*.dart` - UI display files

---

## Best Practices

1. **Always use database classes** instead of direct Firestore access when available
2. **Don't mix databases** within a collection's operations
3. **Use FirebaseService static instances** for consistency
4. **Test migrations** before running in production
5. **Monitor quota usage** across all databases
6. **Keep security rules** synchronized across databases
7. **Document any new database additions** in this guide

---

**Last Updated**: April 25, 2026
