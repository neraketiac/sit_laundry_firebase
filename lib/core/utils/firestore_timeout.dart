/// Centralized Firestore timeout config.
/// All Firestore Future calls should use .withFsTimeout() to avoid hanging
/// when there is no internet or the connection is slow.
library;

import 'package:cloud_firestore/cloud_firestore.dart';

const kFsTimeout = Duration(seconds: 12);

extension FsTimeoutX<T> on Future<T> {
  Future<T> withFsTimeout() => timeout(
        kFsTimeout,
        onTimeout: () => throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'timeout',
          message:
              'Firestore request timed out. Check your internet connection.',
        ),
      );
}
