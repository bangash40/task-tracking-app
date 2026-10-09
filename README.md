# Task Tracking App

A Flutter task management app for Internee.pk interns and admins. Interns create and track their tasks and see tasks assigned to them. Admins assign tasks, monitor completion in real time and review intern performance.

## Tech stack

- Flutter (Dart)
- Firebase Authentication and Cloud Firestore (Firebase core connected; Auth and Firestore to be added)
- Provider for state management

## Status

- Step 1: Flutter project created, folder structure in place, secrets and docs excluded from git.
- Step 2: Firebase project connected (`firebase_core`) and Firebase initialized in `main.dart`.
- Step 3: App theme, constants (collections, roles, task statuses) and shared loading, empty and error widgets.
- Step 4: `UserModel`, `TaskModel` and `ReportModel` with Firestore mapping and report calculations (unit tested).
- Step 5: Email and password authentication (register, login, logout) with `AuthService`, `UserService` and `AuthProvider`. New accounts get a `users` document with the `intern` role. Requires Email/Password sign-in to be enabled in the Firebase console.
- Step 6: Auth gate with role-based navigation. Interns see My Tasks and My Progress; admins see All Tasks, Interns and Summary, each with bottom navigation and a logout action. The tab screens are placeholders until later steps.
- Step 7: Firestore security rules (`firestore.rules`). Interns can only read and write their own tasks and can only change the status of admin-assigned tasks; admins can access everything.
- Step 8: Interns can create tasks (title, description, due date) with validation and a date picker, and edit or delete tasks they created themselves. The task list is basic until the next step.
- Step 9: Real-time My Tasks list for interns with a status filter (All, To Do, In Progress, Completed), status chips, and Overdue and Assigned by admin badges. Loading, empty and error states are handled.
- Step 10: Task Details screen with live updates and who assigned the task, plus a status control (To Do, In Progress, Completed). `completedAt` is set when a task is completed and cleared if it is moved back. Interns can edit or delete only tasks they created.

## Firestore security rules

The rules live in `firestore.rules`. To deploy them:

```
firebase login
firebase deploy --only firestore:rules --project <your-project-id>
```

This needs a local `firebase.json` that points at the rules file (it is gitignored):

```
{ "firestore": { "rules": "firestore.rules" } }
```

Alternatively, paste the contents of `firestore.rules` into Firestore Database > Rules in the Firebase console and publish.

## Creating an admin

Register normally in the app, then open the Firebase console, go to Firestore Database, open the `users` document for that account and change `role` from `intern` to `admin`. The app switches to the admin side automatically.

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
