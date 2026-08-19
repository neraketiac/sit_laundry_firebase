# Visual Menu Guide - Where Everything Is

## 🎯 Quick Answer

### Salary Correction
```
File: lib/features/pages/body/main_laundry_body.dart
Line: 676-679

Visible at: Top menu bar → Tools → Admin → Salary Correction
```

### Loyalty Data Sync  
```
File #1: lib/features/pages/body/main_laundry_body.dart
Line: 685-692
Visible at: Top menu bar → Tools → Admin → Loyalty Data Sync

File #2: lib/features/pages/header/Admin/showAdminMainPage.dart
Line: 122-160
Visible at: Tools page → Purple card (top priority section)
```

### Search History (NEW)
```
File: lib/features/pages/header/Admin/showAdminMainPage.dart
Line: 290-315
Visible at: Tools page → Indigo card (in middle of page)
```

---

## 📱 Visual App Navigation

```
┌─────────────────────────────────────────────────┐
│  App Home Screen                                 │
├─────────────────────────────────────────────────┤
│                                                  │
│  [☰ Menu]  Daily Routine  Rider  Tools  Logout │
│                                      ▼           │
│                                  [Admin ▼]      │
│                                    ├─ 💸 Salary Correction
│                                    ├─ 🔄 Loyalty Data Sync
│                                    ├─ 📊 Jobs vs Loyalty
│                                    └─ ...more
│                                                  │
└─────────────────────────────────────────────────┘
```

---

## 📄 Admin Dashboard Layout (showAdminMainPage.dart)

```
┌────────────────────────────────────────────┐
│ Tools                                    [↑] │
├────────────────────────────────────────────┤
│                                            │
│  [Edit Counter Section]                    │
│                                            │
│  [Purple Card]                             │
│  🔄 Loyalty Data Sync                      │ ← Line 122-160
│  Compare and sync loyalty records...       │
│                                            │
│  [Grey Card]                               │
│  📦 Batch Promo                            │
│                                            │
│  [Orange Card]                             │
│  🔍 Batch Promo Review                     │
│                                            │
│  [Orange Card]                             │
│  ⚙️ Fix PromoCounter                       │
│                                            │
│  [Blue Card]                               │
│  📊 Monthly Analytics                      │
│                                            │
│  ... (more cards) ...                      │
│                                            │
│  [Green Card]                              │
│  ⏱️ Auto Salary Date                        │
│                                            │
│  [INDIGO CARD]                             │
│  🔍 Search History                         │ ← Line 290-315 (NEW!)
│  View staff search activity...             │
│                                            │
│  [Teal Card]                               │
│  ✏️ Edit AutoSalaryDate                     │
│                                            │
│  ... (more cards below) ...                │
│                                            │
└────────────────────────────────────────────┘
```

---

## 🔗 File Structure Overview

### main_laundry_body.dart (Main Menu Bar)
```
File: lib/features/pages/body/main_laundry_body.dart

Line 673-679:  SALARY CORRECTION MENU ITEM
    └─ MenuItemButton
        └─ onPressed: showSalaryMaintenance()
        └─ child: '💸 Salary Correction'

Line 680-692:  LOYALTY DATA SYNC MENU ITEM  
    └─ MenuItemButton
        └─ onPressed: Navigate to SitVsLoyalty page
        └─ child: '🔄 Loyalty Data Sync'

Line 693+:     MORE MENU ITEMS
    └─ Jobs vs Loyalty
    └─ ...etc
```

### showAdminMainPage.dart (Admin Dashboard)
```
File: lib/features/pages/header/Admin/showAdminMainPage.dart

Line 1-50:       Imports & class definition
Line 51-120:     Edit Counter section
Line 122-160:    LOYALTY DATA SYNC CARD (Purple)
                 ├─ Icon: Icons.compare_arrows
                 ├─ Title: "🔄 Loyalty Data Sync"
                 ├─ Navigation: SitVsLoyalty()
                 └─ Color: Purple.shade50

Line 170-250:    Other menu cards...

Line 290-315:    SEARCH HISTORY CARD (Indigo) ← NEW!
                 ├─ Icon: Icons.history_edu
                 ├─ Title: "🔍 Search History"
                 ├─ Navigation: SearchHistoryPage()
                 └─ Color: Indigo.shade100

Line 320+:       Auto Salary Date & Edit sections
```

---

## 🖼️ Before & After

### BEFORE (Without Search History)
```
Tools Admin Dashboard Cards (in order):
1. Edit Counter
2. 🔄 Loyalty Data Sync (Purple)
3. 📦 Batch Promo (Grey)
4. 🔍 Batch Promo Review (Orange)
5. ⚙️ Fix PromoCounter (Orange)
6. 📊 Monthly Analytics (Blue)
7. ... more cards ...
8. ⏱️ Auto Salary Date (Green)
9. ✏️ Edit AutoSalaryDate (Teal)
```

### AFTER (With Search History)
```
Tools Admin Dashboard Cards (in order):
1. Edit Counter
2. 🔄 Loyalty Data Sync (Purple)
3. 📦 Batch Promo (Grey)
4. 🔍 Batch Promo Review (Orange)
5. ⚙️ Fix PromoCounter (Orange)
6. 📊 Monthly Analytics (Blue)
7. ... more cards ...
8. ⏱️ Auto Salary Date (Green)
9. 🔍 Search History (Indigo) ← NEW!
10. ✏️ Edit AutoSalaryDate (Teal)
```

---

## 🎨 Color Coding

| Menu Item | Color | File | Line |
|-----------|-------|------|------|
| Salary Correction | - | main_laundry_body.dart | 676 |
| Loyalty Data Sync (Menu) | - | main_laundry_body.dart | 685 |
| Loyalty Data Sync (Card) | 🟪 Purple | showAdminMainPage.dart | 122 |
| Search History | 🟦 Indigo | showAdminMainPage.dart | 290 |

---

## 🔎 How to Find Them in Code

### Find Salary Correction
```dart
// Open: lib/features/pages/body/main_laundry_body.dart
// Search for: "Salary Correction"
// Line: ~676

MenuItemButton(
  onPressed: () => showSalaryMaintenance(context),
  child: const Text('💸 Salary Correction'),  ← HERE
),
```

### Find Loyalty Data Sync (Menu Version)
```dart
// Open: lib/features/pages/body/main_laundry_body.dart
// Search for: "Loyalty Data Sync"
// Line: ~685

child: const Text('🔄 Loyalty Data Sync'),  ← HERE
```

### Find Loyalty Data Sync (Dashboard Version)
```dart
// Open: lib/features/pages/header/Admin/showAdminMainPage.dart
// Search for: "Loyalty Data Sync"
// Line: ~136

title: Text(
  "🔄 Loyalty Data Sync",  ← HERE
  style: TextStyle(...),
),
```

### Find Search History (NEW)
```dart
// Open: lib/features/pages/header/Admin/showAdminMainPage.dart
// Search for: "Search History"
// Line: ~303

title: Text(
  "Search History",  ← HERE
  style: TextStyle(...),
),
```

---

## 📋 Summary

| Item | Location File | Line # | Menu Type | Color |
|------|---------------|--------|-----------|-------|
| **Salary Correction** | main_laundry_body.dart | 676-679 | Dropdown | - |
| **Loyalty Data Sync** | main_laundry_body.dart | 685-692 | Dropdown | - |
| **Loyalty Data Sync** | showAdminMainPage.dart | 122-160 | Dashboard Card | 🟪 Purple |
| **Search History** | showAdminMainPage.dart | 290-315 | Dashboard Card | 🟦 Indigo |

---

## ✅ You Now Know

✅ Where Salary Correction is located  
✅ Where Loyalty Data Sync appears (2 locations)  
✅ Where Search History was added  
✅ Exact line numbers for all items  
✅ Which files to edit to modify menus  

---

**Need to make changes?**
- Edit menu order → Edit `main_laundry_body.dart`
- Edit dashboard layout → Edit `showAdminMainPage.dart`
- Add new items → Add to the appropriate file above
