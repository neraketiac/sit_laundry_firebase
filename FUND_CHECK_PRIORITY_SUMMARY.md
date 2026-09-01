# Fund Check Priority Logic - Quick Summary

## The Rule (Simple):

**Check every 1 hour. Stop ONLY when:**
- ✅ Fund check is DONE in Firestore for current period, AND
- ✅ Current time is still in that period

---

## Timeline Example:

```
MORNING PERIOD (00:00 - 11:59)
│
├─ 9:00 AM: Click → Not done → SHOW MESSAGE + Save time
├─ 9:30 AM: Click → Within 1h → BLOCK (no message, already shown)
├─ 10:15 AM: Click → Within 1h → BLOCK (no message)
├─ 10:45 AM: Click → User completes fund check ✅
├─ 11:00 AM: Click → DONE ✅ Still morning → ALLOW (no message)
├─ 11:50 AM: Click → DONE ✅ Still morning → ALLOW (no message)
│
├─ 12:05 PM: PERIOD CHANGED TO LUNCH ❌
│   └─ STOP allowing, new period started
│   └─ Lunch not done → SHOW MESSAGE
│
└─ (Repeat cycle for lunch 12:00-15:59)

LUNCH PERIOD (12:00 - 15:59)
│
├─ 12:05 PM: Click → Not done → SHOW MESSAGE + Save time
├─ 12:30 PM: Click → Within 1h → BLOCK (no message)
├─ 1:15 PM: Click → 1 hour 10 min passed → REFRESH Firestore + SHOW MESSAGE
├─ 1:45 PM: Click → Within 1h → BLOCK (no message)
├─ 2:00 PM: User completes fund check ✅
├─ 2:15 PM: Click → DONE ✅ Still lunch → ALLOW (no message)
│
├─ 4:05 PM: PERIOD CHANGED TO DINNER ❌
│   └─ Dinner not done → SHOW MESSAGE
│
└─ (Repeat cycle for dinner 16:00-23:59)
```

---

## State Machine:

```
┌─────────────┐
│   WAITING   │ (User hasn't clicked)
└──────┬──────┘
       │ User clicks
       ▼
┌─────────────────────────────────┐
│ Check: Period Changed?          │
└──────┬──────────────────────────┘
       │ YES              │ NO
       │                  │
   Clear           Continue
   storage
       │                  │
       ▼                  ▼
┌──────────────────────────────────┐
│ Current Period DONE?             │
│ (Check local storage)            │
└──┬──────────────────────────┬────┘
   │ YES                      │ NO
   │                          │
   │                  ┌───────┴────────┐
   │                  │ 1 hour passed? │
   │                  └───┬────────┬───┘
   │                      │        │
   │              YES     │ NO     │
   │                      │        │
   │              ┌─────┐ │        └─► BLOCK (No message)
   │              │ YES │ │            (Already showed)
   │              ├─────┤ │
   │              ▼     ▼ │
   │      ┌───────────────┘
   │      │ SHOW MESSAGE
   │      │ Update timestamp
   │      │ BLOCK proceed
   │      │
   └──────┼──► ALLOW proceed
          │    No message
          └──► No Firestore call
```

---

## State Tracking in Local Storage:

```javascript
// When message is shown at 9:00 AM for morning:
{
  "fund_check_last_check_time": 1705321200000,      // 9:00 AM timestamp
  "fund_check_last_check_period": "morning",         // Current period checking
  "fund_check_completed": false,                     // Morning not done yet
  "fund_check_completed_period": "",                 // No period done yet
  "fund_check_last_check_date": "2024-01-15"        // Today's date
}

// After 1 hour at 10:00 AM (still not done):
// → Same structure, will show message again

// After user completes at 10:45 AM:
{
  "fund_check_last_check_time": 1705325100000,      // 10:45 AM timestamp
  "fund_check_last_check_period": "morning",
  "fund_check_completed": true,                     // ✅ Now true
  "fund_check_completed_period": "morning",         // This period done
  "fund_check_last_check_date": "2024-01-15"
}

// At 11:00 AM (still morning, already done):
// → No Firestore call needed, just ALLOW proceed

// At 12:05 PM (period changed to lunch):
{
  "fund_check_last_check_time": 1705329900000,      // 12:05 PM timestamp
  "fund_check_last_check_period": "lunch",          // New period
  "fund_check_completed": false,                    // Lunch not done
  "fund_check_completed_period": "morning",         // Remember morning was done
  "fund_check_last_check_date": "2024-01-15"
}
// → Show message for lunch, new 1-hour cycle
```

---

## Implementation Pseudocode:

```dart
Future<bool> _validateFundCheck(BuildContext context) async {
  
  // Step 1: Detect period change or new day
  final currentPeriod = FundCheckService.getCurrentTimePeriod(); // morning/lunch/dinner
  final storedPeriod = localStorage.get('fund_check_last_check_period');
  final storedDate = localStorage.get('fund_check_last_check_date');
  final today = DateTime.now().toDateString();
  
  if (storedDate != today) {
    // NEW DAY - clear everything
    localStorage.clear('fund_check_*');
  }
  
  if (currentPeriod != storedPeriod) {
    // PERIOD CHANGED - reset completion tracking
    localStorage.set('fund_check_last_check_period', currentPeriod);
    localStorage.set('fund_check_completed', false);
  }
  
  // Step 2: Check if current period is already done
  final isCompleted = localStorage.get('fund_check_completed') ?? false;
  
  if (isCompleted) {
    // ✅ DONE - Allow proceed
    return true;
  }
  
  // Step 3: Check if 1 hour has passed since last check
  final lastCheckTime = localStorage.get('fund_check_last_check_time');
  final now = DateTime.now().millisecondsSinceEpoch;
  final oneHourMs = 60 * 60 * 1000;
  
  if (lastCheckTime != null && (now - lastCheckTime) < oneHourMs) {
    // Within 1 hour - don't show message again
    // ❌ BLOCK proceed
    return false;
  }
  
  // Step 4: 1 hour passed or first time - Check Firestore
  final fundCheck = await _fetchFundCheckFromFirestore();
  
  if (fundCheck == null) {
    return true; // No record, allow proceed
  }
  
  // Step 5: Validate based on current period
  final isCurrentPeriodDone = FundCheckService.isCurrentPeriodDone(fundCheck);
  
  if (isCurrentPeriodDone) {
    // ✅ DONE in Firestore - Update local storage
    localStorage.set('fund_check_completed', true);
    localStorage.set('fund_check_completed_period', currentPeriod);
    return true; // Allow proceed
  }
  
  // Step 6: Not done - Show message & update timestamp
  localStorage.set('fund_check_last_check_time', now);
  localStorage.set('fund_check_last_check_date', today);
  
  // Show the dialog
  if (context.mounted) {
    final result = await showDialog(...); // Fund check required dialog
    if (result == true) {
      // User wants to go to fund check
      return false; // Block, let them go do it
    }
  }
  
  return false; // ❌ BLOCK proceed
}
```

---

## What Gets Stored vs What Gets Checked:

| Operation | Local Storage | Firestore | 
|-----------|---------------|-----------|
| User clicks first time | ✅ Save timestamp | ✅ Read status |
| Show message | ✅ Update timestamp | ❌ No call |
| Within 1 hour, not done | ❌ No update | ❌ No call |
| After 1 hour, not done | ✅ Update timestamp | ✅ Refresh |
| Period changes | ✅ Reset tracking | ✅ Check new period |
| User completes | ✅ Mark done | ✅ morningCheck=true |
| Next click (done) | ✅ Check local | ❌ No call needed |

---

## Ready? ✅

This is the correct logic. Should I proceed with implementation?
