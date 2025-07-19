import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class FirebaseOptionsTest {
  static const FirebaseOptions testOptions = FirebaseOptions(
    apiKey: 'test-api-key',
    appId: 'test-app-id',
    messagingSenderId: 'test-messaging-sender-id',
    projectId: 'test-project-id',
    storageBucket: 'test-bucket.appspot.com',
    iosClientId: 'test-ios-client-id',
    iosBundleId: 'com.example.test',
    androidClientId: 'test-android-client-id',
  );
}
