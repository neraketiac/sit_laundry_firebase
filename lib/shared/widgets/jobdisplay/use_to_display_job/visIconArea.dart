import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/utils/app_scale.dart';
import 'package:laundry_firebase/features/jobs/models/jobmodel.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';

InkWell visIconArea(BuildContext context, JobModelRepository jobRepo,
    JobModel job, bool isSelected, bool isRunning, VoidCallback onTap) {
  final s = AppScale.of(context);
  final size = s.isTablet ? 52.0 : 38.0;
  final strokeWidth = s.isTablet ? 8.0 : 6.0;
  final fontSize = s.isTablet ? 20.0 : 16.0;

  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(size / 2),
    child: Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: jobRepo.allStatus,
              strokeWidth: strokeWidth,
              color: jobRepo.riderPickup ? Colors.green : Colors.deepPurple,
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
              style: TextStyle(
                color: Colors.deepPurple,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                shadows: const [
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
    ),
  );
}
