# Employee Collections Access Summary

## Collections Overview

### **EmployeeCurr** (Current Employee Data)
- **Database**: primaryFirestore (main)
- **Reference**: `EMPLOYEE_CURR_REF = "EmployeeCurr"`
- **Service Class**: `DatabaseEmployeeCurrent`

### **EmployeeHist** (Employee History/Transactions)
- **Database**: primaryFirestore (main)
- **Reference**: `EMPLOYEE_HIST_REF = "EmployeeHist"`
- **Service Class**: `DatabaseEmployeeHist`

---

## Files That Access These Collections

### 1. **UI Display Pages**

#### `lib/features/pages/body/Employee/readDataEmployeeCurr.dart`
- **Purpose**: Display current employee data in a table
- **Collections Used**: EmployeeCurr
- **Operations**: READ (streaming)
- **Database**: primaryFirestore
- **Key Methods**:
  - `DatabaseEmployeeCurrent()` - reads all employee current records
  - Displays employee names, current stocks, and balances
  - Shows dark mode support

#### `lib/features/pages/body/Employee/readDataEmployeeHist.dart`
- **Purpose**: Display employee transaction history with pagination
- **Collections Used**: EmployeeHist
- **Operations**: READ (streaming + pagination)
- **Database**: primaryFirestore
- **Key Methods**:
  - `DatabaseEmployeeHist.getEmployeeHistory()` - live stream
  - `DatabaseEmployeeHist.getEmployeeHistoryPaginated()` - paginated queries
  - Supports filtering by employee ID
  - Loads 20 records per page

#### `lib/features/pages/body/main_laundry_body.dart`
- **Purpose**: Main body page that displays both employee widgets
- **Collections Used**: EmployeeCurr, EmployeeHist
- **Operations**: DISPLAY (calls both readDataEmployeeCurr and readDataEmployeeHist)
- **Database**: primaryFirestore

---

### 2. **Database Service Classes**

#### `lib/core/services/database_employee_current.dart`
- **Class**: `DatabaseEmployeeCurrent`
- **Collection**: EmployeeCurr
- **Database**: primaryFirestore
- **Operations**:
  - `addEmployeeCurr()` - Add new employee current record
  - `streamAll()` - Stream all employee current records
  - Other CRUD operations

#### `lib/core/services/database_employee_hist.dart`
- **Class**: `DatabaseEmployeeHist`
- **Collection**: EmployeeHist
- **Database**: primaryFirestore
- **Operations**:
  - `getEmployeeHistory()` - Stream employee history (with optional filter)
  - `getEmployeeHistoryPaginated()` - Paginated query for history
  - Supports filtering by EmpId
  - Special handling for admin users ('Ket', 'DonF')

---

### 3. **Shared Methods**

#### `lib/core/utils/sharedmethodsdatabase.dart`
- **Purpose**: Shared database operations
- **Collections Used**: EmployeeCurr
- **Operations**: INSERT
- **Database**: primaryFirestore
- **Key Function**:
  - Uses `DatabaseEmployeeCurrent.addEmployeeCurr()` to insert employee current records
  - Called when processing employee transactions

---

### 4. **Migration**

#### `lib/features/pages/header/Admin/subAdmin/migrateToThird.dart`
- **Purpose**: Migrate collections to reports database
- **Collections Included**: EmployeeCurr, EmployeeHist
- **Source Database**: primaryFirestore
- **Destination Database**: reportsDb (thirdWeb)
- **Operations**: Full collection migration with optional delete-first option

---

## Access Pattern Summary

```
┌─────────────────────────────────────────────────────────────┐
│                    PRIMARY FIRESTORE                         │
│                                                              │
│  ┌──────────────────┐         ┌──────────────────┐          │
│  │  EmployeeCurr    │         │  EmployeeHist    │          │
│  └────────┬─────────┘         └────────┬─────────┘          │
│           │                            │                    │
│  ┌────────▼──────────────────────────────▼────────┐         │
│  │  DatabaseEmployeeCurrent                       │         │
│  │  DatabaseEmployeeHist                          │         │
│  └────────┬──────────────────────────────┬────────┘         │
│           │                              │                  │
│  ┌────────▼──────────┐      ┌────────────▼──────────┐       │
│  │readDataEmployee   │      │readDataEmployeeHist   │       │
│  │Curr.dart          │      │.dart                  │       │
│  └────────┬──────────┘      └────────────┬──────────┘       │
│           │                              │                  │
│  ┌────────▼──────────────────────────────▼────────┐         │
│  │  main_laundry_body.dart (Display)              │         │
│  └──────────────────────────────────────────────────┘       │
│                                                              │
│  ┌──────────────────────────────────────────────────┐       │
│  │  sharedmethodsdatabase.dart (Insert)            │       │
│  └──────────────────────────────────────────────────┘       │
│                                                              │
│  ┌──────────────────────────────────────────────────┐       │
│  │  migrateToThird.dart (Migrate to reportsDb)     │       │
│  └──────────────────────────────────────────────────┘       │
└─────────────────────────────────────────────────────────────┘
```

---

## Current Database Location

| Collection | Database | Status |
|-----------|----------|--------|
| EmployeeCurr | primaryFirestore | ✅ Active |
| EmployeeHist | primaryFirestore | ✅ Active |

---

## Access Summary Table

| File | Collection | Operation | Database | Purpose |
|------|-----------|-----------|----------|---------|
| readDataEmployeeCurr.dart | EmployeeCurr | READ | primaryFirestore | Display current employee data |
| readDataEmployeeHist.dart | EmployeeHist | READ | primaryFirestore | Display employee history |
| main_laundry_body.dart | Both | DISPLAY | primaryFirestore | Main UI page |
| database_employee_current.dart | EmployeeCurr | CRUD | primaryFirestore | Service layer |
| database_employee_hist.dart | EmployeeHist | READ | primaryFirestore | Service layer |
| sharedmethodsdatabase.dart | EmployeeCurr | INSERT | primaryFirestore | Shared operations |
| migrateToThird.dart | Both | MIGRATE | primaryFirestore → reportsDb | Migration tool |

---

## Notes

- Both collections are currently on **primaryFirestore**
- No separation to different databases yet (unlike GCash, Jobs_done, Loyalty)
- Employee data is read-heavy (display pages)
- Employee current data is written when processing transactions
- Both collections are included in migration to reports database
