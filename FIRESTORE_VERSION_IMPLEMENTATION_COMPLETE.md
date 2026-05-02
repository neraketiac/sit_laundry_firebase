# Firestore project_version Implementation - COMPLETE ✓

## Summary
Successfully implemented simple version checking system using Firestore `project_version` collection. No periodic checking - only checks on login and main button click.

---

## FILES CREATED

### 1. **lib/core/services/project_version_manager.dart** ✓
- **Purpose:** Manages version checking against Firestore
- **Size:** ~120 lines
- **Key Methods:**
  - `checkVersionOnLogin(context)` - Called once on login
  - `checkVersionOnMainButton(context)` - Called on main FAB click
  - `_fetchVersionFromFirestore()` - Fetches from Firestore
  - `_isOutdated(remoteVersion)` - Compares versions
  - `_showVersionMessage(context, remoteVersion)` - Shows dialog
  - `_refreshPage()` - Reloads browser page

### 2. **scripts/update_firestore_version.js** ✓
- **Purpose:** Updates Firestore after build deploy
- **Size:** ~50 lines
- **Functionality:**
  - Reads version from `lib/core/global/app_version.dart`
  - Writes to Firestore `project_version/current`
  - Uses Firebase Admin SDK

### 3. **firestore.rules** ✓
- **Purpose:** Firestore security rules
- **Size:** ~10 lines
- **Rules:**
  - Allow anyone to read `project_version`
  - Only backend (Admin SDK) can write
  - Deny all other access

---

## FILES UPDATED

### 1. **build_web.bat** ✓
- **Changes:** Added 5 lines
- **What changed:**
  ```batch
  echo [7/7] Updating Firestore project_version...
  call node scripts/update_firestore_version.js
  if errorlevel 1 ( echo WARNING: Firestore update failed, but deployment succeeded )
  ```
- **Impact:** Calls update script after Firebase deploy

### 2. **lib/features/pages/body/Loyalty/enterloyaltycode.dart** ✓
- **Changes:** Added 3 lines + import
- **What changed:**
  ```dart
  void _queuePage(BuildContext context, String empid) async {
    // Check version on login
    await ProjectVersionManager.instance.checkVersionOnLogin(context);
    
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => MyMainLaundryHeader(empid)));
  }
  ```
- **Impact:** Triggers version check when user logs in

### 3. **lib/features/pages/header/main_laundry_header.dart** ✓
- **Changes:** Added 3 lines + import
- **What changed:**
  ```dart
  onPressed: () async {
    // Check version on main button click
    await ProjectVersionManager.instance.checkVersionOnMainButton(context);
    
    if (_isOpen) {
      setState(() => _isOpen = false);
    } else {
      setState(() => _isOpen = true);
    }
  },
  ```
- **Impact:** Triggers version check when main FAB is clicked

### 4. **.gitignore** ✓
- **Changes:** Added 1 line
- **What changed:**
  ```
  scripts/firestore-key.json
  ```
- **Impact:** Protects Firebase credentials

---

## FIRESTORE COLLECTION STRUCTURE

### Collection: `project_version`
### Document: `current`
```json
{
  "version": "1.209"
}
```

**That's it.** Just one field with the version number.

---

## WORKFLOW

### Build Process:
```
1. Run: build_web.bat
2. Bumps version in app_version.dart (e.g., 1.209 → 1.210)
3. Runs flutter build web --release
4. Deploys to Firebase Hosting
5. Calls: node scripts/update_firestore_version.js
6. Script reads app_version.dart (gets 1.210)
7. Script writes to Firestore: { version: "1.210" }
8. Done ✓
```

### User Experience:

**On Login:**
```
User enters loyalty code and clicks "Queue"
  ↓
_queuePage() called
  ↓
checkVersionOnLogin() triggered
  ↓
Fetches version from Firestore (e.g., 1.210)
  ↓
Compares with cached app version (e.g., 1.209)
  ↓
If outdated: Shows dialog
  "You are using the old version, new version 1.210 is available.
   Please refresh the page to load it."
  ↓
User can click "Refresh Now" or "Later"
  ↓
Proceeds to main page
```

**On Main Button Click:**
```
User clicks main FAB button
  ↓
checkVersionOnMainButton() triggered
  ↓
If cached version is outdated: Shows same dialog
  ↓
Otherwise: Opens menu normally
```

---

## SETUP INSTRUCTIONS

### 1. Get Firebase Service Account Key
1. Go to Firebase Console → Project Settings → Service Accounts
2. Click "Generate New Private Key"
3. Save as `scripts/firestore-key.json`
4. **Important:** This file is gitignored - don't commit it

### 2. Deploy Firestore Rules
```bash
firebase deploy --only firestore:rules
```

### 3. Create Initial Firestore Document
1. Go to Firebase Console → Firestore
2. Create collection: `project_version`
3. Create document: `current`
4. Add field: `version` = `"1.209"` (or current version)

### 4. Test Build
```bash
build_web.bat
```
- Should see: `✓ Updated Firestore project_version/current to version 1.210`

---

## VERIFICATION CHECKLIST

- [x] `lib/core/services/project_version_manager.dart` created
- [x] `scripts/update_firestore_version.js` created
- [x] `firestore.rules` created
- [x] `build_web.bat` updated
- [x] `enterloyaltycode.dart` updated with login check
- [x] `main_laundry_header.dart` updated with main button check
- [x] `.gitignore` updated
- [x] No compilation errors
- [ ] `scripts/firestore-key.json` added (manual step)
- [ ] Firestore rules deployed (manual step)
- [ ] Initial Firestore document created (manual step)
- [ ] Test build run (manual step)

---

## KEY FEATURES

✓ **Simple** - No periodic checking, no listeners  
✓ **Efficient** - Only 2 Firestore reads per session  
✓ **Real-time** - Users see updates immediately after refresh  
✓ **User-friendly** - Clear message about outdated version  
✓ **Easy to implement** - ~200 lines total  
✓ **Easy to rollback** - Just revert build_web.bat  
✓ **No breaking changes** - Existing code mostly unchanged  

---

## NEXT STEPS

1. **Get Firebase Service Account Key:**
   - Firebase Console → Project Settings → Service Accounts
   - Generate New Private Key
   - Save as `scripts/firestore-key.json`

2. **Deploy Firestore Rules:**
   ```bash
   firebase deploy --only firestore:rules
   ```

3. **Create Initial Firestore Document:**
   - Collection: `project_version`
   - Document: `current`
   - Field: `version` = current app version

4. **Test:**
   ```bash
   build_web.bat
   ```

5. **Verify:**
   - Check Firestore console - should see updated version
   - Login to app - should see version check
   - Click main button - should see version check

---

## TROUBLESHOOTING

### Script fails with "Cannot find module 'firebase-admin'"
```bash
cd scripts
npm install firebase-admin
```

### Firestore update shows WARNING but deployment succeeded
- This is OK - deployment succeeded, just Firestore update failed
- Check if `firestore-key.json` exists and is valid
- Check if Firestore rules are deployed

### Version message doesn't show on login
- Check if Firestore document `project_version/current` exists
- Check if version field is populated
- Check browser console for errors

### "Refresh Now" button doesn't work
- Only works on web platform
- Make sure app is running on web (not mobile)

---

## SUMMARY

**Total Changes:**
- Files Created: 3
- Files Updated: 4
- Total Lines Added: ~200
- Complexity: LOW
- Risk Level: VERY LOW
- Time to Implement: 2-3 hours (including manual setup)

**Status:** ✓ COMPLETE - Ready for manual setup and testing
