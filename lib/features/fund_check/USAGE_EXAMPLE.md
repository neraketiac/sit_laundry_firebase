# Fund Check Feature - Usage Examples

## Overview
The fund check feature validates whether users have completed their daily fund checks at specific times.

## Time Periods
- **Morning**: Before 12:00 (noon)
- **Lunch**: 12:00 to 16:00 (before 4 PM)
- **Dinner**: 16:00 and after (4 PM and later)

## Service Methods

### 1. Validate Time-Based Fund Check
```dart
// In your action/button handler
final errorMessage = FundCheckService.validateTimeBasedFundCheck(fundCheck);

if (errorMessage != null) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(errorMessage)),
  );
  return; // Block the action
}

// Continue with your action
// ...
```

### 2. Get Current Time Period
```dart
String period = FundCheckService.getCurrentTimePeriod();
// Returns: 'morning', 'lunch', or 'dinner'
```

### 3. Check if Current Period is Required
```dart
bool isRequired = FundCheckService.isCurrentPeriodCheckRequired(fundCheck);
// Returns true if the current period check is enabled and not completed
```

### 4. Get User-Friendly Message
```dart
String message = FundCheckService.getCurrentPeriodMessage(fundCheck);
// Returns: "✅ morning fund check completed" or "❌ lunch fund check required"
```

## Usage in Widgets

### Example 1: Show Validation Status
```dart
@override
Widget build(BuildContext context) {
  return FundCheckValidator(
    fundCheck: fundCheck,
    onValidationPassed: () {
      // User passed validation
    },
  );
}
```

### Example 2: Block Action Until Fund Check is Complete
```dart
ElevatedButton(
  onPressed: () async {
    // Check if fund check is required
    final canProceed = await FundCheckValidator.showValidationDialog(
      context,
      fundCheck,
      title: 'Fund Check Required',
    );

    if (canProceed) {
      // Proceed with action
      _performAction();
    }
  },
  child: const Text('Start Day'),
)
```

### Example 3: Use Helper Function
```dart
ElevatedButton(
  onPressed: () async {
    // Simple one-liner check
    final canProceed = await checkFundCheckBeforeAction(context, fundCheck);

    if (canProceed) {
      // Proceed with action
      _performAction();
    }
  },
  child: const Text('Create Order'),
)
```

## Logic Flow

```
Current Time Check
    ↓
├─ < 12:00 (Morning)
│   └─ If morning_enable = true AND morning_check = false
│       └─ ❌ Show: "You need to fund check to proceed."
│
├─ 12:00 to 16:00 (Lunch)
│   └─ If lunch_enable = true AND lunch_check = false
│       └─ ❌ Show: "You need to fund check to proceed."
│
└─ >= 16:00 (Dinner)
    └─ If dinner_enable = true AND dinner_check = false
        └─ ❌ Show: "You need to fund check to proceed."

If check is completed → ✅ Proceed
```

## Integration Points

### Place where checks should happen:
1. **Before creating/processing orders** - Block order creation
2. **Before starting the day** - Block day initialization
3. **Before processing payments** - Block payment processing
4. **In main dashboard** - Show status warning

### Example Integration:
```dart
// In your order creation button
onPressed: () async {
  final fundCheck = await getFundCheckFromFirebase(); // Your method
  
  // Validate fund check first
  final errorMsg = FundCheckService.validateTimeBasedFundCheck(fundCheck);
  if (errorMsg != null) {
    showSnackBar(errorMsg);
    return;
  }
  
  // If validation passed, proceed with order creation
  createOrder();
},
```

## Fields Reference

### FundCheckModel Fields:
- `morningCheck`: bool - Whether morning check was completed
- `lunchCheck`: bool - Whether lunch check was completed
- `dinnerCheck`: bool - Whether dinner check was completed
- `morningEnable`: bool - Whether morning check is enabled (admin setting)
- `lunchEnable`: bool - Whether lunch check is enabled (admin setting)
- `dinnerEnable`: bool - Whether dinner check is enabled (admin setting)
- `logDate`: Timestamp - Date when checks were logged

## Admin Controls

The `_enable` fields allow admins to enable/disable checks:
- `morningEnable = false` → Morning checks are not required
- `lunchEnable = true` → Lunch checks are required
- `dinnerEnable = true` → Dinner checks are required
