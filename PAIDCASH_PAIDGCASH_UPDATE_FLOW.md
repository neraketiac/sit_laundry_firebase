# paidCash and paidGCash Update Flow

## Summary
`paidCash` and `paidGCash` are payment status fields that track whether a job has been paid via cash or GCash. These fields are updated through various UI dialogs and saved to the database.

---

## Direct Update Methods (Where paidCash and paidGCash are SET)

### 1. **showPaidUnpaid()** ⭐ PRIMARY
**File:** `lib/features/pages/body/JobsOnQueue/showPaidUnpaid.dart`
- **Purpose:** Main dialog for updating payment status (Cash/GCash/Split payment)
- **Called from:** `visPaidUnpaidArea.dart` (Edit Payment Status button)
- **Updates:**
  - `jobRepo.selectedPaidCash` (toggle)
  - `jobRepo.selectedPaidGCash` (toggle)
  - `jobRepo.selectedPaidCashAmount` (input field)
  - `jobRepo.selectedPaidGCashAmount` (input field)
  - `jobRepo.selectedPaidGCashVerified` (switch - admin only)
- **Saves to DB:** Calls `callDatabaseUpdateJob()` after syncing

### 2. **showOnGoingStatus()** 
**File:** `lib/features/pages/body/JobsOnGoing/showOnGoingStatus.dart`
- **Purpose:** Update job status while job is being processed
- **Updates:** Via `syncSelectedToRepoMin()` which includes payment fields
- **Saves to DB:** Calls `callDatabaseUpdateJob()`

### 3. **showDeliverOrCustomerPickup()** 
**File:** `lib/features/pages/body/JobsDone/showDeliverOrCustomerPickup.dart`
- **Purpose:** Mark job as delivered/picked up, finalize payment
- **Auto-sets:** `jobRepo.paidCash = true` if cash amount > 0
- **Saves to DB:** Calls `callDatabaseUpdateJob()`

### 4. **showDeliverOrCustomerPickupPaidUnpaid()** 
**File:** `lib/features/pages/body/JobsDone/showDeliverOrCustomerPickupPaidUnpaid.dart`
- **Purpose:** Variant for jobs with paid/unpaid status
- **Auto-sets:** `jobRepo.paidCash = true` if cash amount > 0
- **Saves to DB:** Calls `callDatabaseUpdateJob()`

### 5. **showJobOnQueue()**
**File:** `lib/features/pages/header/JobOnQueue/showJobOnQueue.dart`
- **Purpose:** Queue job view with payment handling
- **Saves to DB:** Calls `callDatabaseUpdateJob()`

### 6. **showJobOnQueueEdit()**
**File:** `lib/features/pages/body/JobsOnQueue/showJobOnQueueEdit.dart`
- **Purpose:** Edit job details from queue
- **Updates:** Via `syncSelectedToRepoAll()` which includes payment fields
- **Saves to DB:** Calls `callDatabaseUpdateJob()`

### 7. **showAdminJob()**
**File:** `lib/features/pages/header/Admin/subAdmin/showAdminJob.dart`
- **Purpose:** Admin-only job editing
- **Direct Sets:**
  ```dart
  jobRepo.paidCash = jobRepo.selectedPaidCash
  jobRepo.paidGCash = jobRepo.selectedPaidGCash
  jobRepo.paidGCashVerified = jobRepo.selectedPaidGCashVerified
  jobRepo.paidCashAmount = jobRepo.selectedPaidCashAmount
  jobRepo.paidGCashAmount = jobRepo.selectedPaidGCashAmount
  ```
- **Saves to DB:** Calls `callDatabaseUpdateJob()`

---

## Sync Methods (Transfer from "selected" to "repo")

### **syncSelectedToRepoAll()**
**File:** `lib/features/jobs/repository/jobmodel_repository.dart`
- **Purpose:** Syncs ALL selected fields to the job repo (full update)
- **Syncs:**
  ```dart
  jobRepo.paidCash = selectedPaidCash
  jobRepo.paidGCash = selectedPaidGCash
  jobRepo.paidGCashVerified = selectedPaidGCashVerified
  jobRepo.paidCashAmount = selectedPaidCashAmount
  jobRepo.paidGCashAmount = selectedPaidGCashAmount
  ```
- **Called from:**
  - `showJobOnQueueEdit()` - Edit queue job
  - Potentially other full-update dialogs

### **syncSelectedToRepoMin()**
**File:** `lib/features/jobs/repository/jobmodel_repository.dart`
- **Purpose:** Syncs ONLY payment-related and minimal fields (targeted update)
- **Syncs Payment:**
  ```dart
  jobRepo.paidCash = selectedPaidCash
  jobRepo.paidGCash = selectedPaidGCash
  jobRepo.paidGCashVerified = selectedPaidGCashVerified
  jobRepo.paidCashAmount = selectedPaidCashAmount
  jobRepo.paidGCashAmount = selectedPaidGCashAmount
  ```
- **Logic:** Calculates `selectedUnpaid` based on payment amounts
  - Unpaid = false if: cash amount >= final price OR (gcash verified + amount >= final price)
- **Called from:**
  - `showOnGoingStatus()` - Minimal status update
  - `showPaidUnpaid()` - After dialog closes

---

## Database Save Flow

```
User clicks "Update Payment" in Dialog
        ↓
Dialog updates: selectedPaidCash, selectedPaidGCash, amounts
        ↓
User clicks "Save"
        ↓
syncSelectedToRepoMin() OR syncSelectedToRepoAll()
        ↓
Transfers selected fields → jobRepo fields
        ↓
callDatabaseUpdateJob(context, jobRepo.getJobsModel())
        ↓
Determines which collection to update:
  - 'completed' → DatabaseJobsCompleted.update()
  - 'done' → DatabaseJobsDone.update()
  - 'waiting'/'washing'/'drying'/'folding' → DatabaseJobsOngoing.update()
  - else → DatabaseJobsQueue.update()
        ↓
Database.update() calls: await _ref.doc(docId).update(jM.toJson())
        ↓
JobModel.toJson() includes:
  - P01_PaidCash: paidCash
  - P02_PaidGCash: paidGCash
  - P03_PaidCashAmount: paidCashAmount
  - P04_PaidGCashAmount: paidGCashAmount
  - P05_PaidGCashVerified: paidGCashverified
```

---

## UI Components

### **visPaidUnpaid.dart** (Main Payment Dialog UI)
**Location:** `lib/shared/widgets/jobdisplay/use_to_alter_job/visPaidUnpaid.dart`
- Displays cash/GCash toggle buttons
- Shows amount input fields
- Includes GCash receipt image upload
- GCash verification switch (admin only)
- Returns payment status string: "Paid Cash", "Paid GCash", "Split payment", etc.

### **visPaidUnpaidArea.dart** (Edit Payment Status Button)
**Location:** `lib/shared/widgets/jobdisplay/use_to_alter_job/visPaidUnpaidArea.dart`
- Shows current payment status display
- "Edit Payment Status" button → calls `showPaidUnpaid()`
- Permission checks (non-admin can't revert saved cash payment)

---

## Permission/Validation Rules

From `visPaidUnpaid.dart`:

```dart
// Non-admin cannot remove already-saved cash payment
if (!isAdmin && !jobRepo.unpaid && jobRepo.paidCash) {
  return; // Show error, block toggle
}

// Non-admin cannot revert paid GCash to unpaid (if not split)
if (!isAdmin && jobRepo.selectedPaidGCash && 
    !jobRepo.selectedPaidCash && !jobRepo.unpaid) {
  return; // Show error, block toggle
}
```

---

## Field Mapping (Firestore)

| Model Field | Firestore Field | Description |
|---|---|---|
| `paidCash` | `P01_PaidCash` | Whether paid via cash |
| `paidGCash` | `P02_PaidGCash` | Whether paid via GCash |
| `paidCashAmount` | `P03_PaidCashAmount` | Cash payment amount |
| `paidGCashAmount` | `P04_PaidGCashAmount` | GCash payment amount |
| `paidGCashverified` | `P05_PaidGCashVerified` | GCash payment verified by admin |
| `unpaid` | `P00_UnpaidFlag` | Whether job still has unpaid balance |

---

## Summary Table: All Functions that Update paidCash/paidGCash

| Function | File | Entry Point | Type |
|---|---|---|---|
| **showPaidUnpaid** | JobsOnQueue/showPaidUnpaid.dart | Main dialog | ⭐ PRIMARY |
| **showOnGoingStatus** | JobsOnGoing/showOnGoingStatus.dart | Status update | Dialog |
| **showDeliverOrCustomerPickup** | JobsDone/showDeliverOrCustomerPickup.dart | Delivery flow | Delivery |
| **showDeliverOrCustomerPickupPaidUnpaid** | JobsDone/showDeliverOrCustomerPickupPaidUnpaid.dart | Delivery flow (alt) | Delivery |
| **showJobOnQueue** | JobOnQueue/showJobOnQueue.dart | Queue view | Queue |
| **showJobOnQueueEdit** | JobsOnQueue/showJobOnQueueEdit.dart | Edit job | Edit |
| **showAdminJob** | Admin/subAdmin/showAdminJob.dart | Admin edit | Admin |
| **syncSelectedToRepoAll** | repository/jobmodel_repository.dart | Helper method | Sync |
| **syncSelectedToRepoMin** | repository/jobmodel_repository.dart | Helper method | Sync |

