# devshabitat

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Firebase Setup

### 1. Firebase CLI Kurulumu

```bash
npm install -g firebase-tools
firebase login
```

### 2. Firebase Projesi Bağlantısı

```bash
firebase use YOUR_PROJECT_ID
```

### 3. Firebase Konfigürasyonu

`firebase.json` dosyasındaki `YOUR_PROJECT_ID`, `YOUR_ANDROID_APP_ID` ve `YOUR_IOS_APP_ID` değerlerini kendi Firebase projenizin bilgileriyle değiştirin.

### 4. Firestore Deploy

```bash
firebase deploy --only firestore:indexes
firebase deploy --only firestore:rules
```

### 5. Google Services Dosyaları

- `android/app/google-services.json` dosyasını Firebase Console'dan indirin
- `ios/Runner/GoogleService-Info.plist` dosyasını Firebase Console'dan indirin
