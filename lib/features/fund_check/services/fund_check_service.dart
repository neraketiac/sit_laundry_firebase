import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/features/fund_check/models/fund_check_model.dart';

class FundCheckService {
  /// Check if the given logDate is today
  static bool isToday(Timestamp logDate) {
    final today = DateTime.now();
    final logDateTime = logDate.toDate();

    return logDateTime.year == today.year &&
        logDateTime.month == today.month &&
        logDateTime.day == today.day;
  }

  /// Check if check fields should be disabled based on logDate
  /// Returns true if fields should be DISABLED (logDate is not today)
  static bool shouldDisableCheckFields(Timestamp logDate) {
    return !isToday(logDate);
  }

  /// Get the enabled state for all check fields
  /// Returns a map with the enabled state of each field
  static Map<String, bool> getCheckFieldsState(FundCheckModel fundCheck) {
    final isDisabled = shouldDisableCheckFields(fundCheck.logDate);

    return {
      'morningCheckEnabled': !isDisabled,
      'lunchCheckEnabled': !isDisabled,
      'dinnerCheckEnabled': !isDisabled,
    };
  }

  /// Get a message for the user when fields are disabled
  static String getDisabledMessage(Timestamp logDate) {
    final today = DateTime.now();
    final logDateTime = logDate.toDate();

    final difference = today.difference(logDateTime).inDays;

    if (difference == 1) {
      return 'These fields are locked (logged yesterday)';
    } else if (difference > 1) {
      return 'These fields are locked (logged $difference days ago)';
    }
    return 'These fields are locked';
  }

  /// Reset all check fields to false (for a new day)
  static FundCheckModel resetCheckFields(FundCheckModel fundCheck) {
    return fundCheck.copyWith(
      morningCheck: false,
      lunchCheck: false,
      dinnerCheck: false,
      logDate: Timestamp.now(),
    );
  }

  /// Time-based fund check validation
  /// Returns error message if fund check is required but not completed
  /// Returns null if no error (fund check is completed or not required)
  static String? validateTimeBasedFundCheck(FundCheckModel fundCheck) {
    final now = DateTime.now();
    final currentHour = now.hour;

    // Morning Check: Before 12:00 (noon)
    if (currentHour < 12) {
      if (fundCheck.morningEnable && !fundCheck.morningCheck) {
        return 'You need to fund check to proceed.';
      }
    }
    // Lunch Check: Between 12:00 and 16:00 (4 PM)
    else if (currentHour >= 12 && currentHour < 16) {
      if (fundCheck.lunchEnable && !fundCheck.lunchCheck) {
        return 'You need to fund check to proceed.';
      }
    }
    // Dinner Check: After 16:00 (4 PM)
    else if (currentHour >= 16) {
      if (fundCheck.dinnerEnable && !fundCheck.dinnerCheck) {
        return 'You need to fund check to proceed.';
      }
    }

    return null; // No error
  }

  /// Get the current time period (morning, lunch, dinner)
  static String getCurrentTimePeriod() {
    final now = DateTime.now();
    final currentHour = now.hour;

    if (currentHour < 12) {
      return 'morning';
    } else if (currentHour >= 12 && currentHour < 16) {
      return 'lunch';
    } else {
      return 'dinner';
    }
  }

  /// Get the current period check status
  static bool isCurrentPeriodCheckRequired(FundCheckModel fundCheck) {
    final now = DateTime.now();
    final currentHour = now.hour;

    if (currentHour < 12) {
      return fundCheck.morningEnable && !fundCheck.morningCheck;
    } else if (currentHour >= 12 && currentHour < 16) {
      return fundCheck.lunchEnable && !fundCheck.lunchCheck;
    } else {
      return fundCheck.dinnerEnable && !fundCheck.dinnerCheck;
    }
  }

  /// Get user-friendly message about current period
  static String getCurrentPeriodMessage(FundCheckModel fundCheck) {
    final period = getCurrentTimePeriod();
    final isRequired = isCurrentPeriodCheckRequired(fundCheck);

    if (!isRequired) {
      return '✅ $period fund check completed';
    } else {
      return '❌ $period fund check required';
    }
  }

  /// Check if it's a new day compared to logDate
  static bool isNewDay(Timestamp logDate) {
    final logDateTime = logDate.toDate();
    final today = DateTime.now();

    return logDateTime.year != today.year ||
        logDateTime.month != today.month ||
        logDateTime.day != today.day;
  }

  /// Reset checks to false (called at midnight or start of new day)
  static FundCheckModel resetChecksForNewDay(FundCheckModel fundCheck) {
    return fundCheck.copyWith(
      morningCheck: false,
      lunchCheck: false,
      dinnerCheck: false,
      logDate: Timestamp.now(),
    );
  }
}
