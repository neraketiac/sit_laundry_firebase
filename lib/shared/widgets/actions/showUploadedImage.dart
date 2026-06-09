import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/global/variables_all_codes.dart';
import 'package:laundry_firebase/core/utils/sharedMethods.dart';
import 'package:laundry_firebase/core/utils/sharedmethodsdatabase.dart';
import 'package:laundry_firebase/features/payments/repository/gcash_repository.dart';
import 'package:laundry_firebase/shared/widgets/actions/uploadPlaceholder.dart';

Widget showUploadedImage(BuildContext context, GCashRepository gRepo,
    {VoidCallback? onImageUploaded, bool readOnly = false}) {
  // Use selectedFundCode for new records (showGCashPending), itemUniqueId for existing records (readDataGCashPending)
  final fundCode =
      gRepo.docId.isEmpty ? gRepo.selectedFundCode : gRepo.itemUniqueId;
  final bool isCashOut = fundCode == menuOthUniqIdCashOut;

  // Prioritize whichever image URL is not empty
  final String imageUrl = gRepo.cashInImageUrl.isNotEmpty
      ? gRepo.cashInImageUrl
      : gRepo.cashOutImageUrl;
  final IconData fallbackIcon =
      gRepo.cashOutImageUrl.isNotEmpty && gRepo.cashInImageUrl.isEmpty
          ? Icons.logout
          : Icons.login;

  return Visibility(
    visible: true,
    child: GestureDetector(
      onTap: () async {
        // Read-only mode: only allow viewing
        if (readOnly) {
          if (imageUrl.isNotEmpty) {
            showImagePreview(context, imageUrl);
          }
          return;
        }

        debugPrint(
            'itemUniqueId: ${gRepo.itemUniqueId} / ${gRepo.cashInImageUrl} / ${gRepo.cashOutImageUrl}');

        if (imageUrl.isEmpty) {
          // No image — pick directly
          final uploadedUrl = await callPickImageUniversal(
              context, gRepo.getModel()!, !isCashOut);
          if (uploadedUrl != null) {
            if (isCashOut) {
              gRepo.cashOutImageUrl = uploadedUrl;
            } else {
              gRepo.cashInImageUrl = uploadedUrl;
            }
            onImageUploaded?.call();
          }
        } else {
          // Image exists — show view only option
          await showDialog<String>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('GCash Receipt'),
              content: const Text('View the receipt'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, 'view'),
                  child: const Text('View'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('Close'),
                ),
              ],
            ),
          );

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
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          uploadPlaceholder(fallbackIcon),
                    )
                  : uploadPlaceholder(fallbackIcon),
            ),

            /// 📷 Overlay when image exists
            if (imageUrl.isNotEmpty)
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.6),
                  ),
                  child: const Icon(
                    Icons.visibility,
                    size: 10,
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
