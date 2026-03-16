import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/global/variables_all_codes.dart';
import 'package:laundry_firebase/core/global/variables_oth.dart';
import 'package:laundry_firebase/core/utils/sharedMethods.dart';
import 'package:laundry_firebase/core/utils/sharedmethodsdatabase.dart';
import 'package:laundry_firebase/features/payments/repository/gcash_repository.dart';
import 'package:laundry_firebase/shared/widgets/actions/uploadPlaceholder.dart';

Widget showUploadedImage(
  BuildContext context,
  GCashRepository gRepo,
) {
  final bool isCashOut = gRepo.itemUniqueId == menuOthUniqIdCashOut;

  final String imageUrl =
      isCashOut ? gRepo.cashOutImageUrl : gRepo.cashInImageUrl;

  final IconData fallbackIcon = isCashOut ? Icons.logout : Icons.login;

  return Visibility(
    visible: true,
    child: GestureDetector(
      onTap: () {
        debugPrint(
            'itemUniqueId: ${gRepo.itemUniqueId} / ${gRepo.cashInImageUrl} / ${gRepo.cashOutImageUrl}');

        if (imageUrl.isEmpty) {
          callPickImageUniversal(context, gRepo.getModel()!, !isCashOut);
        } else {
          showImagePreview(context, imageUrl);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.12),
              Colors.white.withOpacity(0.05),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            /// 🖼 IMAGE PREVIEW
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          uploadPlaceholder(fallbackIcon),
                    )
                  : uploadPlaceholder(fallbackIcon),
            ),

            /// 📷 Overlay when image exists
            if (imageUrl.isNotEmpty)
              Positioned(
                bottom: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.6),
                  ),
                  child: const Icon(
                    Icons.visibility,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
