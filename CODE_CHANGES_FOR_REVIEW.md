# Code Changes for Review

## Summary
- 8 files total
- 8 code additions
- Phase 3 (database fix): 1 file
- Phase 1 (payment tracking): 6 files
- Phase 2 (daily cash total): 1 file

---

## PHASE 3: Database Query Fix

### File: `lib/core/services/database_supplies_current.dart`

**Function**: `computeCurrentStocks()`
**Line**: ~30

### BEFORE
```dart
Future<SuppliesModelHist> computeCurrentStocks(SuppliesModelHist sMH) async {
  final snap = await FirebaseService.suppliesFirestore
      .collection('SuppliesCurr')
      .where('ItemId', isEqualTo: sMH.itemId)
      .get()
      .withFsTimeout();
  for (var doc in snap.docs) {
    sMH.currentStocks = doc['CurrentStocks'];
    sMH.countId = doc['CountId'] + 1;
    sMH.docId = doc['DocId'];
    break;
  }
  return sMH;
}
```

### AFTER
```dart
Future<SuppliesModelHist> computeCurrentStocks(SuppliesModelHist sMH) async {
  final snap = await FirebaseService.suppliesFirestore
      .collection('SuppliesCurr')
      .where('ItemUniqueId', isEqualTo: sMH.itemUniqueId)
      .get()
      .withFsTimeout();
  for (var doc in snap.docs) {
    sMH.currentStocks = doc['CurrentStocks'];
    sMH.countId = doc['CountId'] + 1;
    sMH.docId = doc['DocId'];
    break;
  }
  return sMH;
}
```

**Change**: Line 30 - `ItemId` → `ItemUniqueId`

---

## PHASE 1: Payment Tracking (paidCashAmountPrev)

### File 1: `lib/features/pages/body/JobsOnQueue/showPaidUnpaid.dart`

**Location**: After paidCashAmount is set

### BEFORE
```dart
jobRepo.paidCashAmount = int.tryParse(customerAmountVar.text.replaceAll(',', '')) ?? 0;
jobRepo.paymentReceivedBy = empIdGlobal;
```

### AFTER
```dart
jobRepo.paidCashAmount = int.tryParse(customerAmountVar.text.replaceAll(',', '')) ?? 0;
jobRepo.paymentReceivedBy = empIdGlobal;
jobRepo.paidCashAmountPrev = previousPaidCash;
```

**Add**: `jobRepo.paidCashAmountPrev = previousPaidCash;`

---

### File 2: `lib/features/pages/body/JobsDone/showDeliverOrCustomerPickup.dart`

**Location**: After paidCashAmount is set

### BEFORE
```dart
jobRepo.paidCashAmount = int.tryParse(customerAmountVar.text.replaceAll(',', '')) ?? 0;
jobRepo.paymentReceivedBy = empIdGlobal;
```

### AFTER
```dart
jobRepo.paidCashAmount = int.tryParse(customerAmountVar.text.replaceAll(',', '')) ?? 0;
jobRepo.paymentReceivedBy = empIdGlobal;
jobRepo.paidCashAmountPrev = previousPaidCash;
```

**Add**: `jobRepo.paidCashAmountPrev = previousPaidCash;`

---

### File 3: `lib/features/pages/body/JobsDone/showDeliverOrCustomerPickupPaidUnpaid.dart`

**Location**: After paidCashAmount is set

### BEFORE
```dart
jobRepo.paidCashAmount = int.tryParse(customerAmountVar.text.replaceAll(',', '')) ?? 0;
jobRepo.paymentReceivedBy = empIdGlobal;
```

### AFTER
```dart
jobRepo.paidCashAmount = int.tryParse(customerAmountVar.text.replaceAll(',', '')) ?? 0;
jobRepo.paymentReceivedBy = empIdGlobal;
jobRepo.paidCashAmountPrev = previousPaidCash;
```

**Add**: `jobRepo.paidCashAmountPrev = previousPaidCash;`

---

### File 4: `lib/features/pages/header/JobOnQueue/showJobOnQueue.dart`

**Location**: After paidCashAmount is set

### BEFORE
```dart
jobRepo.paidCashAmount = int.tryParse(customerAmountVar.text.replaceAll(',', '')) ?? 0;
jobRepo.paymentReceivedBy = empIdGlobal;
```

### AFTER
```dart
jobRepo.paidCashAmount = int.tryParse(customerAmountVar.text.replaceAll(',', '')) ?? 0;
jobRepo.paymentReceivedBy = empIdGlobal;
jobRepo.paidCashAmountPrev = previousPaidCash;
```

**Add**: `jobRepo.paidCashAmountPrev = previousPaidCash;`

---

### File 5: `lib/features/pages/header/Funds/showLaundryPayment.dart`

**Location**: After paidCashAmount is set

### BEFORE
```dart
jobRepo.paidCashAmount = int.tryParse(customerAmountVar.text.replaceAll(',', '')) ?? 0;
jobRepo.paymentReceivedBy = empIdGlobal;
```

### AFTER
```dart
jobRepo.paidCashAmount = int.tryParse(customerAmountVar.text.replaceAll(',', '')) ?? 0;
jobRepo.paymentReceivedBy = empIdGlobal;
jobRepo.paidCashAmountPrev = previousPaidCash;
```

**Add**: `jobRepo.paidCashAmountPrev = previousPaidCash;`

---

### File 6: `lib/features/pages/header/GCash/showGCashPending.dart`

**Location**: After paidCashAmount is set

### BEFORE
```dart
jobRepo.paidCashAmount = int.tryParse(customerAmountVar.text.replaceAll(',', '')) ?? 0;
jobRepo.paymentReceivedBy = empIdGlobal;
```

### AFTER
```dart
jobRepo.paidCashAmount = int.tryParse(customerAmountVar.text.replaceAll(',', '')) ?? 0;
jobRepo.paymentReceivedBy = empIdGlobal;
jobRepo.paidCashAmountPrev = previousPaidCash;
```

**Add**: `jobRepo.paidCashAmountPrev = previousPaidCash;`

---

## PHASE 2: Daily Cash Total (T*9999)

### File: `lib/features/pages/header/Funds/showFundCheck.dart`

**Function**: `buildSelectedMoneyText()`
**Location**: Before return statement

### BEFORE
```dart
String buildSelectedMoneyText() {
  final List<String> parts = [];

  String formatDenom(int denom) {
    if (denom >= 1000) {
      return '${denom ~/ 1000}k';
    } else if (denom >= 100) {
      return '${denom ~/ 100}h';
    } else {
      return denom.toString();
    }
  }

  qtyMap.forEach((denom, qty) {
    if (qty > 0) {
      parts.add('${formatDenom(denom)}*$qty');
    }
  });

  // Add job status counts
  if (intJobsDoneDefault > 0) {
    parts.add('D*$intJobsDoneDefault');
  }
  if (intJobsDoneClothesHere > 0) {
    parts.add('C*$intJobsDoneClothesHere');
  }
  if (intJobsDoneClothesGoneGCash > 0) {
    parts.add('GC*$intJobsDoneClothesGoneGCash');
  }
  if (intJobsDoneClothesGoneCash > 0) {
    parts.add('G*$intJobsDoneClothesGoneCash');
  }
  if (intJobsDoneAdminRequest > 0) {
    parts.add('A*$intJobsDoneAdminRequest');
  }

  // Build final string
  String moneyText = '';
  List<String> moneyDenom = [];
  List<String> jobStatus = [];

  for (var part in parts) {
    if (part.startsWith('D*') ||
        part.startsWith('C*') ||
        part.startsWith('GC*') ||
        part.startsWith('G*') ||
        part.startsWith('A*')) {
      jobStatus.add(part);
    } else {
      moneyDenom.add(part);
    }
  }

  moneyText = moneyDenom.join(',');
  if (jobStatus.isNotEmpty) {
    moneyText += ' ' + jobStatus.join(',');
  }

  return moneyText;
}
```

### AFTER
```dart
String buildSelectedMoneyText() {
  final List<String> parts = [];

  String formatDenom(int denom) {
    if (denom >= 1000) {
      return '${denom ~/ 1000}k';
    } else if (denom >= 100) {
      return '${denom ~/ 100}h';
    } else {
      return denom.toString();
    }
  }

  qtyMap.forEach((denom, qty) {
    if (qty > 0) {
      parts.add('${formatDenom(denom)}*$qty');
    }
  });

  // Add job status counts
  if (intJobsDoneDefault > 0) {
    parts.add('D*$intJobsDoneDefault');
  }
  if (intJobsDoneClothesHere > 0) {
    parts.add('C*$intJobsDoneClothesHere');
  }
  if (intJobsDoneClothesGoneGCash > 0) {
    parts.add('GC*$intJobsDoneClothesGoneGCash');
  }
  if (intJobsDoneClothesGoneCash > 0) {
    parts.add('G*$intJobsDoneClothesGoneCash');
  }
  if (intJobsDoneAdminRequest > 0) {
    parts.add('A*$intJobsDoneAdminRequest');
  }

  // Build final string
  String moneyText = '';
  List<String> moneyDenom = [];
  List<String> jobStatus = [];

  for (var part in parts) {
    if (part.startsWith('D*') ||
        part.startsWith('C*') ||
        part.startsWith('GC*') ||
        part.startsWith('G*') ||
        part.startsWith('A*')) {
      jobStatus.add(part);
    } else {
      moneyDenom.add(part);
    }
  }

  moneyText = moneyDenom.join(',');
  if (jobStatus.isNotEmpty) {
    moneyText += ' ' + jobStatus.join(',');
  }
  moneyText += ' T*$grandTotal';

  return moneyText;
}
```

**Add**: `moneyText += ' T*$grandTotal';` (line before return)

---

## Summary of Changes

| Phase | Files | Changes | Status |
|-------|-------|---------|--------|
| Phase 3 | 1 | 1 line | For Review |
| Phase 1 | 6 | 6 lines | For Review |
| Phase 2 | 1 | 1 line | For Review |
| **Total** | **8** | **8 lines** | **For Review** |

All changes are single-line additions with no breaking changes.
