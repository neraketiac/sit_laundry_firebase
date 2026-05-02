# Firestore project_version Collection Implementation - Change Analysis

## Current System (web/version.json based)
- Version stored in: `web/version.json`
- Version checked from: Firebase Hosting HTTP request
- Update mechanism: `build_web.bat` updates `web/version.json` during build
- Cache duration: 15 minutes
- Firestore reads: 0 (no Firestore involved)

---

## Proposed System (Firestore collection based)
- Version stored in: Firestore `project_version` collection
- Version checked from: Firestore real-time listener
- Update mechanism: `build_web.bat` writes to Firestore after deploy
- Cache duration: 15 minutes (same)
- Firestore reads: 1 per 15 minutes per user

---

## SCOPE OF CHANGES

### SIZE ESTIMATE: **MEDIUM** (15-20 files affected)

---

## FILES TO BE CREATED

### 1. **lib/core/services/firestore_project_version_manager.dart** (NEW)
   - **Purpose:** Manages Firestore project_version collection reads
   - **Size:** ~150-200 lines
   - **Responsibilities:**
     - Real-time listener to `project_version` collection
     - Version comparison logic
     - Cache management (15 minutes)
     - Error handling (fail open)

### 2. **scripts/update_firestore_version.js** (NEW)
   - **Purpose:** Node.js script to update Firestore after deploy
   - **Size:** ~80-100 lines
   - **Responsibilities:**
     - Read current version from `lib/core/global/app_version.dart`
     - Update Firestore `project_version` collection
     - Handle authentication with Firebase Admin SDK
     - Error logging

### 3. **scripts/firestore-key.json** (NEW - GITIGNORED)
   - **Purpose:** Firebase Admin SDK service account key
   - **Size:** ~1KB
   - **Note:** Must be added to `.gitignore`

---

## FILES TO BE UPDATED

### 1. **build_web.bat** (MODIFIED)
   - **Current lines:** ~50
   - **Changes:** Add 5-10 lines
   - **What changes:**
     ```
     [7/7] Deploying to Firebase Hosting...
     call firebase deploy --only hosting
     
     [8/8] Updating Firestore project_version...  ← NEW
     call node scripts/update_firestore_version.js  ← NEW
     ```
   - **Impact:** Adds one extra step after Firebase deploy

### 2. **lib/core/services/project_version_manager.dart** (MODIFIED)
   - **Current lines:** ~120
   - **Changes:** Replace entire file OR create wrapper
   - **Option A - Replace (Simpler):**
     - Remove XMLHttpRequest logic (~40 lines)
     - Add Firestore listener logic (~60 lines)
     - Keep version comparison logic (reuse)
     - **Net change:** ~20 lines added
   
   - **Option B - Keep both (More complex):**
     - Keep current file as fallback
     - Create new `firestore_project_version_manager.dart`
     - Add logic to try Firestore first, fall back to version.json
     - **Net change:** ~80 lines added

### 3. **lib/core/global/variables.dart** (MODIFIED)
   - **Current lines:** ~500+
   - **Changes:** Add 1-2 lines
   - **What changes:**
     ```dart
     // Add new global variable
     StreamSubscription<DocumentSnapshot>? projectVersionListener;
     ```

### 4. **lib/main.dart** (MODIFIED)
   - **Current lines:** ~100+
   - **Changes:** Add 5-10 lines
   - **What changes:**
     ```dart
     // In initState or main():
     projectVersionListener = FirebaseFirestore.instance
         .collection('project_version')
         .doc('current')
         .snapshots()
         .listen((snapshot) {
           // Update version
         });
     
     // In dispose:
     projectVersionListener?.cancel();
     ```

### 5. **lib/core/services/database_jobs.dart** (MODIFIED - if using same pattern)
   - **Current lines:** ~500+
   - **Changes:** Add 1-2 lines
   - **What changes:** Add Firestore collection reference if not already present
   - **Impact:** Minimal - just ensure collection path is defined

### 6. **firebase.json** (MODIFIED)
   - **Current lines:** ~30
   - **Changes:** Modify cache headers for Firestore (optional)
   - **What changes:**
     ```json
     // Remove or modify version.json cache rules
     // Add Firestore security rules reference
     ```
   - **Impact:** Minimal - mostly cleanup

### 7. **web/version.json** (OPTIONAL - Can be deleted)
   - **Current lines:** 3
   - **Changes:** Can be removed entirely
   - **Impact:** Cleanup only - no longer needed

### 8. **package.json** (MODIFIED - if not already present)
   - **Current lines:** ~20
   - **Changes:** Add 2-3 lines
   - **What changes:**
     ```json
     "scripts": {
       "update-version": "node scripts/update_firestore_version.js"
     }
     ```
   - **Impact:** Minimal - just adds npm script

### 9. **.gitignore** (MODIFIED)
   - **Current lines:** ~50
   - **Changes:** Add 2-3 lines
   - **What changes:**
     ```
     scripts/firestore-key.json
     scripts/.env
     ```

### 10. **lib/features/pages/header/VersionCheckOverlay.dart** (MODIFIED - if exists)
   - **Current lines:** ~100+
   - **Changes:** Update message display
   - **What changes:** Update UI messages to reflect Firestore source
   - **Impact:** Minimal - just UI text

### 11. **Firestore Security Rules** (NEW/MODIFIED)
   - **Purpose:** Allow version reads, restrict writes
   - **Size:** ~10-15 lines
   - **What changes:**
     ```
     match /project_version/{document=**} {
       allow read: if true;
       allow write: if request.auth.uid == admin_uid;
     }
     ```

---

## FIRESTORE COLLECTION STRUCTURE

### Collection: `project_version`
### Document: `current`
```json
{
  "version": "1.210",
  "timestamp": "2026-05-01T12:00:00Z",
  "updatedBy": "build_script",
  "notes": "Auto-updated by build_web.bat"
}
```

---

## WORKFLOW CHANGES

### Current Workflow (web/version.json):
```
1. build_web.bat runs
2. Bumps version in app_version.dart
3. Updates web/version.json
4. Runs flutter build web
5. Deploys to Firebase Hosting
6. Done
```

### New Workflow (Firestore):
```
1. build_web.bat runs
2. Bumps version in app_version.dart
3. Runs flutter build web
4. Deploys to Firebase Hosting
5. Calls update_firestore_version.js  ← NEW
6. Script reads app_version.dart
7. Script updates Firestore project_version/current
8. Done
```

---

## DEPENDENCIES TO ADD

### In pubspec.yaml:
- Already have: `cloud_firestore` (likely)
- No new dependencies needed

### In Node.js (scripts):
- `firebase-admin` - for Firestore writes
- `dotenv` - for environment variables (optional)

---

## BREAKING CHANGES / CONSIDERATIONS

### 1. **Firestore Costs**
   - Current: 0 Firestore reads (uses HTTP)
   - New: ~1 read per user per 15 minutes
   - **Impact:** Minimal cost increase (reads are cheap)

### 2. **Offline Behavior**
   - Current: Works offline (cached version.json)
   - New: Requires internet for version check
   - **Impact:** Version check fails gracefully (fail open)

### 3. **Deployment Dependency**
   - Current: Independent (just HTTP)
   - New: Requires Firebase Admin SDK credentials
   - **Impact:** Need to store `firestore-key.json` securely

### 4. **Real-time Updates**
   - Current: 15-minute cache
   - New: Real-time listener (can be instant)
   - **Benefit:** Users see updates faster

### 5. **Security Rules**
   - Current: No rules needed (public file)
   - New: Must configure Firestore rules
   - **Impact:** Need to set up read-only access

---

## IMPLEMENTATION COMPLEXITY

| Component | Complexity | Time |
|-----------|-----------|------|
| Create FirestoreProjectVersionManager | Medium | 1-2 hours |
| Create update_firestore_version.js | Low | 30 mins |
| Update build_web.bat | Low | 15 mins |
| Update main.dart | Low | 30 mins |
| Set up Firestore rules | Low | 15 mins |
| Testing | Medium | 1-2 hours |
| **TOTAL** | **Medium** | **4-6 hours** |

---

## RISK ASSESSMENT

| Risk | Severity | Mitigation |
|------|----------|-----------|
| Firestore down | Low | Fail open - allow access |
| Script fails | Low | Manual Firestore update possible |
| Wrong credentials | Medium | Use environment variables |
| Version mismatch | Low | Version comparison logic handles it |
| Firestore costs | Low | Minimal read volume |

---

## ROLLBACK PLAN

If issues occur:
1. Keep `web/version.json` as fallback
2. Revert `build_web.bat` to skip Firestore update
3. Revert `ProjectVersionManager` to use HTTP
4. Takes ~5 minutes to rollback

---

## SUMMARY

**Total Files:**
- **Created:** 3 (1 Dart, 1 JS, 1 JSON key)
- **Updated:** 8-10 (mostly small changes)
- **Deleted:** 0 (optional cleanup of version.json)

**Total Lines Changed:** ~200-300 lines across all files

**Complexity:** Medium (straightforward, no architectural changes)

**Time to Implement:** 4-6 hours including testing

**Risk Level:** Low (can fail gracefully, easy rollback)
