/* eslint-disable no-undef */

importScripts("https://www.gstatic.com/firebasejs/10.12.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.12.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyASvVM-bX6W7-r1-O_u8fbrn5CaFnxVzWQ",
  authDomain: "wash-ko-lang-sit.firebaseapp.com",
  projectId: "wash-ko-lang-sit",
  storageBucket: "wash-ko-lang-sit.appspot.com",
  messagingSenderId: "248306194923",
  appId: "1:248306194923:web:4484ca74bbc01546b7a1ae",
  measurementId: "G-S5RTGDB4DL"
});

const messaging = firebase.messaging();

// ❌ DO NOT manually show notification
// Let webpush.notification handle it automatically
