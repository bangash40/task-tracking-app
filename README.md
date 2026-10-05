# Task Tracking App

A Flutter task management app for Internee.pk interns and admins. Interns create and track their tasks and see tasks assigned to them. Admins assign tasks, monitor completion in real time and review intern performance.

## Tech stack

- Flutter (Dart)
- Firebase Authentication and Cloud Firestore (Firebase core connected; Auth and Firestore to be added)
- Provider for state management

## Status

- Step 1: Flutter project created, folder structure in place, secrets and docs excluded from git.
- Step 2: Firebase project connected (`firebase_core`) and Firebase initialized in `main.dart`.

## Getting started

```
flutter pub get
flutter devices
flutter run --debug -d <device_id>
```

## Firebase setup

Firebase configuration files (`google-services.json`, `firebase_options.dart`) are not committed. To regenerate them:

1. Install the Firebase CLI and log in: `firebase login`
2. Install FlutterFire: `dart pub global activate flutterfire_cli`
3. From the project root run `flutterfire configure` and select the Firebase project. This generates `lib/firebase_options.dart` and `android/app/google-services.json`.
