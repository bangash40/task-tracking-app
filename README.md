# Task Tracking App

A Flutter task management app for Internee.pk interns and admins. Interns create and track their tasks and see tasks assigned to them. Admins assign tasks, monitor completion in real time and review intern performance.

## Tech stack

- Flutter (Dart)
- Firebase Authentication and Cloud Firestore (to be added)
- Provider for state management

## Status

- Step 1: Flutter project created, folder structure in place, secrets and docs excluded from git.

## Getting started

```
flutter pub get
flutter devices
flutter run --debug -d <device_id>
```

Firebase configuration files (`google-services.json`, `firebase_options.dart`) are not committed. Regenerate them with `flutterfire configure` once Firebase setup is added.
