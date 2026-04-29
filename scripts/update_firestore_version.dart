import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// This script updates the Firestore project_version after deployment
/// Run with: dart scripts/update_firestore_version.dart <version>
Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    print('❌ Usage: dart scripts/update_firestore_version.dart <version>');
    print('   Example: dart scripts/update_firestore_version.dart 1.181');
    exit(1);
  }

  final newVersion = args[0];

  try {
    print('📦 Initializing Firebase...');
    await Firebase.initializeApp();

    print('🔄 Updating Firestore project_version to $newVersion...');
    await FirebaseFirestore.instance
        .collection('project_version')
        .doc('current')
        .set({'version': newVersion}, SetOptions(merge: true));

    print('✅ Firestore project_version updated to $newVersion');
    exit(0);
  } catch (e) {
    print('❌ Error updating Firestore: $e');
    exit(1);
  }
}
