# Firestore project_version Collection - Simple Implementation

## Overview
- **No periodic checking** - Only check on login and main button click
- **Simple Firestore write** - build_web.bat writes version to Firestore
- **One-time checks** - Login and main button trigger version check
- **User-friendly message** - Show outdated version message if needed

---

## FIRESTORE COLLECTION STRUCTURE

### Collection: `project_version`
### Document: `current`
```json
{
  "version": "1.209"
}
```

**That's it.** Just one field: `version` with the build number.

---

## FILES TO BE CREATED

### 1. **lib/core/services/project_version_manager.dart** (NEW - REPLACES CURRENT)
   - **Purpose:** Simple version check against Firestore
   - **Size:** ~80-100 lines
   - **Responsibilities:**
     - Fetch version from Firestore `project_version/current`
     - Compare with cached app version
     - Return message if outdated
     - No periodic checking, no listeners

### 2. **scripts/update_firestore_version.js** (NEW)
   - **Purpose:** Update Firestore after deploy
   - **Size:** ~60-80 lines
   - **Responsibilities:**
     - Read version from `lib/core/global/app_version.dart`
     - Write to Firestore `project_version/current`
     - Called by build_web.bat after Firebase deploy

### 3. **scripts/firestore-key.json** (NEW - GITIGNORED)
   - **Purpose:** Firebase Admin SDK service account key
   - **Size:** ~1KB
   - **Note:** Add to `.gitignore`

---

## FILES TO BE UPDATED

### 1. **build_web.bat** (MODIFIED)
   - **Current lines:** ~50
   - **Changes:** Add 3-5 lines
   - **What changes:**
     ```batch
     echo [7/7] Deploying to Firebase Hosting...
     call firebase deploy --only hosting
     if errorlevel 1 ( echo ERROR: firebase deploy failed & exit /b 1 )
     
     echo [8/8] Updating Firestore project_version...
     call node scripts/update_firestore_version.js
     ```
   - **Impact:** One extra step after deploy

### 2. **lib/core/global/app_version.dart** (NO CHANGE)
   - Already auto-updated by build_web.bat
   - No changes needed

### 3. **lib/main.dart** (MODIFIED)
   - **Current lines:** ~100+
   - **Changes:** Add 5-10 lines
   - **What changes:**
     ```dart
     // After login successful, trigger version check
     await ProjectVersionManager.instance.checkVersionOnLogin();
     ```
   - **Impact:** One function call after login

### 4. **lib/features/pages/header/main_laundry_header.dart** (MODIFIED)
   - **Current lines:** ~500+
   - **Changes:** Add 3-5 lines
   - **What changes:**
     ```dart
     // In main FAB onPressed
     await ProjectVersionManager.instance.checkVersionOnMainButton();
     ```
   - **Impact:** One function call in main button

### 5. **firebase.json** (MODIFIED - OPTIONAL)
   - **Current lines:** ~30
   - **Changes:** Add Firestore rules reference
   - **What changes:**
     ```json
     "firestore": {
       "rules": "firestore.rules"
     }
     ```
   - **Impact:** Minimal - just configuration

### 6. **.gitignore** (MODIFIED)
   - **Current lines:** ~50
   - **Changes:** Add 2 lines
   - **What changes:**
     ```
     scripts/firestore-key.json
     scripts/.env
     ```

### 7. **firestore.rules** (NEW - OPTIONAL)
   - **Purpose:** Firestore security rules
   - **Size:** ~10 lines
   - **What changes:**
     ```
     match /project_version/{document=**} {
       allow read: if true;
       allow write: if false;  // Only backend can write
     }
     ```

---

## IMPLEMENTATION DETAILS

### ProjectVersionManager.dart Structure

```dart
class ProjectVersionManager {
  static final instance = ProjectVersionManager._();
  
  String? _cachedVersion;
  
  // Called once on login
  Future<void> checkVersionOnLogin() async {
    final remoteVersion = await _fetchVersionFromFirestore();
    if (remoteVersion != null && _isOutdated(remoteVersion)) {
      _showVersionMessage(remoteVersion);
    }
    _cachedVersion = remoteVersion;
  }
  
  // Called when main button clicked
  Future<void> checkVersionOnMainButton() async {
    if (_cachedVersion == null) return; // Already checked on login
    
    final remoteVersion = await _fetchVersionFromFirestore();
    if (remoteVersion != null && _isOutdated(remoteVersion)) {
      _showVersionMessage(remoteVersion);
    }
  }
  
  Future<String?> _fetchVersionFromFirestore() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('project_version')
          .doc('current')
          .get();
      return doc.data()?['version'] as String?;
    } catch (e) {
      return null; // Fail silently
    }
  }
  
  bool _isOutdated(String remoteVersion) {
    return _compareVersions(appVersion, remoteVersion) < 0;
  }
  
  void _showVersionMessage(String remoteVersion) {
    // Show dialog or snackbar:
    // "You are using the old version, new version $remoteVersion is available.
    //  Please refresh the page to load it."
  }
}
```

### update_firestore_version.js Structure

```javascript
const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Initialize Firebase Admin
const serviceAccount = require('./firestore-key.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// Read version from app_version.dart
const versionFile = path.join(__dirname, '../lib/core/global/app_version.dart');
const content = fs.readFileSync(versionFile, 'utf8');
const match = content.match(/appVersion = '([^']+)'/);
const version = match ? match[1] : 'unknown';

// Update Firestore
admin.firestore()
  .collection('project_version')
  .doc('current')
  .set({ version }, { merge: true })
  .then(() => {
    console.log(`✓ Updated Firestore project_version to ${version}`);
    process.exit(0);
  })
  .catch(err => {
    console.error('✗ Failed to update Firestore:', err);
    process.exit(1);
  });
```

---

## WORKFLOW

### Build Process:
```
1. build_web.bat runs
2. Bumps version in app_version.dart (e.g., 1.209 → 1.210)
3. Runs flutter build web --release
4. Deploys to Firebase Hosting
5. Calls: node scripts/update_firestore_version.js
6. Script reads app_version.dart (gets 1.210)
7. Script writes to Firestore project_version/current: { version: "1.210" }
8. Done
```

### User Experience:

**On Login:**
```
User logs in
  ↓
checkVersionOnLogin() called
  ↓
Fetch version from Firestore (e.g., 1.210)
  ↓
Compare with cached app version (e.g., 1.209)
  ↓
If outdated: Show message
  "You are using the old version, new version 1.210 is available.
   Please refresh the page to load it."
  ↓
Cache the remote version
```

**On Main Button Click:**
```
User clicks main FAB button
  ↓
checkVersionOnMainButton() called
  ↓
If cache exists and outdated: Show same message
  ↓
Otherwise: Proceed normally
```

---

## FILES SUMMARY

### Created (3):
1. `lib/core/services/project_version_manager.dart` (~100 lines)
2. `scripts/update_firestore_version.js` (~70 lines)
3. `scripts/firestore-key.json` (gitignored)

### Updated (6):
1. `build_web.bat` (+5 lines)
2. `lib/main.dart` (+5 lines)
3. `lib/features/pages/header/main_laundry_header.dart` (+3 lines)
4. `.gitignore` (+2 lines)
5. `firebase.json` (optional, +3 lines)
6. `firestore.rules` (new, ~10 lines)

### Deleted (1):
1. `web/version.json` (no longer needed)

---

## TOTAL CHANGES

- **Files Created:** 3
- **Files Updated:** 6
- **Files Deleted:** 1
- **Total Lines Added:** ~200 lines
- **Complexity:** LOW
- **Time to Implement:** 2-3 hours
- **Risk Level:** VERY LOW

---

## KEY DIFFERENCES FROM PREVIOUS SYSTEM

| Aspect | Previous (web/version.json) | New (Firestore) |
|--------|---------------------------|-----------------|
| Storage | HTTP file | Firestore document |
| Checking | Periodic (15 min cache) | On-demand (login + button) |
| Firestore reads | 0 | 2 per session |
| Complexity | Medium | Low |
| Real-time | No | Yes |
| Offline support | Yes | No |
| Cost | Free | Minimal (reads are cheap) |

---

## SECURITY RULES

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /project_version/{document=**} {
      allow read: if true;  // Anyone can read
      allow write: if false; // Only backend (via Admin SDK)
    }
  }
}
```

---

## ADVANTAGES OF THIS APPROACH

1. **Simple** - No periodic checking, no listeners
2. **Efficient** - Only 2 Firestore reads per session
3. **Real-time** - Users see updates immediately after refresh
4. **User-friendly** - Clear message about outdated version
5. **Easy to implement** - ~200 lines total
6. **Easy to rollback** - Just revert build_web.bat
7. **No breaking changes** - Existing code mostly unchanged

---

## IMPLEMENTATION CHECKLIST

- [ ] Create `lib/core/services/project_version_manager.dart`
- [ ] Create `scripts/update_firestore_version.js`
- [ ] Create `scripts/firestore-key.json` (get from Firebase Console)
- [ ] Update `build_web.bat` to call update script
- [ ] Update `lib/main.dart` to call checkVersionOnLogin()
- [ ] Update `lib/features/pages/header/main_laundry_header.dart` to call checkVersionOnMainButton()
- [ ] Update `.gitignore` to ignore firestore-key.json
- [ ] Create/update `firestore.rules`
- [ ] Test: Run build_web.bat and verify Firestore update
- [ ] Test: Login and verify version check message
- [ ] Test: Click main button and verify version check message
- [ ] Delete `web/version.json` (optional cleanup)
