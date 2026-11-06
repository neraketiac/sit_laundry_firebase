import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/features/jobs/models/jobmodel.dart';
import 'package:laundry_firebase/core/global/variables.dart';

/// Admin Remarks Tracker
/// Detects field changes and records them in format:
/// fieldName: (MMDDYYYY HH:MI:SS/person/value)(MMDDYYYY HH:MI:SS/person/value)...
///
/// Scope: Jobs_queue, Jobs_ongoing, Jobs_done ONLY (not Jobs_completed)
class AdminRemarksTracker {
  /// Compare old and new job models and generate audit trail entries
  /// Returns updated adminRemarks string with new changes appended
  static String trackChanges({
    required JobModel oldJob,
    required JobModel newJob,
  }) {
    final changes = <String>[];
    final now = DateTime.now();
    final timestamp = DateFormat('MMddyyyy HH:mm:ss').format(now);
    final person = empIdGlobal;

    // Check all fields for changes
    _compareField(
        'jobId', oldJob.jobId, newJob.jobId, changes, timestamp, person);
    _compareField(
        'dateQ', oldJob.dateQ, newJob.dateQ, changes, timestamp, person);
    _compareField(
        'needOn', oldJob.needOn, newJob.needOn, changes, timestamp, person);
    _compareField(
        'dateO', oldJob.dateO, newJob.dateO, changes, timestamp, person);
    _compareField(
        'paidD', oldJob.paidD, newJob.paidD, changes, timestamp, person);
    _compareField(
        'dateD', oldJob.dateD, newJob.dateD, changes, timestamp, person);
    _compareField(
        'dateC', oldJob.dateC, newJob.dateC, changes, timestamp, person);
    _compareField('customerPickupDate', oldJob.customerPickupDate,
        newJob.customerPickupDate, changes, timestamp, person);
    _compareField('riderDeliveryDate', oldJob.riderDeliveryDate,
        newJob.riderDeliveryDate, changes, timestamp, person);

    _compareField('customerId', oldJob.customerId, newJob.customerId, changes,
        timestamp, person);
    _compareField('customerName', oldJob.customerName, newJob.customerName,
        changes, timestamp, person);
    _compareField(
        'address', oldJob.address, newJob.address, changes, timestamp, person);

    _compareField('forSorting', oldJob.forSorting, newJob.forSorting, changes,
        timestamp, person);
    _compareField('riderPickup', oldJob.riderPickup, newJob.riderPickup,
        changes, timestamp, person);
    _compareField('isCustomerPickedUp', oldJob.isCustomerPickedUp,
        newJob.isCustomerPickedUp, changes, timestamp, person);
    _compareField('isDeliveredToCustomer', oldJob.isDeliveredToCustomer,
        newJob.isDeliveredToCustomer, changes, timestamp, person);

    _compareField(
        'perKilo', oldJob.perKilo, newJob.perKilo, changes, timestamp, person);
    _compareField(
        'perLoad', oldJob.perLoad, newJob.perLoad, changes, timestamp, person);
    _compareField('finalKilo', oldJob.finalKilo, newJob.finalKilo, changes,
        timestamp, person);
    _compareField('finalLoad', oldJob.finalLoad, newJob.finalLoad, changes,
        timestamp, person);
    _compareField('finalDry', oldJob.finalDry, newJob.finalDry, changes,
        timestamp, person);
    _compareField('finalLoadForBonus', oldJob.finalLoadForBonus,
        newJob.finalLoadForBonus, changes, timestamp, person);
    _compareField('finalPrice', oldJob.finalPrice, newJob.finalPrice, changes,
        timestamp, person);
    _compareField('promoCounter', oldJob.promoCounter, newJob.promoCounter,
        changes, timestamp, person);
    _compareField('pricingSetup', oldJob.pricingSetup, newJob.pricingSetup,
        changes, timestamp, person);

    _compareField(
        'regular', oldJob.regular, newJob.regular, changes, timestamp, person);
    _compareField('sayosabon', oldJob.sayosabon, newJob.sayosabon, changes,
        timestamp, person);
    _compareField(
        'addOn', oldJob.addOn, newJob.addOn, changes, timestamp, person);
    _compareField('fold', oldJob.fold, newJob.fold, changes, timestamp, person);
    _compareField('mix', oldJob.mix, newJob.mix, changes, timestamp, person);

    _compareField(
        'basket', oldJob.basket, newJob.basket, changes, timestamp, person);
    _compareField('ebag', oldJob.ebag, newJob.ebag, changes, timestamp, person);
    _compareField('sako', oldJob.sako, newJob.sako, changes, timestamp, person);

    _compareField(
        'unpaid', oldJob.unpaid, newJob.unpaid, changes, timestamp, person);
    _compareField('paidCash', oldJob.paidCash, newJob.paidCash, changes,
        timestamp, person);
    _compareField('paidGCash', oldJob.paidGCash, newJob.paidGCash, changes,
        timestamp, person);
    _compareField('paidGCashverified', oldJob.paidGCashverified,
        newJob.paidGCashverified, changes, timestamp, person);
    _compareField('paidCashAmount', oldJob.paidCashAmount,
        newJob.paidCashAmount, changes, timestamp, person);
    _compareField('paidGCashAmount', oldJob.paidGCashAmount,
        newJob.paidGCashAmount, changes, timestamp, person);
    _compareField('paymentReceivedBy', oldJob.paymentReceivedBy,
        newJob.paymentReceivedBy, changes, timestamp, person);
    _compareField('gcashReceiptUrl', oldJob.gcashReceiptUrl,
        newJob.gcashReceiptUrl, changes, timestamp, person);

    _compareField(
        'remarks', oldJob.remarks, newJob.remarks, changes, timestamp, person);

    _compareField('processStep', oldJob.processStep, newJob.processStep,
        changes, timestamp, person);
    _compareField('allStatus', oldJob.allStatus, newJob.allStatus, changes,
        timestamp, person);

    _compareField('forDisposal', oldJob.forDisposal, newJob.forDisposal,
        changes, timestamp, person);
    _compareField('disposed', oldJob.disposed, newJob.disposed, changes,
        timestamp, person);

    _compareField('promoErrorCode', oldJob.promoErrorCode,
        newJob.promoErrorCode, changes, timestamp, person);
    _compareField('requestForAdmin', oldJob.requestForAdmin,
        newJob.requestForAdmin, changes, timestamp, person);

    // Append new changes to existing adminRemarks
    final updatedRemarks = oldJob.adminRemarks + changes.join('');
    return updatedRemarks;
  }

  /// Helper to compare two values and add to changes if different
  static void _compareField<T>(
    String fieldName,
    T oldValue,
    T newValue,
    List<String> changes,
    String timestamp,
    String person,
  ) {
    if (oldValue != newValue) {
      final value = _formatValue(newValue);
      changes.add('$fieldName:($timestamp/$person/$value)');
    }
  }

  /// Format value for logging
  static String _formatValue(dynamic value) {
    if (value is Timestamp) {
      return DateFormat('MMddyyyy HH:mm:ss').format(value.toDate());
    }
    return value.toString();
  }
}
