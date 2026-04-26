import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:laundry_firebase/core/services/firebase_service.dart';
import 'package:laundry_firebase/features/jobs/models/jobmodel.dart';
import 'package:laundry_firebase/core/global/variables_all_codes.dart';

/// Utility class to batch fix promoCounter values in Jobs_done and Jobs_completed collections
class BatchFixPromoCounter {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final FirebaseFirestore _jobsDoneFirestore =
      FirebaseService.jobsDoneFirestore;

  /// Calculate correct promoCounter based on job data
  int calculateCorrectPromoCounter(JobModel job) {
    // For Regular Package (Per Kilo)
    if (job.regular && job.perKilo) {
      double kg = job.finalKilo;
      double remainder = kg % 8;
      int wholeEight = kg ~/ 8;

      if (remainder >= 3) {
        return wholeEight + 1;
      } else {
        return wholeEight;
      }
    }

    // For Regular Package (Per Load)
    if (job.regular && job.perLoad) {
      return job.finalLoad;
    }

    // For Others Package - count only premium items (155 and 195)
    if (job.addOn) {
      final onlyPromo = job.items.where((v) => v.itemId == menuOth155).length +
          job.items.where((v) => v.itemId == menuOth195).length;
      return onlyPromo;
    }

    // For Sayosabon Package - same as regular
    if (job.sayosabon) {
      if (job.perKilo) {
        double kg = job.finalKilo;
        double remainder = kg % 8;
        int wholeEight = kg ~/ 8;

        if (remainder >= 3) {
          return wholeEight + 1;
        } else {
          return wholeEight;
        }
      } else {
        return job.finalLoad;
      }
    }

    return 0; // Default fallback
  }

  /// Fix promoCounter for Jobs_done collection
  Future<Map<String, dynamic>> fixJobsDone() async {
    int totalProcessed = 0;
    int totalUpdated = 0;
    List<String> errors = [];

    try {
      // Get all documents from Jobs_done (from jobsDoneDb)
      final snapshot = await _jobsDoneFirestore.collection('Jobs_done').get();

      if (snapshot.docs.isEmpty) {
        return {
          'success': true,
          'message': 'No documents found in Jobs_done',
          'totalProcessed': 0,
          'totalUpdated': 0,
          'errors': []
        };
      }

      // Process in batches of 500 (Firestore batch limit)
      final batches = <WriteBatch>[];
      WriteBatch currentBatch = _jobsDoneFirestore.batch();
      int batchCount = 0;

      for (final doc in snapshot.docs) {
        try {
          totalProcessed++;

          final jobModel = JobModel.fromJson(doc.data());
          final correctPromoCounter = calculateCorrectPromoCounter(jobModel);

          // Only update if promoCounter is different
          if (jobModel.promoCounter != correctPromoCounter) {
            currentBatch.update(doc.reference, {
              'Q06_PromoCounter': correctPromoCounter,
            });

            totalUpdated++;
            batchCount++;

            if (kDebugMode) {
              print(
                  'Jobs_done - ${jobModel.customerName} (${jobModel.jobId}): ${jobModel.promoCounter} → $correctPromoCounter');
            }
          }

          // Create new batch if current one reaches 500 operations
          if (batchCount >= 500) {
            batches.add(currentBatch);
            currentBatch = _jobsDoneFirestore.batch();
            batchCount = 0;
          }
        } catch (e) {
          errors.add('Error processing document ${doc.id}: $e');
          if (kDebugMode) {
            print('Error processing Jobs_done document ${doc.id}: $e');
          }
        }
      }

      // Add the last batch if it has operations
      if (batchCount > 0) {
        batches.add(currentBatch);
      }

      // Commit all batches
      for (final batch in batches) {
        await batch.commit();
      }
    } catch (e) {
      errors.add('Error in fixJobsDone: $e');
      if (kDebugMode) {
        print('Error in fixJobsDone: $e');
      }
    }

    return {
      'success': errors.isEmpty,
      'collection': 'Jobs_done',
      'totalProcessed': totalProcessed,
      'totalUpdated': totalUpdated,
      'errors': errors
    };
  }

  /// Fix promoCounter for Jobs_completed collection
  Future<Map<String, dynamic>> fixJobsCompleted() async {
    int totalProcessed = 0;
    int totalUpdated = 0;
    List<String> errors = [];

    try {
      // Get all documents from Jobs_completed
      final snapshot = await _firestore.collection('Jobs_completed').get();

      if (snapshot.docs.isEmpty) {
        return {
          'success': true,
          'message': 'No documents found in Jobs_completed',
          'totalProcessed': 0,
          'totalUpdated': 0,
          'errors': []
        };
      }

      // Process in batches of 500 (Firestore batch limit)
      final batches = <WriteBatch>[];
      WriteBatch currentBatch = _firestore.batch();
      int batchCount = 0;

      for (final doc in snapshot.docs) {
        try {
          totalProcessed++;

          final jobModel = JobModel.fromJson(doc.data());
          final correctPromoCounter = calculateCorrectPromoCounter(jobModel);

          // Only update if promoCounter is different
          if (jobModel.promoCounter != correctPromoCounter) {
            currentBatch.update(doc.reference, {
              'Q06_PromoCounter': correctPromoCounter,
            });

            totalUpdated++;
            batchCount++;

            if (kDebugMode) {
              print(
                  'Jobs_completed - ${jobModel.customerName} (${jobModel.jobId}): ${jobModel.promoCounter} → $correctPromoCounter');
            }
          }

          // Create new batch if current one reaches 500 operations
          if (batchCount >= 500) {
            batches.add(currentBatch);
            currentBatch = _firestore.batch();
            batchCount = 0;
          }
        } catch (e) {
          errors.add('Error processing document ${doc.id}: $e');
          if (kDebugMode) {
            print('Error processing Jobs_completed document ${doc.id}: $e');
          }
        }
      }

      // Add the last batch if it has operations
      if (batchCount > 0) {
        batches.add(currentBatch);
      }

      // Commit all batches
      for (final batch in batches) {
        await batch.commit();
      }
    } catch (e) {
      errors.add('Error in fixJobsCompleted: $e');
      if (kDebugMode) {
        print('Error in fixJobsCompleted: $e');
      }
    }

    return {
      'success': errors.isEmpty,
      'collection': 'Jobs_completed',
      'totalProcessed': totalProcessed,
      'totalUpdated': totalUpdated,
      'errors': errors
    };
  }

  /// Fix promoCounter for both collections
  Future<Map<String, dynamic>> fixAllJobs() async {
    final results = <String, dynamic>{
      'success': true,
      'totalProcessed': 0,
      'totalUpdated': 0,
      'collections': <Map<String, dynamic>>[],
      'errors': <String>[]
    };

    if (kDebugMode) {
      print('Starting batch fix for promoCounter...');
    }

    // Fix Jobs_done
    final doneResults = await fixJobsDone();
    results['collections'].add(doneResults);
    results['totalProcessed'] += doneResults['totalProcessed'] as int;
    results['totalUpdated'] += doneResults['totalUpdated'] as int;
    results['errors'].addAll(doneResults['errors'] as List<String>);

    if (kDebugMode) {
      print(
          'Jobs_done: ${doneResults['totalUpdated']}/${doneResults['totalProcessed']} updated');
    }

    // Fix Jobs_completed
    final completedResults = await fixJobsCompleted();
    results['collections'].add(completedResults);
    results['totalProcessed'] += completedResults['totalProcessed'] as int;
    results['totalUpdated'] += completedResults['totalUpdated'] as int;
    results['errors'].addAll(completedResults['errors'] as List<String>);

    if (kDebugMode) {
      print(
          'Jobs_completed: ${completedResults['totalUpdated']}/${completedResults['totalProcessed']} updated');
    }

    results['success'] = (results['errors'] as List).isEmpty;

    if (kDebugMode) {
      print(
          'Batch fix completed: ${results['totalUpdated']}/${results['totalProcessed']} total updated');
    }

    return results;
  }

  /// Calculate total applicable promoCounter for a customer based on promoErrorCode logic
  int calculateApplicablePromoCounter(List<JobModel> customerJobs) {
    // Sort jobs by dateD descending (latest first)
    customerJobs.sort((a, b) => b.dateD.compareTo(a.dateD));

    int totalApplicable = 0;

    for (final job in customerJobs) {
      // If promoErrorCode is 0, include in promo
      if (job.promoErrorCode == 0) {
        totalApplicable += job.promoCounter;
      } else {
        // If promoErrorCode != 0, stop counting (all succeeding jobs are not included)
        break;
      }
    }

    return totalApplicable;
  }

  /// Get loyalty count mismatches
  Future<Map<String, dynamic>> getLoyaltyMismatches() async {
    final mismatches = <Map<String, dynamic>>[];
    final customerJobsMap = <int, List<JobModel>>{};

    try {
      // Get all jobs from both collections
      final doneSnapshot =
          await _jobsDoneFirestore.collection('Jobs_done').get();
      final completedSnapshot =
          await _firestore.collection('Jobs_completed').get();

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

      // Get current loyalty counts from database - use loyaltyCardDb
      final loyaltyFirestore = FirebaseFirestore.instanceFor(
        app: Firebase.apps.firstWhere(
          (app) => app.name == 'loyaltyCardDb',
          orElse: () => Firebase.app(),
        ),
      );
      final loyaltySnapshot =
          await loyaltyFirestore.collection('loyalty').get();
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
            errorCodeCounts[job.promoErrorCode] =
                (errorCodeCounts[job.promoErrorCode] ?? 0) + 1;
          }

          mismatches.add({
            'customerId': customerId,
            'customerName': customerName,
            'currentLoyaltyCount': currentLoyaltyCount,
            'expectedLoyaltyCount': applicablePromoCounter,
            'difference': applicablePromoCounter - currentLoyaltyCount,
            'totalJobs': jobs.length,
            'errorCodeBreakdown': errorCodeCounts,
            'applicableJobs': jobs.where((j) => j.promoErrorCode == 0).length,
          });
        }
      }

      // Sort by difference (largest discrepancies first)
      mismatches.sort((a, b) => (b['difference'] as int)
          .abs()
          .compareTo((a['difference'] as int).abs()));
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

  Future<Map<String, dynamic>> previewChanges() async {
    final preview = <String, dynamic>{
      'Jobs_done': <Map<String, dynamic>>[],
      'Jobs_completed': <Map<String, dynamic>>[],
      'totalChanges': 0
    };

    // Preview Jobs_done
    try {
      final doneSnapshot =
          await _jobsDoneFirestore.collection('Jobs_done').get();
      for (final doc in doneSnapshot.docs) {
        final jobModel = JobModel.fromJson(doc.data());
        final correctPromoCounter = calculateCorrectPromoCounter(jobModel);

        if (jobModel.promoCounter != correctPromoCounter) {
          preview['Jobs_done'].add({
            'docId': jobModel.docId,
            'customerName': jobModel.customerName,
            'jobId': jobModel.jobId,
            'currentPromoCounter': jobModel.promoCounter,
            'correctPromoCounter': correctPromoCounter,
            'packageType': jobModel.regular
                ? 'Regular'
                : jobModel.sayosabon
                    ? 'Sayosabon'
                    : 'Others',
            'pricingType': jobModel.perKilo ? 'Per Kilo' : 'Per Load',
            'finalKilo': jobModel.finalKilo,
            'finalLoad': jobModel.finalLoad,
          });
          preview['totalChanges']++;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error previewing Jobs_done: $e');
      }
    }

    // Preview Jobs_completed
    try {
      final completedSnapshot =
          await _firestore.collection('Jobs_completed').get();
      for (final doc in completedSnapshot.docs) {
        final jobModel = JobModel.fromJson(doc.data());
        final correctPromoCounter = calculateCorrectPromoCounter(jobModel);

        if (jobModel.promoCounter != correctPromoCounter) {
          preview['Jobs_completed'].add({
            'docId': jobModel.docId,
            'customerName': jobModel.customerName,
            'jobId': jobModel.jobId,
            'currentPromoCounter': jobModel.promoCounter,
            'correctPromoCounter': correctPromoCounter,
            'packageType': jobModel.regular
                ? 'Regular'
                : jobModel.sayosabon
                    ? 'Sayosabon'
                    : 'Others',
            'pricingType': jobModel.perKilo ? 'Per Kilo' : 'Per Load',
            'finalKilo': jobModel.finalKilo,
            'finalLoad': jobModel.finalLoad,
          });
          preview['totalChanges']++;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error previewing Jobs_completed: $e');
      }
    }

    return preview;
  }
}
