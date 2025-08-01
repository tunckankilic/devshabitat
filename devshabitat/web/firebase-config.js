// Firebase configuration for web
const firebaseConfig = {
  apiKey: "AIzaSyC9EAUDH9K8hm96NLh9CmQpyyaAmU_UKsQ",
  authDomain: "devshabitat-23119.firebaseapp.com",
  projectId: "devshabitat-23119",
  storageBucket: "devshabitat-23119.firebasestorage.app",
  messagingSenderId: "163730674615",
  appId: "1:163730674615:web:d1ba409f7c975448730e32",
  measurementId: "G-XH6QMMHLCL"
};

// Initialize Firebase
firebase.initializeApp(firebaseConfig);

// Initialize Firebase services
const auth = firebase.auth();
const firestore = firebase.firestore();
const storage = firebase.storage();
const messaging = firebase.messaging();
const analytics = firebase.analytics(); 