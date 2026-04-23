import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/utils/sharedMethods.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';

Widget visCustomerNameNoAutoComplete(
  BuildContext context,
  JobModelRepository jobRepo,
  bool bShort,
) {
  return Container(
    padding: const EdgeInsets.all(1),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      gradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.12),
          Colors.white.withOpacity(0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(
        color: Colors.white.withOpacity(0.25),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🔹 Label
        Text(
          "     Customer",
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 1,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.7),
          ),
        ),

        const SizedBox(height: 2),

        /// 🔹 Content Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.black.withOpacity(0.15),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
            ),
          ),
          child: Text(
            bShort
                ? '${jobRepo.selectedProcessStep.isEmpty ? '' : '#${jobRepo.selectedJobId} '}${jobRepo.selectedCustomerNameVar.text}'
                : '${jobRepo.selectedProcessStep.isEmpty ? '' : '#${jobRepo.selectedJobId} '}${jobRepo.selectedCustomerNameVar.text} '
                    '(${jobRepo.selectedFinalLoad})\n'
                    '${textBagDetails(jobRepo.getJobsModel()!)} '
                    '₱ ${jobRepo.selectedFinalPrice}.00',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 1.4,
              fontWeight: FontWeight.w600,
              color: jobRepo.selectedCustomerNameVar.text.isEmpty
                  ? Colors.white.withOpacity(0.5)
                  : Colors.white,
            ),
          ),
        ),
      ],
    ),
  );
}
