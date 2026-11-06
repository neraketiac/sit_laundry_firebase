# Current Task Status - Full Overview

**Last Updated**: Continuation from context transfer
**Status**: 3 tasks in progress, awaiting user decisions/approvals

---

## TASK 1: Hide Payment Feature in showJobOnQueue ✅ COMPLETE

**Status**: DONE - Baseline established

**What was done**:
- Commented out `visPaidUnpaid` widget in `showJobOnQueue.dart`
- Wrapped payment recording logic in multi-line comment
- This was established as checkpoint before subsequent work

**File**: `lib/features/pages/header/JobOnQueue/showJobOnQueue.dart`

---

## TASK 2: SuppliesCurr Zero Bug - Phase 3 Fix Ready

**Status**: IN-PROGRESS - Fix documented, NOT applied yet

**Root Cause Found**:
- `computeCurrentStocks()` in `lib/core/services/database_supplies_current.dart` line 30
- Queries by `ItemId` (parent category = 422) instead of `ItemUniqueId` (specific type = 429)
- When multiple transaction types share same ItemId, wrong SuppliesCurr document retrieved
- When remarks content changes, Firestore document ordering changes → returns wrong transaction type → often 0 balance

**Phase 3 Fix Location**: `lib/core/services/database_supplies_current.dart` line 30

**BEFORE**:
```dart
.where('ItemId', isEqualTo: sMH.itemId)
```

**AFTER**:
```dart
.where('ItemUniqueId', isEqualTo: sMH.itemUniqueId)
```

**Current State**: Fix is documented in `CODE_CHANGES_FOR_REVIEW.md` but NOT applied to codebase (reverted per user request)

**Next Steps**:
- User reviews impact
- User approves Phase 3 fix to apply to database_supplies_current.dart

---

## TASK 3: Phase 1 & 2 Implementation - Ready for Review

**Status**: IN-PROGRESS - Code changes documented, awaiting approval

**What's being reviewed**: `CODE_CHANGES_FOR_REVIEW.md` - ALL 8 changes documented with before/after code

### Phase 1: Payment Tracking (6 files)
Add `jobRepo.paidCashAmountPrev = previousPaidCash;` to track previous payment for delta calculation

**Files affected**:
1. `lib/features/pages/body/JobsOnQueue/showPaidUnpaid.dart`
2. `lib/features/pages/body/JobsDone/showDeliverOrCustomerPickup.dart`
3. `lib/features/pages/body/JobsDone/showDeliverOrCustomerPickupPaidUnpaid.dart`
4. `lib/features/pages/header/JobOnQueue/showJobOnQueue.dart`
5. `lib/features/pages/header/Funds/showLaundryPayment.dart`
6. `lib/features/pages/header/GCash/showGCashPending.dart`

### Phase 2: Daily Cash Total (1 file)
Add `moneyText += ' T*$grandTotal';` to fund check remarks to track daily cash total

**File affected**:
- `lib/features/pages/header/Funds/showFundCheck.dart` - function `buildSelectedMoneyText()`

**Current State**: All 8 changes precisely documented in `CODE_CHANGES_FOR_REVIEW.md`

**Next Steps**:
- User approves or requests changes to Phase 1/2 code
- Once approved, apply all 8 changes simultaneously

---

## TASK 4: Admin Remarks Field - AWAITING STORAGE DECISION

**Status**: IN-PROGRESS - Impact analysis complete, implementation plan ready

**Feature Requirement**:
- Add new `admin_remarks` string field to JobModel
- **APPEND/CONCATENATE** on every update (does NOT replace)
- Format: `"fieldName: oldValue→newValue | empIdGlobal | Timestamp"`
- Scope: Jobs_queue, Jobs_ongoing, Jobs_done ONLY (NOT Jobs_completed)

**User Clarification Confirmed**: ✅
- admin_remarks grows with every update
- Creates complete history of all changes
- Each new update adds a new line entry

**Key Problem**: admin_remarks will grow indefinitely
- Firestore document size limit: 1MB
- Multiple daily updates = rapid growth
- Can exceed document size limit in theory

**DECISION NEEDED**: How to handle growth?

### Option 1: Subcollection (RECOMMENDED)
- Create `jobs_queue/{jobId}/admin_remarks_history/` subcollection
- Main doc stores only recent entries (last 10-20)
- Older entries archived in subcollection
- ✅ No size limit, ✅ maintains history, ⚠️ slightly more complex

### Option 2: Archive Collection
- Keep recent entries in main doc (e.g., last 100 entries)
- Archive older entries to `job_admin_remarks_archive` collection
- ✅ Simple, ⚠️ harder to view complete history

### Option 3: Separate Audit Collection
- Dedicated `job_audit_log` collection with jobId + timestamp
- admin_remarks field stays minimal/empty in main doc
- ✅ Clean separation, ✅ scalable, ⚠️ additional collection

**Current State**: 
- Impact analysis done: `ADMIN_REMARKS_FEATURE_IMPACT_ANALYSIS.md`
- JobModel structure reviewed
- Implementation plan ready (6-8 hours total)

**Next Steps**:
1. User chooses Option 1/2/3 for growth handling
2. Implementation proceeds in 4 phases:
   - Phase 1: Add field to JobModel (1 hour)
   - Phase 2: Create tracking functions (2 hours)
   - Phase 3: Integrate into Queue/Ongoing/Done (3-4 hours)
   - Phase 4: Implement growth handling (1-2 hours, if needed)

**Files to modify**: 
- `lib/features/jobs/models/jobmodel.dart` (add admin_remarks field)
- `lib/core/services/database_jobs.dart` (integrate wrapper function)

---

## Git Status

**Current State**: 
- Phase 3 database fix: NOT applied (per user request)
- Phase 1 & 2 changes: NOT applied (awaiting approval)
- Task 4 admin_remarks: NOT applied (awaiting storage decision)

**All changes currently only documented for review, nothing applied to codebase**

---

## Files Involved

### Review Documents
- `CODE_CHANGES_FOR_REVIEW.md` - All 8 changes from Phase 1, 2, 3 with before/after
- `ADMIN_REMARKS_FEATURE_IMPACT_ANALYSIS.md` - Complete analysis, decision options

### Code Files (Not yet modified)
- `lib/core/services/database_supplies_current.dart` - Phase 3 location (line 30)
- `lib/features/pages/body/JobsOnQueue/showPaidUnpaid.dart` - Phase 1
- `lib/features/pages/body/JobsDone/showDeliverOrCustomerPickup.dart` - Phase 1
- `lib/features/pages/body/JobsDone/showDeliverOrCustomerPickupPaidUnpaid.dart` - Phase 1
- `lib/features/pages/header/JobOnQueue/showJobOnQueue.dart` - Phase 1
- `lib/features/pages/header/Funds/showLaundryPayment.dart` - Phase 1
- `lib/features/pages/header/GCash/showGCashPending.dart` - Phase 1
- `lib/features/pages/header/Funds/showFundCheck.dart` - Phase 2
- `lib/features/jobs/models/jobmodel.dart` - Task 4 location

---

## Waiting For User

### Immediate (Next Message)
1. **Review Phase 1 & 2 code changes** in `CODE_CHANGES_FOR_REVIEW.md`
   - Approve or request modifications
   - Once approved → apply all 8 changes

2. **Choose storage option for admin_remarks** (Option 1/2/3)
   - Subcollection (recommended)
   - Archive collection
   - Separate audit log

### After Decisions
3. **Apply Phase 3** database fix to `database_supplies_current.dart` line 30
4. **Implement Task 4** admin_remarks feature based on chosen storage option

---

## Summary

| Task | Status | Blocker |
|------|--------|---------|
| Task 1 | ✅ Complete | None |
| Task 2 Phase 3 | 📋 Ready | User approval |
| Task 3 Phase 1 & 2 | 📋 Ready | User approval |
| Task 4 Admin Remarks | 📋 Ready | User storage decision |

**All tasks have documentation ready. Awaiting user decisions to proceed with implementation.**

