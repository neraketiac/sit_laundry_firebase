# Fund Check Message - CORRECTED Logic (Priority-Based)

## Simple Priority Rule:

**Check every 1 hour. Only STOP checking if:**
1. ✅ Fund check is DONE for the current period, AND
2. ✅ We're still in that period

**If either condition is false → Keep checking (show message every 1 hour)**

---

## Examples:

### Example 1: Morning Check Completed in Morning
```
9:00 AM (Morning) - User clicks
├─ Fund check NOT done
├─ Show message: "Complete morning fund check"
├─ Save to local storage: timestamp=9:00, period=morning, done=false

9:15 AM (Morning) - User clicks again
├─ Within 1 hour + Same period (morning)
├─ Check local storage: done=false
├─ Don't show message (already shown < 1 hour ago)
├─ Block action: "Still need to complete morning fund check"

9:30 AM (Morning) - User completes fund check
├─ Updates Firestore: morningCheck=true
├─ Also updates local storage: done=true, timestamp=9:30
├─ Dialog closes

9:45 AM (Morning) - User clicks
├─ Check local storage: done=true + still morning
├─ ✅ STOP CHECKING
├─ Allow proceed immediately
├─ NO message shown

11:50 AM (Still Morning) - User clicks
├─ Check local storage: done=true + still morning
├─ ✅ STOP CHECKING
├─ Allow proceed immediately
├─ NO message shown

12:05 PM (Lunch Period Now) - User clicks
├─ Period changed: morning → lunch
├─ Local storage shows morning done, but NOW it's lunch
├─ Lunch check NOT started yet
├─ Show message: "Complete lunch fund check"
├─ Save: timestamp=12:05, period=lunch, done=false
├─ New 1-hour cycle for lunch starts
```

### Example 2: Morning Check NOT Completed
```
9:00 AM (Morning) - User clicks
├─ Fund check NOT done
├─ Show message: "Complete morning fund check"
├─ Save: timestamp=9:00, period=morning, done=false

9:15 AM (Morning) - User clicks
├─ Within 1 hour + Same period
├─ Check local storage: done=false
├─ Don't show message yet (< 1 hour)

9:45 AM (Morning) - User closes app/busy

10:05 AM (Morning) - User clicks again
├─ More than 1 hour passed since 9:00
├─ Same period (still morning)
├─ Refresh Firestore: Morning still not done
├─ Show message again: "Complete morning fund check"
├─ Update timestamp: now=10:05
├─ New 1-hour cycle starts

10:30 AM (Morning) - User clicks
├─ Within 1 hour (since 10:05)
├─ Don't show message

11:10 AM (Morning) - User clicks
├─ 1 hour + 5 minutes passed (since 10:05)
├─ Refresh Firestore: Morning still not done
├─ Show message again
├─ Update timestamp: now=11:10

11:30 AM (Morning) - User completes fund check
├─ Updates Firestore: morningCheck=true
├─ Updates local storage: done=true, timestamp=11:30
├─ From now on: Allow proceed for rest of morning

12:15 PM (Lunch) - User clicks
├─ Period changed: morning → lunch
├─ Lunch check NOT done
├─ Show message: "Complete lunch fund check"
├─ Save: timestamp=12:15, period=lunch, done=false
```

### Example 3: Period Changed (Morning → Lunch → Dinner)
```
9:00 AM (Morning) - Fund check NOT done → Show message, block, save timestamp
10:10 AM (Morning) - Refresh every 1h → Still not done → Show message again
11:00 AM (Morning) - User completes → done=true, Allow proceed ✅

12:05 PM (Lunch) - Period changed → Lunch check NOT done → Show message, block
1:15 PM (Lunch) - Refresh every 1h → Still not done → Show message again
2:00 PM (Lunch) - User completes → done=true, Allow proceed ✅

4:10 PM (Dinner) - Period changed → Dinner check NOT done → Show message, block
5:15 PM (Dinner) - Refresh every 1h → Still not done → Show message again
5:45 PM (Dinner) - User completes → done=true, Allow proceed ✅

7:00 PM (Dinner) - Dinner done, still dinner → Allow proceed ✅
```

---

## Decision Tree Logic:

```
User clicks floating button
│
├─ Get current time period (Morning/Lunch/Dinner)
├─ Get current timestamp from local storage (fund_check_last_check_time)
├─ Get current period from local storage (fund_check_last_check_period)
├─ Get completion status from local storage (fund_check_completed)
├─ Get completion period from local storage (fund_check_completed_period)
│
├─ IF (period changed) OR (period not in local storage)
│  │
│  ├─ RESET period tracking
│  ├─ Load fresh data from Firestore
│  └─ Check if current period is completed
│
├─ IF (current period COMPLETED) AND (still in same period)
│  │
│  └─ ✅ ALLOW PROCEED (No message)
│
├─ ELSE (NOT completed) AND (1 hour passed since last check)
│  │
│  ├─ ✅ Refresh Firestore
│  ├─ ✅ Show message
│  ├─ ✅ Update timestamp
│  └─ ❌ Block proceed
│
├─ ELSE (NOT completed) AND (< 1 hour since last check)
│  │
│  └─ ❌ Block proceed (Don't show message again, already shown)
│
├─ ELSE (New day detected)
│  │
│  ├─ Clear all local storage
│  ├─ Fetch Firestore
│  └─ New cycle starts
│
└─ END
```

---

## Local Storage Keys:

```
fund_check_last_check_time       → Timestamp when last message shown
fund_check_last_check_period     → Period when last checked (morning/lunch/dinner)
fund_check_completed             → Boolean: Is current period completed?
fund_check_completed_period      → Which period is completed (morning/lunch/dinner)
fund_check_last_check_date       → Date to detect new day
```

---

## Summary:

### ✅ Message Shows When:
1. First click of the day/period
2. Every 1 hour if fund check NOT completed
3. Period changes (morning → lunch → dinner)

### ✅ Message STOPS When:
1. Fund check DONE for current period, AND
2. Still in that same period (haven't moved to next period)

### ✅ Message RESTARTS When:
1. New period begins (lunch period found, but morning was done)
2. New day begins (all periods reset)
3. More than 1 hour passed and fund check still not done

---

## Files to Modify:

### 1. `lib/core/services/project_version_manager.dart`
- Add local storage timestamp checks (1-hour based)
- Add period detection (morning/lunch/dinner)
- Add completion status tracking
- Add local storage get/set for tracking
- Modify `_validateFundCheck()` to implement decision tree

### 2. `lib/features/pages/header/Funds/showFundCheck.dart`
- When user clicks "Save": Update Firestore + Update local storage (completed=true)
- When user cancels without saving: Don't update completion status

---

## Key Difference from Previous Plan:

❌ OLD: "Skip Firestore if within 1 hour and same period"
✅ NEW: "Skip message if within 1 hour and same period, BUT still validate that fund check is actually done"
