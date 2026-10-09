# Task Tracking App

A Flutter task management app for Internee.pk interns and admins. Interns create and track their own tasks and see tasks assigned to them. Admins assign tasks, monitor completion in real time and review each intern's performance.

## Features

**Everyone**
- Register and log in with email and password; stay logged in until you log out.
- Routed to the intern or admin side based on your role.

**Interns**
- Create, edit and delete their own tasks (title, description, due date).
- See self-created and admin-assigned tasks in one list that updates in real time.
- Filter by status (All, To Do, In Progress, Completed); overdue and admin-assigned tasks are clearly marked.
- Open a task to see its details and update its status. Admin-assigned tasks can only have their status changed.
- My Progress report: total tasks, count per status, completion rate, overdue count and on-time completion rate.

**Admins**
- See every task across all interns in real time, filtered by intern and status.
- View the list of interns, assign tasks to them, and edit or delete the tasks they assigned.
- Open any intern's performance view: the same report as the intern's plus their tasks.
- Overall summary: total interns, total tasks, count per status, overall completion rate, overdue count, and interns ranked by completion rate.

## Tech stack

- Flutter (Dart), Provider for state management
- Firebase Authentication (email/password)
- Cloud Firestore with real-time snapshots
- `intl` for date formatting

## Project structure

```
lib/
  core/        theme, constants (collections, roles, statuses), utils (dates, validators)
  models/      UserModel, TaskModel, ReportModel
  services/    AuthService, UserService, TaskService
  providers/   AuthProvider
  screens/     auth, intern, admin, shared
  widgets/     task card, status chip, report view, loading/empty/error views
firestore.rules
test/
```

## Getting started

Requirements: Flutter SDK, an Android device or emulator, and a Firebase project.

```
flutter pub get
flutter devices
flutter run --debug -d <device_id>
```

The app will not run until the Firebase configuration files exist (see below).

## Firebase setup

Firebase configuration files are not committed (`lib/firebase_options.dart`, `android/app/google-services.json`). To create them:

1. In the Firebase console, create a project, enable **Authentication > Email/Password**, and create a **Firestore** database.
2. Install the Firebase CLI and log in: `firebase login`
3. Install FlutterFire: `dart pub global activate flutterfire_cli`
4. From the project root run `flutterfire configure` and select your project. This generates both files.

### Security rules

The rules live in `firestore.rules`. Interns can only read and write their own tasks and can only change the status of admin-assigned tasks; admins can access everything. To deploy them:

```
firebase deploy --only firestore:rules --project <your-project-id>
```

This needs a local `firebase.json` that points at the rules file (it is gitignored):

```
{ "firestore": { "rules": "firestore.rules" } }
```

Alternatively, paste the contents of `firestore.rules` into Firestore Database > Rules in the Firebase console and publish.

### Creating an admin

There is no public admin sign-up. Register normally in the app, then open the Firebase console, go to Firestore Database, open that account's document in `users` and change `role` from `intern` to `admin`. The app switches to the admin side automatically.

## Tests

```
flutter test
```

Covers the report calculations and the form validators.

## Secrets

`docs/`, Firebase configuration files, `firebase.json`, `.firebaserc`, environment files and signing keys are listed in `.gitignore` and must never be committed. Run `git status` before every commit to confirm none of them are staged.
