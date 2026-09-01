# Fund Check Implementation - Testing Guide

## How to Test Locally

### Prerequisites:
- Open browser DevTools (F12)
- Go to Application tab → Local Storage
- Monitor console logs

---

## Test Case 1: Message Shows Once Per Period

### Scenario: Morning fund check not done

**Setup**:
- Clear local storage: `fund_check_*` keys
- Current time: 9:00 AM
- Firestore: `morningCheck = false`

**Steps**:
1. Click floating button
2. **Expected**: Message dialog appears "Fund check required"
3. **Verify**: Local storage has:
   - `fund_check_last_check_time` = current timestamp
   - `fund_check_last_check_period` = "morning"
   - `fund_check_completed` = "false"

4. Click "Cancel" button
5. Click floating button again (9:10 AM, within 1 hour)
6. **Expected**: NO message shown, action blocked silently
7. **Verify**: Timestamp NOT updated (still shows 9:00)

---

## Test Case 2: Message Reappears After 1 Hour

### Scenario: 1 hour passes, fund check still not done

**Setup**:
- From previous test, time is 9:10 AM
- Morning still not done

**Steps**:
1. Manually set system time to 10:15 AM (or adjust timestamp in local storage)
2. Click floating button
3. **Expected**: Message dialog appears again "Fund check required"
4. **Verify**: 
   - Firestore was queried (check network tab)
   - `fund_check_last_check_time` updated to 10:15

---

## Test Case 3: Complete Fund Check

### Scenario: User completes morning fund check

**Setup**:
- Message is showing (from Test Case 2)
- Current time: 10:15 AM

**Steps**:
1. Click "Go to Fund Check" button
2. Enter fund amounts (e.g., count some bills)
3. Click "Save" button
4. **Expected**: Success message "Fund check saved successfully"
5. **Verify** Local storage has:
   - `fund_check_completed` = "true"
   - `fund_check_completed_period` = "morning"
6. **Verify** Firestore updated:
   - `morningCheck` = true

---

## Test Case 4: No Message After Completion

### Scenario: Fund check done, try to proceed

**Setup**:
- From previous test, morning fund check completed
- Current time: 10:45 AM

**Steps**:
1. Click floating button
2. **Expected**: NO message shown, action proceeds immediately
3. **Verify**: No Firestore query made (check network tab)
4. Click floating button again at 11:50 AM
5. **Expected**: Still no message, proceeds immediately

---

## Test Case 5: Period Change Resets

### Scenario: Morning done, but lunch not done

**Setup**:
- Morning fund check completed
- Current time: 12:05 PM (lunch period)
- Firestore: `lunchCheck = false`

**Steps**:
1. Click floating button at 12:05 PM
2. **Expected**: New message appears "Fund check required" for lunch
3. **Verify** Local storage changed:
   - `fund_check_last_check_period` = "lunch"
   - `fund_check_completed` = "false"
   - `fund_check_completed_period` = "morning" (remember previous)

---

## Test Case 6: New Day Clears Everything

### Scenario: Next day starts

**Setup**:
- Morning fund check was done today
- Current time: 12:05 AM (next day)
- Firestore: New record created for tomorrow

**Steps**:
1. Manually set system date to tomorrow
2. Click floating button
3. **Expected**: Message appears (new day, morning not done)
4. **Verify** Local storage cleared and reset:
   - `fund_check_last_check_date` = new date
   - `fund_check_completed` = "false"
   - All tracking reset

---

## Test Case 7: Page Reload Persists State

### Scenario: User refreshes page

**Setup**:
- Morning fund check not done
- Message shown at 9:00 AM
- Current time: 9:30 AM

**Steps**:
1. F5 or reload page
2. Click floating button
3. **Expected**: NO message shown (within 1 hour, already shown)
4. **Verify**: Local storage still has original timestamp from 9:00

---

## Test Case 8: Lunch Period (12:00-15:59)

### Scenario: Check lunch period

**Setup**:
- Current time: 1:30 PM
- Firestore: `lunchCheck = false`

**Steps**:
1. Click floating button
2. **Expected**: Message "Fund check required"
3. **Verify**: `fund_check_last_check_period` = "lunch"
4. Complete lunch fund check
5. **Verify**: `fund_check_completed_period` = "lunch"

---

## Test Case 9: Dinner Period (16:00-23:59)

### Scenario: Check dinner period

**Setup**:
- Current time: 5:00 PM
- Firestore: `dinnerCheck = false`

**Steps**:
1. Click floating button
2. **Expected**: Message "Fund check required"
3. **Verify**: `fund_check_last_check_period` = "dinner"
4. Complete dinner fund check
5. **Verify**: `fund_check_completed_period` = "dinner"

---

## Console Debug Output to Look For

### First Click (Message Shown):
```
✅ Fund check fetched and cached for 1 hour
You need to fund check to proceed.
```

### Second Click (Within 1 Hour):
```
⏱️ Within 1 hour of last check, blocking proceed (message already shown)
```

### After 1 Hour:
```
📡 Fetching fund check from Firestore...
✅ Fund check fetched and cached for 1 hour
You need to fund check to proceed.
```

### After Completion:
```
✅ Local storage updated: morning fund check completed
```

### Next Click After Completion:
```
✅ morning fund check already completed, allowing proceed
```

### New Day:
```
📅 New day detected, clearing fund check tracking
```

### Period Change:
```
🔄 Period changed, resetting completion tracking (now: lunch)
```

---

## Browser DevTools Checks

### Local Storage Keys to Monitor:
```
fund_check_last_check_time       (timestamp in milliseconds)
fund_check_last_check_period     (morning/lunch/dinner)
fund_check_last_check_date       (YYYY-MM-DD)
fund_check_completed             (true/false)
fund_check_completed_period      (morning/lunch/dinner)
```

### Firestore Collections to Check:
```
Collections → fund_checks → Today's document
├─ logDate: Today's date/time
├─ morningCheck: true/false
├─ lunchCheck: true/false
├─ dinnerCheck: true/false
├─ morningEnable: true
├─ lunchEnable: true
├─ dinnerEnable: true
```

---

## Quick Summary: What Should Happen

| Action | Result |
|--------|--------|
| Click (not done, 1st time) | Show message |
| Click (not done, <1h) | Block, no message |
| Click (not done, >1h) | Show message again |
| Click (done, same period) | Allow proceed, no message |
| Period changes | New message (if not done) |
| Complete fund check | Local storage + Firestore updated |
| Next click (done) | Allow proceed immediately |
| New day | All tracking cleared, restart |

---

## If Something Goes Wrong

### Message Still Shows After Completion:
- Check local storage: `fund_check_completed` should be "true"
- Check Firestore: `morningCheck` should be true
- Check console for errors

### Message Not Showing on First Click:
- Check Firestore: Does the record exist?
- Check console: Any error messages?
- Check if `validateTimeBasedFundCheck()` returns error

### Stuck in Blocking State:
- Check local storage timestamp
- Check if 1 hour has actually passed
- Try clearing local storage manually

### Period Not Changing:
- Check current time (should be in different period)
- Check local storage `fund_check_last_check_period`
- Verify `getCurrentTimePeriod()` function works

---

## Success Criteria ✅

- [x] Message shows on first click (not done)
- [x] Message doesn't repeat within 1 hour
- [x] Message reappears after 1 hour (if not done)
- [x] Message stops after completion
- [x] Period changes are detected
- [x] New day clears everything
- [x] Local storage persists across reloads
- [x] Firestore synced with local storage
