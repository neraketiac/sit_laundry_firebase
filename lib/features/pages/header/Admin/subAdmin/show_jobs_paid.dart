import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/features/jobs/models/jobmodel.dart';
import 'package:laundry_firebase/core/services/firebase_service.dart';

class ShowJobsPaid extends StatefulWidget {
  const ShowJobsPaid({super.key});

  @override
  State<ShowJobsPaid> createState() => _ShowJobsPaidState();
}

class _ShowJobsPaidState extends State<ShowJobsPaid> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  /// Get date range for selected date
  DateTimeRange getSelectedDateRange() {
    final todayStart = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day, 0, 0, 0);
    final todayEnd = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59);
    return DateTimeRange(start: todayStart, end: todayEnd);
  }

  /// Fetch Jobs_done where paidD matches selected date
  Future<List<JobModel>> fetchJobsPaidOnDate() async {
    try {
      final range = getSelectedDateRange();
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
      debugPrint('Error fetching jobs paid on date: $e');
      return [];
    }
  }

  /// Fetch Jobs_done where dateQ matches selected date AND paidCash is true
  Future<List<JobModel>> fetchJobsQueueOnDatePaidCash() async {
    try {
      final range = getSelectedDateRange();
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
      debugPrint('Error fetching queue jobs paid cash on date: $e');
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Jobs Paid'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Selection Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Date:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        border:
                            Border.all(color: Colors.deepPurple, width: 1.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              color: Colors.deepPurple, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('MMM dd, yyyy').format(_selectedDate),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Section 1: Jobs Paid on Selected Date
            _buildSection(
              '1️⃣ Jobs Paid (paidD = ${DateFormat('MMM dd').format(_selectedDate)})',
              fetchJobsPaidOnDate(),
            ),

            const SizedBox(height: 30),

            // Section 2: Jobs Queued on Selected Date + Paid Cash
            _buildSection(
              '2️⃣ Jobs Queued + Paid Cash (dateQ = ${DateFormat('MMM dd').format(_selectedDate)}, paidCash = true)',
              fetchJobsQueueOnDatePaidCash(),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
