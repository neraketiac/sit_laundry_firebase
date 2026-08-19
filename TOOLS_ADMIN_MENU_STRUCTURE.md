# Tools > Admin Menu Structure - Complete Guide

## 📍 File Location

**File**: `lib/features/pages/body/main_laundry_body.dart`  
**Lines**: 566-840  
**Menu Type**: Dropdown/Submenu buttons in AppBar

---

## 🗺️ Complete Menu Hierarchy

```
🔧 TOOLS (Main Menu - Line 835-840)
│
├── 🔢 Edit Counter
├── 🔢 Edit Promo Days  
├── 📍 Edit Customer Location
├── 🧺 Done → Completed
│
└── 🔑 ADMIN (Submenu - Line 674-838) [Only for admins - if (isAdmin)]
    │
    ├── 💸 Salary Correction (Line 675-679)
    ├── 🔄 Loyalty Data Sync (Line 680-692)
    ├── 📋 Jobs vs Loyalty (Line 693-705)
    ├── 🎁 Batch Promo (Line 706-715)
    ├── 🔍 Batch Promo Review (Line 716-723)
    ├── 🔧 Fix PromoCounter (Line 724-731)
    ├── 🚫 Remove Promo on Disabled Days (Line 732-740)
    ├── 📊 Monthly Analytics (Line 741-748)
    ├── ✓ Jobs Paid (Line 749-756)
    ├── 🏅 Loyalty Validation (Line 757-763)
    ├── ⚙️ Update Loyalty DB (Line 764-774)
    ├── 🔄 Migrate Reports DB (Line 775-788)
    ├── 📅 Admin Date D (Line 789-798)
    ├── 📦 Other Items (Line 799-805)
    ├── 🧴 Detergent Items (Line 806-812)
    ├── 🧺 Fabricon Items (Line 813-819)
    ├── 🫧 Bleach Items (Line 820-826)
    └── 💰 Auto Salary Date Batch (Line 827-834)
```

---

## 📝 Detailed Code Structure

### 1. **Tools Menu Opening** (Line 835-840)
```dart
SubmenuButton(
  menuChildren: [
    // All items below...
  ],
  child: const Text('🔧 Tools'),
)
```

**Contains**:
- Edit Counter
- Edit Promo Days
- Edit Customer Location
- Done → Completed
- **Admin submenu** (if isAdmin)

---

### 2. **Admin Submenu** (Line 674-838)
```dart
if (isAdmin)
  SubmenuButton(
    menuChildren: [
      // 18 admin menu items below...
    ],
    child: const Text('🔑 Admin'),
  )
```

**Only visible if**: `isAdmin == true`  
**Contains**: 18 menu items

---

## 📋 All Admin Submenu Items

### Item 1: Salary Correction (Line 675-679)
```dart
MenuItemButton(
  onPressed: () => showSalaryMaintenance(context),
  child: const Text('💸 Salary Correction'),
)
```
- Function: Opens salary maintenance page
- Icon: 💸

### Item 2: Loyalty Data Sync (Line 680-692)
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
)
```
- Displays: SitVsLoyalty widget
- Icon: 🔄

### Item 3: Jobs vs Loyalty (Line 693-705)
```dart
MenuItemButton(
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Jobs vs Loyalty')),
        body: const SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: SitVsLoyaltyJobs()
        )
      )
    )
  ),
  child: const Text('📋 Jobs vs Loyalty'),
)
```
- Displays: SitVsLoyaltyJobs widget
- Icon: 📋

### Item 4: Batch Promo (Line 706-715)
```dart
MenuItemButton(
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Batch Promo')),
        body: const BatchPromo()
      )
    )
  ),
  child: const Text('🎁 Batch Promo'),
)
```
- Icon: 🎁

### Item 5: Batch Promo Review (Line 716-723)
```dart
MenuItemButton(
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const BatchPromoReviewPage()
    )
  ),
  child: const Text('🔍 Batch Promo Review'),
)
```
- Icon: 🔍

### Item 6: Fix PromoCounter (Line 724-731)
```dart
MenuItemButton(
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const BatchFixPromoCounterPage()
    )
  ),
  child: const Text('🔧 Fix PromoCounter'),
)
```
- Icon: 🔧

### Item 7: Remove Promo on Disabled Days (Line 732-740)
```dart
MenuItemButton(
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const BatchRemovePromoDisabledDays()
    )
  ),
  child: const Text('🚫 Remove Promo on Disabled Days'),
)
```
- Icon: 🚫

### Item 8: Monthly Analytics (Line 741-748)
```dart
MenuItemButton(
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const MonthlyAnalyticsPage()
    )
  ),
  child: const Text('📊 Monthly Analytics'),
)
```
- Icon: 📊

### Item 9: Jobs Paid (Line 749-756)
```dart
MenuItemButton(
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const ShowJobsPaid()
    )
  ),
  child: const Text('✓ Jobs Paid'),
)
```
- Icon: ✓

### Item 10: Loyalty Validation (Line 757-763)
```dart
MenuItemButton(
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const LoyaltyValidationPage()
    )
  ),
  child: const Text('🏅 Loyalty Validation'),
)
```
- Icon: 🏅

### Item 11: Update Loyalty DB (Line 764-774)
```dart
MenuItemButton(
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Update Loyalty DB')),
        body: const UpdateLoyaltyDB()
      )
    )
  ),
  child: const Text('⚙️ Update Loyalty DB'),
)
```
- Icon: ⚙️

### Item 12: Migrate Reports DB (Line 775-788)
```dart
MenuItemButton(
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Update BackupDB')),
        body: const SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: UpdateBackUpDB()
        )
      )
    )
  ),
  child: const Text('🔄 Migrate Reports DB(BackupDB)'),
)
```
- Icon: 🔄

### Item 13: Admin Date D (Line 789-798)
```dart
MenuItemButton(
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Admin Date D')),
        body: const AdminDateDPage()
      )
    )
  ),
  child: const Text('📅 Admin Date D'),
)
```
- Icon: 📅

### Item 14: Other Items (Line 799-805)
```dart
MenuItemButton(
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const OtherItemsPage()
    )
  ),
  child: const Text('📦 Other Items'),
)
```
- Icon: 📦

### Item 15: Detergent Items (Line 806-812)
```dart
MenuItemButton(
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const DetItemsPage()
    )
  ),
  child: const Text('🧴 Detergent Items'),
)
```
- Icon: 🧴

### Item 16: Fabricon Items (Line 813-819)
```dart
MenuItemButton(
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const FabItemsPage()
    )
  ),
  child: const Text('🧺 Fabricon Items'),
)
```
- Icon: 🧺

### Item 17: Bleach Items (Line 820-826)
```dart
MenuItemButton(
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const BleItemsPage()
    )
  ),
  child: const Text('🫧 Bleach Items'),
)
```
- Icon: 🫧

### Item 18: Auto Salary Date Batch (Line 827-834)
```dart
MenuItemButton(
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const AutoSalaryDateOneTimeBatch()
    )
  ),
  child: const Text('💰 Auto Salary Date Batch'),
)
```
- Icon: 💰

---

## 🔍 Where to Find Items in Code

### Quick Navigation

| Item | Line Start | Line End |
|------|-----------|----------|
| Salary Correction | 675 | 679 |
| Loyalty Data Sync | 680 | 692 |
| Jobs vs Loyalty | 693 | 705 |
| Batch Promo | 706 | 715 |
| Batch Promo Review | 716 | 723 |
| Fix PromoCounter | 724 | 731 |
| Remove Promo (Disabled Days) | 732 | 740 |
| Monthly Analytics | 741 | 748 |
| Jobs Paid | 749 | 756 |
| Loyalty Validation | 757 | 763 |
| Update Loyalty DB | 764 | 774 |
| Migrate Reports DB | 775 | 788 |
| Admin Date D | 789 | 798 |
| Other Items | 799 | 805 |
| Detergent Items | 806 | 812 |
| Fabricon Items | 813 | 819 |
| Bleach Items | 820 | 826 |
| Auto Salary Date Batch | 827 | 834 |

---

## 📍 Add Search History to This Menu

To add Search History to the Tools > Admin submenu, add this code after line 834 (before the closing brace of menuChildren):

```dart
MenuItemButton(
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const SearchHistoryPage()
    )
  ),
  child: const Text('🔍 Search History'),
),
```

**Import needed**:
```dart
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/search_history_page.dart';
```

**Final location**: Would be Item 19, Line ~835-841

---

## ✅ Summary

**File**: `lib/features/pages/body/main_laundry_body.dart`  
**Lines**: 566-840  
**Main Menu**: 🔧 Tools  
**Submenu**: 🔑 Admin (only if isAdmin)  
**Items in Admin**: 18 items  
**Structure**: Nested SubmenuButton with MenuItemButton children  

All items use `Navigator.push()` to navigate to their respective pages. Each item has:
- Icon emoji
- Text label
- onPressed callback
- Navigation destination

