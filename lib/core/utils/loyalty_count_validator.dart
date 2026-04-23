import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:laundry_firebase/features/jobs/models/jobmodel.dart';
import 'package:laundry_firebase/core/global/variables_oth.dart';

/// Utility class to validate loyalty counts against applicable promoCounter
class LoyaltyCountValidator {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Calculate total applicable promoCounter for a customer based on promoErrorCode logic
  int calculateApplicablePromoCounter(List<JobModel> customerJobs) {
    // Sort jobs by dateD descending (latest first)
    customerJobs.sort((a, b) => b.dateD.compareTo(a.dateD));
    
    int totalApplicable = 0;
    int promoFreeRedemptions = 0;
    
    for (final job in customerJobs) {
      // Check if job contains promoFree item
      final hasPromoFree = job.items.any((item) => item.itemUniqueId == promoFree.itemUniqueId);
      if (hasPromoFree) {
        promoFreeRedemptions += 10; // Each promoFree redemption costs 10 points
      }
      
      // If promoErrorCode is 0, include in promo
      if (job.promoErrorCode == 0) {
        totalApplicable += job.promoCounter;
      } else {
        // If promoErrorCode != 0, stop counting (all succeeding jobs are not included)
        break;
      }
    }
    
    // Subtract promoFree redemptions from total applicable
    return totalApplicable - promoFreeRedemptions;
  }

  /// Get loyalty count mismatches
  Future<Map<String, dynamic>> getLoyaltyMismatches() async {
    final mismatches = <Map<String, dynamic>>[];
    final customerJobsMap = <int, List<JobModel>>{};
    
    try {
      // Get all jobs from both collections
      final doneSnapshot = await _firestore.collection('Jobs_done').get();
      final completedSnapshot = await _firestore.collection('Jobs_completed').get();
      
      final allJobs = <JobModel>[];
      
      // Add Jobs_done
      for (final doc in doneSnapshot.docs) {
        try {
          allJobs.add(JobModel.fromJson(doc.data()));
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing Jobs_done document ${doc.id}: $e');
          }
        }
      }
      
      // Add Jobs_completed
      for (final doc in completedSnapshot.docs) {
        try {
          allJobs.add(JobModel.fromJson(doc.data()));
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing Jobs_completed document ${doc.id}: $e');
          }
        }
      }
      
      // Group jobs by customer
      for (final job in allJobs) {
        if (!customerJobsMap.containsKey(job.customerId)) {
          customerJobsMap[job.customerId] = [];
        }
        customerJobsMap[job.customerId]!.add(job);
      }
      
      // Get current loyalty counts from database
      final loyaltySnapshot = await _firestore.collection('Loyalty').get();
      final loyaltyMap = <int, int>{};
      
      for (final doc in loyaltySnapshot.docs) {
        try {
          final data = doc.data();
          final customerId = data['customerId'] as int;
          final loyaltyCount = data['loyaltyCount'] as int;
          loyaltyMap[customerId] = loyaltyCount;
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing Loyalty document ${doc.id}: $e');
          }
        }
      }
      
      // Check each customer
      for (final entry in customerJobsMap.entries) {
        final customerId = entry.key;
        final jobs = entry.value;
        
        if (jobs.isEmpty) continue;
        
        final applicablePromoCounter = calculateApplicablePromoCounter(jobs);
        final currentLoyaltyCount = loyaltyMap[customerId] ?? 0;
        
        if (applicablePromoCounter != currentLoyaltyCount) {
          // Get customer name from first job
          final customerName = jobs.first.customerName;
          
          // Count jobs by promoErrorCode
          final errorCodeCounts = <int, int>{};
          for (final job in jobs) {
            errorCodeCounts[job.promoErrorCode] = (errorCodeCounts[job.promoErrorCode] ?? 0) + 1;
          }
          
          // Get breakdown of applicable jobs
          final applicableJobs = jobs.where((j) => j.promoErrorCode == 0).toList();
          final totalApplicablePromoCounter = applicableJobs.fold<int>(0, (sum, job) => sum + job.promoCounter);
          
          // Count promoFree redemptions across all jobs
          final promoFreeRedemptions = jobs.where((job) => 
            job.items.any((item) => item.itemUniqueId == promoFree.itemUniqueId)
          ).length;
          final totalPromoFreeDeduction = promoFreeRedemptions * 10;
          
          mismatches.add({
            'customerId': customerId,
            'customerName': customerName,
            'currentLoyaltyCount': currentLoyaltyCount,
            'expectedLoyaltyCount': applicablePromoCounter,
            'difference': applicablePromoCounter - currentLoyaltyCount,
            'totalJobs': jobs.length,
            'applicableJobs': applicableJobs.length,
            'promoFreeRedemptions': promoFreeRedemptions,
            'totalPromoFreeDeduction': totalPromoFreeDeduction,
            'errorCodeBreakdown': errorCodeCounts,
            'totalApplicablePromoCounter': totalApplicablePromoCounter,
            'jobDetails': applicableJobs.map((job) => {
              'jobId': job.jobId,
              'dateD': job.dateD,
              'promoCounter': job.promoCounter,
              'promoErrorCode': job.promoErrorCode,
              'finalPrice': job.finalPrice,
              'hasPromoFree': job.items.any((item) => item.itemUniqueId == promoFree.itemUniqueId),
              'packageType': job.regular ? 'Regular' : job.sayosabon ? 'Sayosabon' : 'Others',
            }).toList(),
          });
        }
      }
      
      // Sort by difference (largest discrepancies first)
      mismatches.sort((a, b) => (b['difference'] as int).abs().compareTo((a['difference'] as int).abs()));
      
    } catch (e) {
      if (kDebugMode) {
        print('Error in getLoyaltyMismatches: $e');
      }
    }
    
    return {
      'mismatches': mismatches,
      'totalMismatches': mismatches.length,
      'totalCustomersChecked': customerJobsMap.length,
    };
  }

  /// Get summary statistics
  Future<Map<String, dynamic>> getSummaryStats() async {
    final stats = <String, dynamic>{
      'totalCustomers': 0,
      'totalJobs': 0,
      'totalPromoCounterSum': 0,
      'totalApplicablePromoCounter': 0,
      'totalPromoFreeRedemptions': 0,
      'totalPromoFreeDeduction': 0,
      'totalLoyaltyPoints': 0,
      'errorCodeBreakdown': <int, int>{},
      'packageTypeBreakdown': <String, int>{},
    };

    try {
      // Get all jobs
      final doneSnapshot = await _firestore.collection('Jobs_done').get();
      final completedSnapshot = await _firestore.collection('Jobs_completed').get();
      
      final allJobs = <JobModel>[];
      
      for (final doc in doneSnapshot.docs) {
        try {
          allJobs.add(JobModel.fromJson(doc.data()));
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing Jobs_done document ${doc.id}: $e');
          }
        }
      }
      
      for (final doc in completedSnapshot.docs) {
        try {
          allJobs.add(JobModel.fromJson(doc.data()));
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing Jobs_completed document ${doc.id}: $e');
          }
        }
      }

      // Group by customer
      final customerJobsMap = <int, List<JobModel>>{};
      for (final job in allJobs) {
        if (!customerJobsMap.containsKey(job.customerId)) {
          customerJobsMap[job.customerId] = [];
        }
        customerJobsMap[job.customerId]!.add(job);
      }

      stats['totalCustomers'] = customerJobsMap.length;
      stats['totalJobs'] = allJobs.length;

      // Calculate stats
      for (final job in allJobs) {
        stats['totalPromoCounterSum'] += job.promoCounter;
        
        // Check for promoFree redemptions
        final hasPromoFree = job.items.any((item) => item.itemUniqueId == promoFree.itemUniqueId);
        if (hasPromoFree) {
          stats['totalPromoFreeRedemptions']++;
          stats['totalPromoFreeDeduction'] += 10;
        }
        
        // Error code breakdown
        final errorCode = job.promoErrorCode;
        stats['errorCodeBreakdown'][errorCode] = (stats['errorCodeBreakdown'][errorCode] ?? 0) + 1;
        
        // Package type breakdown
        String packageType = 'Others';
        if (job.regular) packageType = 'Regular';
        else if (job.sayosabon) packageType = 'Sayosabon';
        
        stats['packageTypeBreakdown'][packageType] = (stats['packageTypeBreakdown'][packageType] ?? 0) + 1;
      }

      // Calculate applicable promo counter for each customer
      for (final jobs in customerJobsMap.values) {
        stats['totalApplicablePromoCounter'] += calculateApplicablePromoCounter(jobs);
      }

      // Get total loyalty points
      final loyaltySnapshot = await _firestore.collection('Loyalty').get();
      for (final doc in loyaltySnapshot.docs) {
        try {
          final data = doc.data();
          final loyaltyCount = data['loyaltyCount'] as int;
          stats['totalLoyaltyPoints'] += loyaltyCount;
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing Loyalty document ${doc.id}: $e');
          }
        }
      }

    } catch (e) {
      if (kDebugMode) {
        print('Error in getSummaryStats: $e');
      }
    }

    return stats;
  }
}