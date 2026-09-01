# Fund Check Message Optimization - Detailed Analysis

## Current Implementation

### Current Flow (2-hour cache):
1. User clicks floating button
2. `ProjectVersionManager.checkVersionOnMainButton()` calls `_validateFundCheck()`
3. `_validateFundCheck()` calls `_fetchFundCheck()` (Firestore query)
4. Firestore result is cached in `_cachedFundCheck` for **2 hours**
5. Within 2 hours: Uses cached data, **same message shown repeatedly** even after user saw it once
6. After 2 hours: Fetches Firestore again

**Problem**: Message appears every time user clicks the button (within 2 hours), not just once.

---

## Proposed Optimization

### New Flow (1-hour cache + "message already shown" flag):
1. User clicks floating button
2. Check local storage for `fund_check_message_shown_timestamp`
3. If exists AND within 1 hour: **Skip all checks, allow proceed**
   - Don't fetch from Firestore
   - Don't show message again
   - Still respect the time period validation
4. If not exists OR after 1 hour expires:
   - Fetch from Firestore (fresh check)
   - Validate time-based fund check (morning/lunch/dinner)
   - If message needed: Show it + save timestamp to local storage
   - If not needed: Just proceed

---

## Key Implementation Details

### 1. Local Storage Keys to Add:
```
fund_check_message_shown_timestamp  → Stores when message was last shown
fund_check_message_shown_period     → Stores which period (morning/lunch/dinner)
fund_check_current_period           → Stores which period we're checking for
```

### 2. Time-Based Periods (Critical):
- **Morning**: 00:00 - 11:59 (before 12:00)
- **Lunch**: 12:00 - 15:59 (12:00 to before 4 PM)
- **Dinner**: 16:00 - 23:59 (4 PM onwards)

### 3. Logic for Showing Message:

**Scenario A - First click today**
- No local storage timestamp found
- Fetch Firestore → Check current period fund check status
- If morning check not done: Show message + save timestamp + period
- If done: Proceed, don't show message

**Scenario B - Click within 1 hour (same period)**
- Local storage timestamp exists AND within 1 hour
- **Don't fetch Firestore, don't show message**
- Proceed directly
- **Why?**: User already saw the message 10 minutes ago, doesn't need to see again

**Scenario C - Click within 1 hour (different period)**
- Example: User clicks at 11:50 (morning), then clicks at 12:10 (lunch)
- New period detected (lunch now instead of morning)
- Fetch Firestore to check lunch status
- If lunch check not done: Show message + update storage
- If done: Proceed

**Scenario D - Click after 1 hour expires (same period)**
- Local storage timestamp exists but > 1 hour old
- Same period still (e.g., still morning at 11:30 → still morning at 12:00 is lunch)
- Fetch Firestore again (refresh status)
- Validate status, show message if needed, update timestamp

**Scenario E - New day detected**
- Day changed → Clear all local storage fund check keys
- Fetch Firestore → Will auto-reset (or we create new record)
- Proceed with validation

---

## Code Changes Required

### File 1: `ProjectVersionManager` (Main Logic)
**Changes:**
- Change cache duration from **2 hours → 1 hour**
- Add local storage timestamp tracking
- Add period tracking (morning/lunch/dinner)
- Modify `_validateFundCheck()` to:
  - Check local storage timestamp first
  - Skip Firestore if within 1 hour + same period
  - Detect period changes
  - Detect new day

### File 2: `showFundCheck.dart` (Save Logic)
**Changes:**
- After successful save to Firestore
- Also save timestamp + period to local storage
- Clear the "already shown" timestamp when fund check is completed

---

## New Cache Behavior

| Check Scenario | Action | Firestore Call |
|---|---|---|
| First click today | Fetch from Firestore | ✅ Yes |
| Click within 1h (same period) | Use local storage flag | ❌ No |
| Click after 1h (same period) | Fetch from Firestore | ✅ Yes |
| Period changes (9:00am → 12:10pm) | Fetch from Firestore | ✅ Yes |
| New day detected | Clear cache, fetch | ✅ Yes |

---

## Benefits of This Approach

1. **Message appears only once** (or when period changes)
2. **Respects period changes** (morning → lunch → dinner)
3. **Reduced Firestore calls** (compared to every click)
4. **Smart cache expiry** (1 hour instead of 2)
5. **No duplicate alerts** within the same period
6. **Auto-refresh after 1 hour** if user hasn't completed fund check

---

## Edge Cases Handled

✅ User completes fund check → Message cleared  
✅ User closes app and reopens → Timestamp persists  
✅ Clock changes (11:59 AM → 12:01 PM) → New period detected  
✅ New day → All local storage cleared  
✅ User completes morning check at 11:45 AM  
   - Next click at 12:05 PM (lunch) → New message shown  
✅ Network error → Falls back to local storage data  

---

## Summary Before Implementation

**What will change:**
1. Add 3 new local storage keys for fund check tracking
2. Add period detection logic
3. Add 1-hour expiry check + period change detection
4. Reduce cache from 2 hours to 1 hour
5. Clear local storage when fund check is saved

**What stays the same:**
- Firestore structure (no changes needed)
- Fund check model (no changes)
- Time periods validation (morning/lunch/dinner same rules)

**Result:**
- Message shows once per period
- After user completes fund check, message doesn't show again until next period or tomorrow
- More efficient, less repetitive alerts
