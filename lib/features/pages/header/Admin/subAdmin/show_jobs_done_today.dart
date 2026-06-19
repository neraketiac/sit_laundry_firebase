import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/features/jobs/models/jobmodel.dart';
import 'package:laundry_firebase/core/services/firebase_service.dart';

class ShowJobsDoneToday extends StatefulWidget {
  const ShowJobsDoneToday({super.key});

  @override
  State<ShowJobsDoneToday> createState() => _ShowJobsDoneTodayState();
}

class _ShowJobsDoneTodayState extends State<ShowJobsDoneToday> {
  /// Get today's date range for Firestore queries
  DateTimeRange getTodayRange() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day, 0, 0, 0);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return DateTimeRange(start: todayStart, end: todayEnd);
  }

  /// Fetch Jobs_done where paidD is today (from jobsDoneFirestore)
  Future<List<JobModel>> fetchJobsPaidToday() async {
    try {
      final range = getTodayRange();
      final startOfDay = Timestamp.fromDate(range.start);
      final endOfDay = Timestamp.fromDate(range.end);

      final snapshot = await FirebaseService.jobsDoneFirestore
          .collection('Jobs_done')
          .where('A03_PaidD', isGreaterThanOrEqualTo: startOfDay)
          .where('A03_PaidD', isLessThanOrEqualTo: endOfDay)
          .get();

      return snapshot.docs
          .map((doc) => JobModel.fromJson({...doc.data(), 'A00_DocId': doc.id}))
          .toList();
    } catch (e) {
      debugPrint('Error fetching jobs paid today: $e');
      return [];
    }
  }

  /// Fetch Jobs_done where dateQ is today AND paidCash is true (from jobsDoneFirestore)
  Future<List<JobModel>> fetchJobsQueueTodayPaidCash() async {
    try {
      final range = getTodayRange();
      final startOfDay = Timestamp.fromDate(range.start);
      final endOfDay = Timestamp.fromDate(range.end);

      final snapshot = await FirebaseService.jobsDoneFirestore
          .collection('Jobs_done')
          .where('A01_DateQ', isGreaterThanOrEqualTo: startOfDay)
          .where('A01_DateQ', isLessThanOrEqualTo: endOfDay)
          .where('P01_PaidCash', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => JobModel.fromJson({...doc.data(), 'A00_DocId': doc.id}))
          .toList();
    } catch (e) {
      debugPrint('Error fetching queue jobs paid cash today: $e');
      return [];
    }
  }

  Widget _buildJobCard(JobModel job) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      child: ListTile(
        dense: true,
        title: Text(
          '${job.customerName} (₱${job.paidCashAmount})',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        subtitle: Text(
          'Job#${job.jobId} | ${job.processStep} | Status: ${job.allStatus}',
          style: const TextStyle(fontSize: 11),
        ),
        trailing: Text(
          DateFormat('HH:mm').format(job.paidD.toDate()),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildSection(String title, Future<List<JobModel>> futureJobs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ),
        FutureBuilder<List<JobModel>>(
          future: futureJobs,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(12.0),
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              );
            }

            final jobs = snapshot.data ?? [];

            if (jobs.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'No jobs found',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Total: ${jobs.length} jobs | Total Amount: ₱${jobs.fold<int>(0, (sum, job) => sum + job.paidCashAmount)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ),
                ...jobs.map((job) => _buildJobCard(job)).toList(),
              ],
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and date info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Jobs Done Today',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              Text(
                DateFormat('MMM dd, yyyy').format(DateTime.now()),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Section 1: Jobs where paidD is today
          _buildSection(
            '1️⃣ Jobs Paid Today (paidD = today)',
            fetchJobsPaidToday(),
          ),

          const SizedBox(height: 30),

          // Section 2: Jobs where dateQ is today and paidCash is true
          _buildSection(
            '2️⃣ Jobs Queued Today + Paid Cash (dateQ = today, paidCash = true)',
            fetchJobsQueueTodayPaidCash(),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
