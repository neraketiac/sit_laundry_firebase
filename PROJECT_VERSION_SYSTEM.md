# Project Version Management System

## Overview
This system ensures that the running project version matches the Firestore version. It prevents users from using outdated versions of the application.

## How It Works

### 1. Version Storage
- **Local Version**: Stored in `lib/core/global/app_version.dart` (format: `1.180`)
- **Firestore Version**: Stored in `project_version/current` collection with field `version`
- **Build Process**: `build_web.bat` automatically increments the version before deployment

### 2. Version Check Flow

When the app starts:

```
App Loads
    ↓
VersionCheckOverlay checks version
    ↓
Compare Local vs Firestore
    ↓
    ├─ Local > Firestore → Update Firestore, Allow Access ✅
    ├─ Local = Firestore → Allow Access ✅
    └─ Local < Firestore → Block Access, Show Refresh Screen ❌
```

### 3. Behavior by Version Status

#### ✅ Version Valid (Local ≥ Firestore)
- User can login
- All menu buttons work
- All floating buttons work
- Firestore is updated if local version is higher

#### ❌ Version Outdated (Local < Firestore)
- **Cannot login**
- **Cannot use menu buttons**
- **Cannot use floating buttons**
- Shows overlay with "Version Outdated" message
- User must click "Refresh Browser" button to reload

### 4. Files Involved

#### Core Files
- `lib/core/services/project_version_manager.dart` - Version comparison logic
- `lib/core/widgets/version_check_overlay.dart` - UI overlay that blocks outdated versions
- `lib/app.dart` - Wraps MaterialApp with VersionCheckOverlay
- `lib/core/global/app_version.dart` - Current app version (auto-updated by build_web.bat)

#### Firestore Structure
```
project_version/
  └─ current/
      └─ version: "1.180"
```

### 5. Version Comparison Logic

Versions are compared as semantic versions (e.g., "1.180"):
- `1.181 > 1.180` → Local is newer
- `1.180 = 1.180` → Versions match
- `1.179 < 1.180` → Local is outdated

### 6. Build Process Integration

The `build_web.bat` script:
1. Reads current version from `app_version.dart`
2. Increments the build number (e.g., `1.180` → `1.181`)
3. Updates `app_version.dart` with new version
4. Builds and deploys to Firebase
5. The new version is automatically synced to Firestore on first app load

### 7. Error Handling

- If Firestore is unreachable: **Allow access** (fail open)
- If version parsing fails: **Allow access** (fail open)
- This ensures the app remains usable even if the version check system fails

## User Experience

### Scenario 1: Normal Update
1. Admin runs `build_web.bat` (version bumps to 1.181)
2. App deploys to Firebase
3. Users refresh browser
4. App checks version: Local (1.181) > Firestore (1.180)
5. Firestore is updated to 1.181
6. Users can access the app

### Scenario 2: Outdated Browser
1. User has old version (1.179) cached in browser
2. Admin deployed new version (1.181)
3. User tries to access app
4. App checks version: Local (1.179) < Firestore (1.181)
5. **Overlay blocks all UI**
6. User sees "Version Outdated" message
7. User clicks "Refresh Browser"
8. Browser reloads, gets new version
9. Version check passes, app works

## Console Logs

The version check logs to console:
```
📦 Project Version Check:
   Local: 1.180
   Firestore: 1.180
   ✅ Versions match
```

Or if updating:
```
📦 Project Version Check:
   Local: 1.181
   Firestore: 1.180
   ✅ Local version is newer, updating Firestore...
```

Or if outdated:
```
📦 Project Version Check:
   Local: 1.179
   Firestore: 1.180
   ❌ Local version is outdated, refresh required
```

## Testing

### Test 1: Version Match
1. Deploy app
2. Check console logs
3. Should see "✅ Versions match"

### Test 2: Version Update
1. Run `build_web.bat` (increments version)
2. Deploy
3. Check console logs
4. Should see "✅ Local version is newer, updating Firestore..."

### Test 3: Outdated Version
1. Manually set Firestore version higher than app version
2. Load app in browser
3. Should see "Version Outdated" overlay
4. Click "Refresh Browser"
5. Should reload and work

## Future Enhancements

- Add version history tracking
- Add rollback capability
- Add scheduled version checks (not just on app load)
- Add notification system for pending updates
