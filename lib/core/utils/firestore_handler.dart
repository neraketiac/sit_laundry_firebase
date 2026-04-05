/// Centralized Firestore operation handler.
///
/// Usage:
///   final result = await FsHandler.run(
///     context: context,
///     operation: () => _db.collection('x').doc('y').set({...}),
///     successMessage: 'Saved successfully',
///   );
///   if (result) { /* success */ }
///
/// For silent background ops (no UI feedback):
///   await FsHandler.silent(() => _db.collection('x').doc('y').update({...}));
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'firestore_timeout.dart';

class FsHandler {
  FsHandler._();

  // ── Classify error ──────────────────────────────────────────────────────────
  static _FsError _classify(Object e) {
    if (e is FirebaseException) {
      switch (e.code) {
        case 'timeout':
          return _FsError.timeout;
        case 'unavailable':
        case 'network-request-failed':
          return _FsError.noInternet;
        case 'permission-denied':
          return _FsError.permissionDenied;
        case 'not-found':
          return _FsError.notFound;
        case 'already-exists':
          return _FsError.alreadyExists;
        case 'cancelled':
          return _FsError.cancelled;
        default:
          return _FsError.unknown;
      }
    }
    final msg = e.toString().toLowerCase();
    if (msg.contains('timeout') || msg.contains('timed out')) {
      return _FsError.timeout;
    }
    if (msg.contains('network') ||
        msg.contains('socket') ||
        msg.contains('connection')) {
      return _FsError.noInternet;
    }
    return _FsError.unknown;
  }

  static String _message(_FsError error) {
    switch (error) {
      case _FsError.timeout:
        return 'Request timed out. Check your internet connection and try again.';
      case _FsError.noInternet:
        return 'No internet connection. Please check your connection and try again.';
      case _FsError.permissionDenied:
        return 'You don\'t have permission to do this.';
      case _FsError.notFound:
        return 'Record not found. It may have been deleted.';
      case _FsError.alreadyExists:
        return 'This record already exists.';
      case _FsError.cancelled:
        return 'Operation was cancelled.';
      case _FsError.unknown:
        return 'Something went wrong. Please try again.';
    }
  }

  static Color _color(_FsError error) {
    switch (error) {
      case _FsError.timeout:
      case _FsError.noInternet:
        return Colors.orange.shade700;
      case _FsError.permissionDenied:
      case _FsError.notFound:
      case _FsError.unknown:
        return Colors.red.shade700;
      case _FsError.alreadyExists:
        return Colors.amber.shade700;
      case _FsError.cancelled:
        return Colors.grey.shade700;
    }
  }

  // ── Main handler — shows snackbar, returns success bool ────────────────────
  static Future<bool> run({
    required BuildContext context,
    required Future<void> Function() operation,
    String? successMessage,
    String? loadingMessage,
    VoidCallback? onSuccess,
    VoidCallback? onRetry,
    bool showLoading = false,
  }) async {
    OverlayEntry? loadingOverlay;

    if (showLoading && loadingMessage != null) {
      loadingOverlay = _buildLoadingOverlay(context, loadingMessage);
      Overlay.of(context).insert(loadingOverlay);
    }

    try {
      await operation().withFsTimeout();

      loadingOverlay?.remove();

      if (successMessage != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(successMessage),
          ]),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ));
      }

      onSuccess?.call();
      return true;
    } catch (e) {
      loadingOverlay?.remove();

      if (!context.mounted) return false;

      final error = _classify(e);
      final message = _message(error);
      final canRetry =
          error == _FsError.timeout || error == _FsError.noInternet;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          Icon(
            canRetry ? Icons.wifi_off : Icons.error_outline,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ]),
        backgroundColor: _color(error),
        duration: Duration(seconds: canRetry ? 6 : 4),
        behavior: SnackBarBehavior.floating,
        action: (canRetry && onRetry != null)
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ));

      return false;
    }
  }

  // ── Silent — no UI, just returns bool ──────────────────────────────────────
  static Future<bool> silent(Future<void> Function() operation) async {
    try {
      await operation().withFsTimeout();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Loading overlay ─────────────────────────────────────────────────────────
  static OverlayEntry _buildLoadingOverlay(
      BuildContext context, String message) {
    return OverlayEntry(
      builder: (_) => Positioned.fill(
        child: Container(
          color: Colors.black.withValues(alpha: 0.3),
          child: Center(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text(message, style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _FsError {
  timeout,
  noInternet,
  permissionDenied,
  notFound,
  alreadyExists,
  cancelled,
  unknown,
}
