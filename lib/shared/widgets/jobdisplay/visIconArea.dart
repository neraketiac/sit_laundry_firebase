import 'package:flutter/material.dart';
import 'package:laundry_firebase/features/jobs/models/jobmodel.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';

InkWell visIconArea(BuildContext context, JobModelRepository jobRepo,
    JobModel job, bool isSelected, bool isRunning, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    child: Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 38,
          height: 38,
          child: CircularProgressIndicator(
              value: jobRepo.allStatus,
              strokeWidth: 6,
              color: (jobRepo.riderPickup ? Colors.green : Colors.deepPurple)
              // backgroundColor: backGroundStatusColor(job),
              // color: Colors.transparent,
              ),
        ),
        AnimatedRotation(
          turns: 0.05,
          duration: const Duration(seconds: 2),
          curve: Curves.linear,
          child: Text(
            jobRepo.processStep.isNotEmpty
                ? '#${jobRepo.jobId}'
                : jobRepo.forSorting
                    ? '🔃'
                    : jobRepo.riderPickup
                        ? '🚲'
                        : '',
            style: const TextStyle(
              color: Colors.deepPurple,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 0,
                  color: Colors.blueGrey,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
