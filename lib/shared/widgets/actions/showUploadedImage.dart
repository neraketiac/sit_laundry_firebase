import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/global/variables_all_codes.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/utils/sharedMethods.dart';
import 'package:laundry_firebase/core/utils/sharedmethodsdatabase.dart';
import 'package:laundry_firebase/features/payments/repository/gcash_repository.dart';
import 'package:laundry_firebase/shared/widgets/actions/uploadPlaceholder.dart';

Widget showUploadedImage(BuildContext context, GCashRepository gRepo,
    {VoidCallback? onImageUploaded}) {
  // Use selectedFundCode for new records (showGCashPending), itemUniqueId for existing records (readDataGCashPending)
  final fundCode =
      gRepo.docId.isEmpty ? gRepo.selectedFundCode : gRepo.itemUniqueId;
  final bool isCashOut = fundCode == menuOthUniqIdCashOut;

  final String imageUrl =
      isCashOut ? gRepo.cashOutImageUrl : gRepo.cashInImageUrl;

  final IconData fallbackIcon = isCashOut ? Icons.logout : Icons.login;

  return Visibility(
    visible: true,
    child: GestureDetector(
      onTap: () async {
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
          // Image exists — show options
          final action = await showDialog<String>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('GCash Receipt'),
              content:
                  const Text('What would you like to do with the receipt?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, 'view'),
                  child: const Text('View'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, 'replace'),
                  child: const Text('Replace',
                      style: TextStyle(color: Colors.orange)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          );

          if (action == 'view') {
            showImagePreview(context, imageUrl);
          } else if (action == 'replace') {
            // Only admin can replace existing images
            if (!isAdmin) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Only admin can replace existing receipts'),
                  duration: Duration(seconds: 2),
                ),
              );
              return;
            }

            if (!context.mounted) return;
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Replace Receipt?'),
                content: const Text(
                    'This will replace the existing receipt image. Continue?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Replace',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
            if (confirm == true && context.mounted) {
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
            }
          }
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
