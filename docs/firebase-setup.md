# Setting up shared data (Firebase)

Out of the box the app keeps its data on each device. Once Firebase is set
up, coaches sign in and everyone works from the same groups, players,
coaches, sessions, drills, schedules and attendance. Changes show up on the
other coaches' devices while the app is open, and the app keeps working
offline, catching up when it reconnects.

Only coaches you approve can see or change the data. The data includes
children's names, ages and attendance, so keep the approved list short.

## 1. Create the Firebase project

1. Go to <https://console.firebase.google.com> and create a project (Google
   Analytics isn't needed).
2. **Build → Firestore Database → Create database.** Pick a location near
   the club and start in **production mode**.
3. **Build → Authentication → Get started → Sign-in method:** enable
   **Email/Password** (leave "Email link" off).
4. **Authentication → Settings → Authorized domains:** add
   `surafel.github.io` so the web app can sign coaches in.

## 2. Publish the security rules

The rules in [`firestore.rules`](../firestore.rules) let only approved
coaches with a verified email read or write the club's data.

- **Console:** Firestore Database → Rules, paste the contents of
  `firestore.rules`, and click **Publish**; or
- **CLI:** `firebase deploy --only firestore:rules` (uses `firebase.json`).

Until the rules are published, signed-in coaches see "The club database
refused access."

## 3. Connect the app to the project

From the project folder:

```bash
dart pub global activate flutterfire_cli
firebase login             # once, from https://firebase.google.com/docs/cli
flutterfire configure      # choose the project; select android, ios and web
```

This replaces the placeholder `lib/firebase_options.dart` with the
project's settings. Commit it. The values in it identify the project but
aren't secret: access is controlled by sign-in and the security rules. The
next push to `main` deploys a web app and APK that use shared data.

`flutterfire configure` may also add `google-services.json` and a Gradle
plugin on Android. The app doesn't need them, but they do no harm.

## 4. Approve coaches

Each coach creates an account in the app with their email and a password,
then clicks the link in the verification email. They see "Waiting for
approval" until you add them:

1. Firestore Database → **Start collection** (the first time) named
   `approvedCoaches`.
2. Add a document whose **Document ID is the coach's email in lower case**,
   e.g. `alex.coach@example.com`. It needs at least one field: add
   `name` (string) with the coach's name.
3. The coach taps **Try again**.

To remove a coach, delete their document. They lose access straight away.

## 5. Move existing data in

The first approved coach to sign in, while the club has no data yet, is
offered **Copy to the club** if their device already has groups, players,
coaches or sessions. That copies everything on that device into the shared
data. Do this from the device with the most complete data. Data on other
devices stays on those devices and isn't merged.

## How the data is stored

Each item is its own document under `clubs/default/<collection>/<id>`. So
coaches editing different drills, players or dates don't overwrite each
other. If two coaches edit the *same* item at the same moment, the last save
wins.

| Collection | One document per |
| --- | --- |
| `drills`, `sessions`, `rosters`, `players`, `coaches` | item |
| `schedules`, `attendance`, `coachAssignments` | group and date |
| `coachAvailability` | coach and date |
| `seasonProgress` | group |
