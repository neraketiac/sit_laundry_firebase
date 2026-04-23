import 'package:flutter/material.dart';

/// Centralized color palette for the entire app.
///
/// Groups:
///   - App Shell       : scaffold, appbar, menus
///   - Job Panels      : queue, ongoing, done, completed, rider, funds, employee, unpaid
///   - Supplies/Funds  : cash in/out, EOD, salary, stocks
///   - Payment/Status  : paid, unpaid, kulang, gcash
///   - Job Status      : sorting, rider pickup, washing states
///   - UI Components   : buttons, borders, surfaces, dialogs
///   - Analytics       : chart accent colors
///
/// Dark mode helpers at the bottom — pass `isDark` to get the right color.
class AppColors {
  AppColors._();

  // ─────────────────────────────────────────────────────────────────────────
  // APP SHELL
  // ─────────────────────────────────────────────────────────────────────────
  static const Color scaffoldLight = Color(0xFFD1C4E9); // deepPurple[100]
  static const Color scaffoldDark = Color(0xFF121212);

  static const Color appBarLight = scaffoldLight;
  static const Color appBarDark = Color(0xFF1E1E1E);

  static const Color appBarForegroundLight = Colors.black87;
  static const Color appBarForegroundDark = Colors.white;

  static const Color menuSurfaceLight = Colors.white;
  static const Color menuSurfaceDark = Color(0xFF232323);
  static const Color menuSelectedLight = Color(0xFFE0E0E0);
  static const Color menuSelectedDark = Color(0x1FFFFFFF);

  // ─────────────────────────────────────────────────────────────────────────
  // JOB PANELS  (matches LaundryColors + main_laundry_body panel colors)
  // ─────────────────────────────────────────────────────────────────────────
  static const Color gcashPanelLight = Colors.blue;
  static const Color gcashPanelDark = Color(0xFF102A43);

  /// Jobs on Queue panel — amber
  static const Color onQueueLight = Color(0xFFF4B400);
  static const Color onQueueDark = Color(0xFF7A5C00);

  /// Jobs Ongoing panel — blue
  static const Color ongoingLight = Color(0xFF2196F3);
  static const Color ongoingDark = Color(0xFF0D3A57);

  /// Jobs Done panel — green
  static const Color doneLight = Color(0xFF4CAF50);
  static const Color doneDark = Color(0xFF1E5A31);

  /// Jobs Completed panel — deep purple
  static const Color completedLight = Color(0xFF673AB7);
  static const Color completedDark = Color(0xFF35235E);

  /// Rider panel — teal shade
  static const Color riderPanelLight = Color(0xFFB2DFDB);
  static const Color riderPanelDark = Color(0xFF123C3C);

  /// Funds / Supplies panel
  static const Color fundsPanelLight = Color(0xFF856B0E); // cFundsInFundsOut
  static const Color fundsPanelDark = Color(0xFF3B2F12);

  /// Employee panel
  static const Color employeePanelLight =
      Colors.deepOrangeAccent; // cEmployeeMaintenance
  static const Color employeePanelDark = Color(0xFF4A2517);

  /// Unpaid panel
  static const Color unpaidPanelLight = Color(0xFFFFCDD2);
  static const Color unpaidPanelDark = Color(0xFF4A1F1F);

  // ─────────────────────────────────────────────────────────────────────────
  // SUPPLIES / FUNDS  (from variables_supplies.dart)
  // ─────────────────────────────────────────────────────────────────────────
  /// Stocks row background
  static const Color stocks = Color.fromRGBO(255, 251, 43, 0.452);

  /// Cash-out row
  static const Color cashOut =
      Color.from(alpha: 1, red: 0.667, green: 0.667, blue: 0.667);

  /// Cash-in row
  static const Color cashIn = Color.fromRGBO(120, 120, 120, 1);

  /// GCash fee row
  static const Color cashFee = Color.fromRGBO(120, 120, 120, 1);

  /// EOD funds check row — bright green
  static const Color fundsEOD = Color.fromRGBO(62, 255, 45, 1); // cFundsEOD

  /// EOD alternate / secondary
  static const Color fundsEOD2 = Color.fromRGBO(255, 92, 233, 1); // cFundsEOD2
  static const Color fundsEODShaded = Color.fromRGBO(255, 92, 233, 0.7);

  /// Money in/out rows
  static const Color moneyIn = Color.fromRGBO(177, 177, 177, 1);
  static const Color moneyOut = Color.fromRGBO(113, 113, 113, 1);

  /// Salary rows
  static const Color salaryCurrent = Colors.yellow;
  static const Color salaryIn = Color.fromRGBO(209, 99, 30, 1);
  static const Color salaryOut = Color.fromRGBO(255, 151, 86, 1);

  // ─────────────────────────────────────────────────────────────────────────
  // PAYMENT / STATUS  (visPaidUnpaidArea, visPaidUnPaid)
  // ─────────────────────────────────────────────────────────────────────────
  /// Unpaid / overdue
  static const Color unpaid = Colors.redAccent;

  /// KULANG — partial cash payment, not enough
  static const Color kulang = Colors.purpleAccent;

  /// Paid status
  static const Color paid = Colors.black87;
  static const Color paidSelected = Colors.deepPurple;

  /// GCash pending / unverified
  static const Color gcashPending = Colors.orangeAccent;

  /// Date age badges on job cards
  static const Color dateAgeSafe = Colors.transparent; // ≤ 7 days — no badge
  static const Color dateAgeWarning =
      Color(0xFFF57F17); // > 7 days — amber.shade700
  static const Color dateAgeDanger =
      Color(0xFFD32F2F); // > 14 days — red.shade600
  static const Color dateAgeCritical =
      Colors.black; // > 30 days — black bg, white text

  // ─────────────────────────────────────────────────────────────────────────
  // JOB STATUS  (backGroundStatusColor, job process steps)
  // ─────────────────────────────────────────────────────────────────────────
  /// For Sorting badge
  static const Color forSorting = Color(0xFF81C784); // green.shade300

  /// Rider Pickup badge
  static const Color riderPickupBadge = Colors.redAccent;

  /// Rider pickup indicator in queue (cRiderPickup)
  static const Color riderPickup = Color.fromRGBO(62, 255, 45, 1);

  /// Waiting step
  static const Color waiting = Color.fromRGBO(170, 170, 170, 1);

  /// Washing / Drying / Folding step
  static const Color washing = Color.fromRGBO(1, 255, 244, 1);

  /// Delivered / picked up — green
  static const Color delivered = Color(0xFF388E3C); // green.shade600

  // ─────────────────────────────────────────────────────────────────────────
  // UI COMPONENTS
  // ─────────────────────────────────────────────────────────────────────────
  /// General button accent
  static const Color buttonAccent =
      Color.fromRGBO(134, 218, 252, 0.733); // cButtons

  /// Admin section accent
  static const Color admin = Colors.blueGrey; // cAdmin

  /// GCash show button
  static const Color showGCash = Colors.lightBlueAccent; // cShowGCash

  /// Jobs on Queue panel color alias
  static const Color jobsOnQueue = Colors.blue; // cJobsOnQueue

  /// General border
  static const Color border = Colors.black54;

  /// Amber surface (decoAmber background)
  static const Color amberSurface = Color(0xFFFFF8E1); // amber[50]

  /// Light blue surface (decoLightBlue background)
  static const Color lightBlueSurface = Color(0xFFB3E5FC); // lightBlue[100]

  /// Dialog / payment screen background
  static const Color paymentDialog = Colors.lightBlue;

  /// Funds maintenance dialog background
  static const Color fundsMaintenance =
      Color.fromRGBO(62, 255, 45, 1); // same as fundsEOD

  /// Image preview barrier
  static const Color imagePreviewBarrier = Colors.black87;

  /// Disabled button / field
  static const Color disabled = Color(0xFF9E9E9E); // grey.shade400

  /// Enabled button accent (boxButtonElevated)
  static const Color buttonEnabled = Colors.greenAccent;

  /// Delete / danger action
  static const Color danger = Colors.redAccent;

  /// Override / warning action
  static const Color override_ = Colors.orange;

  // ─────────────────────────────────────────────────────────────────────────
  // ANALYTICS  (monthly_analytics charts)
  // ─────────────────────────────────────────────────────────────────────────
  static const Color analyticsExpenseAccent = Colors.orange;
  static const Color analyticsSalaryAccent = Colors.indigo;
  static const Color analyticsUnpaidAccent = Colors.red;
  static const Color analyticsRevenueAccent = Colors.teal;

  // ─────────────────────────────────────────────────────────────────────────
  // DARK MODE HELPERS
  // ─────────────────────────────────────────────────────────────────────────
  static Color scaffold(bool dark) => dark ? scaffoldDark : scaffoldLight;
  static Color appBar(bool dark) => dark ? appBarDark : appBarLight;
  static Color appBarForeground(bool dark) =>
      dark ? appBarForegroundDark : appBarForegroundLight;
  static Color menuSurface(bool dark) =>
      dark ? menuSurfaceDark : menuSurfaceLight;
  static Color menuSelected(bool dark) =>
      dark ? menuSelectedDark : menuSelectedLight;
  static Color gcashPanel(bool dark) => dark ? gcashPanelDark : gcashPanelLight;
  static Color onQueue(bool dark) => dark ? onQueueDark : onQueueLight;
  static Color ongoing(bool dark) => dark ? ongoingDark : ongoingLight;
  static Color done(bool dark) => dark ? doneDark : doneLight;
  static Color completed(bool dark) => dark ? completedDark : completedLight;
  static Color riderPanel(bool dark) => dark ? riderPanelDark : riderPanelLight;
  static Color fundsPanel(bool dark) => dark ? fundsPanelDark : fundsPanelLight;
  static Color employeePanel(bool dark) =>
      dark ? employeePanelDark : employeePanelLight;
  static Color unpaidPanel(bool dark) =>
      dark ? unpaidPanelDark : unpaidPanelLight;
}
