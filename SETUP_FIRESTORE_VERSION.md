# Quick Setup Guide - Firestore project_version

## What Was Created

✓ `lib/core/services/project_version_manager.dart` - Version checking logic  
✓ `scripts/update_firestore_version.js` - Auto-update script  
✓ `firestore.rules` - Security rules  
✓ Updated `build_web.bat` - Calls update script  
✓ Updated `enterloyaltycode.dart` - Check on login  
✓ Updated `main_laundry_header.dart` - Check on main button  
✓ Updated `.gitignore` - Protect credentials  

---

## Manual Setup Required

### Step 1: Get Firebase Service Account Key
```
1. Go to: https://console.firebase.google.com
2. Select your project
3. Go to: Project Settings (gear icon) → Service Accounts
4. Click: "Generate New Private Key"
5. Save file as: scripts/firestore-key.json
6. ⚠️ IMPORTANT: This file is gitignored - never commit it
```

### Step 2: Deploy Firestore Rules
```bash
firebase deploy --only firestore:rules
```

### Step 3: Create Firestore Document
```
1. Go to: Firebase Console → Firestore
2. Create collection: project_version
3. Create document: current
4. Add field:
   - Name: version
   - Type: String
   - Value: 1.209 (or your current version)
```

### Step 4: Install Node Dependencies (if needed)
```bash
cd scripts
npm install firebase-admin
cd ..
```

### Step 5: Test Build
```bash
build_web.bat
```

Expected output:
```
[7/7] Updating Firestore project_version...
✓ Updated Firestore project_version/current to version 1.210
[8/8] Done. Version: 1.210
```

---

## How It Works

### On Build:
```
build_web.bat runs
  ↓
Bumps version (1.209 → 1.210)
  ↓
Builds & deploys to Firebase
  ↓
Calls: node scripts/update_firestore_version.js
  ↓
Script writes to Firestore: { version: "1.210" }
```

### On User Login:
```
User logs in
  ↓
checkVersionOnLogin() called
  ↓
Fetches version from Firestore
  ↓
If outdated: Shows message
  "You are using the old version, new version 1.210 is available.
   Please refresh the page to load it."
```

### On Main Button Click:
```
User clicks main FAB
  ↓
checkVersionOnMainButton() called
  ↓
If outdated: Shows same message
```

---

## Firestore Collection Structure

```
project_version (collection)
  └── current (document)
      └── version: "1.210" (field)
```

That's it! Just one document with one field.

---

## Troubleshooting

### Q: Script fails with "Cannot find module 'firebase-admin'"
**A:** Install dependencies:
```bash
cd scripts
npm install firebase-admin
cd ..
```

### Q: "Firestore update failed" warning appears
**A:** Check:
1. Does `scripts/firestore-key.json` exist?
2. Is it valid JSON?
3. Are Firestore rules deployed?
4. Does `project_version/current` document exist?

### Q: Version message doesn't show on login
**A:** Check:
1. Is Firestore document `project_version/current` created?
2. Does it have a `version` field?
3. Check browser console for errors

### Q: "Refresh Now" button doesn't work
**A:** This only works on web. Make sure:
1. App is running on web (not mobile)
2. Browser allows page reload

---

## Files Reference

| File | Purpose | Status |
|------|---------|--------|
| `lib/core/services/project_version_manager.dart` | Version checking logic | ✓ Created |
| `scripts/update_firestore_version.js` | Auto-update script | ✓ Created |
| `firestore.rules` | Security rules | ✓ Created |
| `build_web.bat` | Build script | ✓ Updated |
| `enterloyaltycode.dart` | Login page | ✓ Updated |
| `main_laundry_header.dart` | Main page | ✓ Updated |
| `.gitignore` | Git ignore | ✓ Updated |
| `scripts/firestore-key.json` | Credentials | ⏳ Manual |

---

## Testing Checklist

- [ ] `scripts/firestore-key.json` created
- [ ] Firestore rules deployed
- [ ] Firestore document `project_version/current` created
- [ ] Run `build_web.bat` - check for success message
- [ ] Login to app - check for version message (if outdated)
- [ ] Click main button - check for version message (if outdated)
- [ ] Click "Refresh Now" - page should reload

---

## Done! 🎉

Your Firestore version checking system is ready to use.

Just complete the manual setup steps above and you're good to go!
