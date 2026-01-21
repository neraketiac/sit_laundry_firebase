import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/jobsonqueuemodel.dart';

class JobsOnQueueRepository {
  JobsOnQueueRepository._();
  static final JobsOnQueueRepository instance =
      JobsOnQueueRepository._();

  /// Single job (nullable until set)
  JobsOnQueueModel? jobsOnQueue;

  bool _loaded = false;

  Future<void> loadOnce() async {
    if (_loaded) return;

    // intentionally blank
    // job will be assigned later

    _loaded = true;
  }

  void setJob(JobsOnQueueModel job) {
    jobsOnQueue = job;
  }

  void clear() {
    jobsOnQueue = null;
  }

  bool get hasJob => jobsOnQueue != null;

  void setCreatedBy(String sEmpId) {
    jobsOnQueue?.createdBy = sEmpId;
  }

  void currentEmpId(String sEmpId) {
    jobsOnQueue?.currentEmpId = sEmpId;
  }
}
