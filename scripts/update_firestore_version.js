#!/usr/bin/env node

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Initialize Firebase Admin
const serviceAccount = require('./firestore-key.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// Read version from app_version.dart
const versionFile = path.join(__dirname, '../lib/core/global/app_version.dart');

try {
  const content = fs.readFileSync(versionFile, 'utf8');
  const match = content.match(/appVersion = '([^']+)'/);
  
  if (!match || !match[1]) {
    console.error('✗ Could not parse version from app_version.dart');
    process.exit(1);
  }

  const version = match[1];
  console.log(`📝 Read version from app_version.dart: ${version}`);

  // Update Firestore
  admin
    .firestore()
    .collection('project_version')
    .doc('current')
    .set({ version }, { merge: true })
    .then(() => {
      console.log(`✓ Updated Firestore project_version/current to version ${version}`);
      process.exit(0);
    })
    .catch((err) => {
      console.error('✗ Failed to update Firestore:', err.message);
      process.exit(1);
    });
} catch (err) {
  console.error('✗ Error:', err.message);
  process.exit(1);
}
