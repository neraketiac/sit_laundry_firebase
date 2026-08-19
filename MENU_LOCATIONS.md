# Menu Items Location Guide

## 📍 Where Are These Menus Located?

### 1. Salary Correction

**File Location:**
```
lib/features/pages/body/main_laundry_body.dart
Line: ~676-679
```

**Code:**
```dart
MenuItemButton(
  onPressed: () => showSalaryMaintenance(context),
  child: const Text('💸 Salary Correction'),
),
```

**Menu Structure:**
- Main menu dropdown
- Under: Tools > Admin submenu
- Part of the horizontal menu bar at the top

---

### 2. Loyalty Data Sync

**File Locations (appears in 2 places):**

#### A. Main Menu Bar
```
lib/features/pages/body/main_laundry_body.dart
Line: ~685-692
```

**Code:**
```dart
MenuItemButton(
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Loyalty Data Sync')),
        body: const SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: SitVsLoyalty()
        )
      )
    )
  ),
  child: const Text('🔄 Loyalty Data Sync'),
),
```

**Menu Structure:**
- Main menu dropdown
- Under: Tools > Admin submenu
- Right after Salary Correction

#### B. Admin Dashboard (Tools Page)
```
lib/features/pages/header/Admin/showAdminMainPage.dart
Line: ~122-160
```

**Code:**
```dart
if (isAdmin)
  Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.purple.shade700, width: 2),
      borderRadius: BorderRadius.circular(8),
      color: Colors.purple.shade50,
    ),
    child: ListTile(
      leading: const Icon(Icons.compare_arrows, color: Colors.purple),
      title: Text(
        "🔄 Loyalty Data Sync",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.purple.shade900,
        ),
      ),
      subtitle: Text(
        "Compare and sync loyalty records between Primary DB and Loyalty DB",
        style: TextStyle(color: Colors.purple.shade700),
      ),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        // Navigation code...
      },
    ),
  ),
```

**Menu Structure:**
- Appears in Admin dashboard page
- Displayed as a purple card with border
- Early in the list (one of the first items)

---

## 🗺️ Menu Hierarchy

```
Main App
├── Menu Bar (Horizontal at top)
│   ├── Daily Routine
│   ├── Rider
│   ├── Tools
│   │   └── Admin
│   │       ├── 💸 Salary Correction
│   │       ├── 🔄 Loyalty Data Sync
│   │       ├── 📊 Jobs vs Loyalty
│   │       └── ... more items
│   └── Logout
│
└── Tools Page (Accessed via Tools menu)
    ├── 🔄 Loyalty Data Sync (Purple card - top priority)
    ├── 📋 Batch Promo
    ├── 🔍 Batch Promo Review
    ├── ⚡ Fix PromoCounter
    ├── 📊 Monthly Analytics
    ├── 🚴 Rider Schedule
    ├── ✅ Loyalty Count Validation
    ├── 🔍 Search History ← NEW!
    ├── ... and more
```

---

## 📋 Where Search History Was Added

**File Location:**
```
lib/features/pages/header/Admin/showAdminMainPage.dart
Line: ~290-315 (after AutoSalaryDate section)
```

**Code:**
```dart
if (isAdmin)
  Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.indigo.shade100,
      borderRadius: BorderRadius.circular(8),
    ),
    child: ListTile(
      leading: const Icon(Icons.history_edu, color: Colors.indigo),
      title: Text(
        "Search History",
        style: TextStyle(color: Colors.indigo.shade900),
      ),
      subtitle: Text(
        "View staff search activity - Customer Name, Staff Name, Date & Time",
        style: TextStyle(color: Colors.indigo.shade700),
      ),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchHistoryPage()),
        );
      },
    ),
  ),
```

**Location in Admin Dashboard:**
- Purple and other cards are above it
- Green "Auto Salary Date" card is just before it
- Teal "Edit AutoSalaryDate" card comes after it

---

## 🔍 File Overview

### main_laundry_body.dart
- **Purpose**: Main menu bar configuration
- **Location**: `lib/features/pages/body/main_laundry_body.dart`
- **Contains**: 
  - Salary Correction menu item (~line 676)
  - Loyalty Data Sync menu item (~line 685)
  - Links to all Tools > Admin menu items

### showAdminMainPage.dart
- **Purpose**: Admin dashboard/Tools page
- **Location**: `lib/features/pages/header/Admin/showAdminMainPage.dart`
- **Contains**: 
  - All admin cards displayed vertically
  - Loyalty Data Sync card (~line 122)
  - Search History card (~line 290) ← NEW!
  - All other admin functions

---

## 🎯 Understanding the Menu System

### Two Ways to Access These Features

**1. Via Menu Bar (Horizontal):**
- Look at top right of app
- Click "Tools" menu
- Click "Admin" submenu
- Shows: Salary Correction, Loyalty Data Sync, Jobs vs Loyalty
- Defined in: `main_laundry_body.dart`

**2. Via Admin Dashboard (Tools Page):**
- Click "Tools" menu
- Click "Admin" submenu
- A full page opens with many cards
- Loyalty Data Sync appears as a purple card
- Search History appears as an indigo card
- Defined in: `showAdminMainPage.dart`

---

## 📝 Summary Table

| Item | File | Lines | Type | Status |
|------|------|-------|------|--------|
| **Salary Correction** | main_laundry_body.dart | ~676-679 | Menu Item | Existing |
| **Loyalty Data Sync** (Menu) | main_laundry_body.dart | ~685-692 | Menu Item | Existing |
| **Loyalty Data Sync** (Card) | showAdminMainPage.dart | ~122-160 | Dashboard Card | Existing |
| **Search History** | showAdminMainPage.dart | ~290-315 | Dashboard Card | NEW ✅ |

---

## ⚠️ Important Notes

- **Salary Correction**: Accessed via menu dropdown
- **Loyalty Data Sync**: Appears in BOTH menu dropdown AND admin dashboard
- **Search History**: Only in admin dashboard (indigo card)
- All require `isAdmin = true` to be visible
- Both files use navigation to open pages

---

**If you want to:**
- Modify menu order → Edit `main_laundry_body.dart`
- Modify dashboard layout → Edit `showAdminMainPage.dart`
- Add more menu items → Add to either file above
