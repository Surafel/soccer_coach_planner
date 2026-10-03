# Soccer Coach Planner

An offline practice planner for youth soccer coaches. Build practice sessions
from a drill library, put them on a calendar, manage your teams and coaches,
and take attendance — all stored on your device, with no account or server.

Built with [Flutter](https://flutter.dev). Runs on Android, iOS, and the web.

**Try it now:** <https://surafel.github.io/soccer_coach_planner/>

## Features

The app has four tabs:

### Today
- Shows today's practice for each of your groups: the session, its drills in
  order, and how long each one runs.
- Jump straight to taking attendance or to the full schedule.

### Drills
- A starter library of drills, filterable by category (Dribbling, Passing,
  Shooting, Fitness, Ball Control, 1v1, Possession, Attacking Principles,
  Defending Principles, Small-Sided Games, Game Realism).
- Create, edit, and delete your own drills with skill tags and an age range.
- Every drill has a video: an embedded YouTube tutorial when one is set, or a
  one-tap YouTube search for the drill when it isn't.

### Sessions
- Build a practice session by picking drills and setting a duration for each.
- Sessions follow the US Soccer grassroots practice structure:
  **Warm-up → Game → Drill → Scrimmage**.
- **Season Plan:** a built-in 16-week U10 curriculum, organised into four
  4-week training blocks. Add a single week or the whole season to your
  sessions.

### Team
- **Groups (rosters):** manage several teams, each with its own age group
  (U6–U19), players, coaches, and schedule.
- **Players:** a global player list with age, position, jersey number, and
  notes.
- **Coaches:** add coaches, assign them to groups, and record the dates each
  one is available.
- **Schedule:** assign sessions to specific calendar dates per group, and
  pick which coaches run each practice — each coach is shown as "Available",
  "Can't make it", or "No answer yet" for that date.
- **Attendance:** mark who was present at each practice.

### Automatic season progression

Groups with the U10 age group get the season plan assigned for them. When you
open the app on a Saturday, that week's session is placed on that Saturday's
date and the group advances to the next week. If you changed the session on
the previous auto-assigned Saturday, the plan stays on the same week instead
of advancing.

There is no background processing, so this only happens when the app is opened
on the Saturday itself.

### Your data

Everything is saved locally on the device with `shared_preferences` (browser
storage on the web). Nothing is uploaded, and nothing syncs between devices —
uninstalling the app or clearing the browser's site data deletes it.

Watching drill videos is the only feature that needs an internet connection.

## Install

### Web (any device)

Open <https://surafel.github.io/soccer_coach_planner/> in a browser. Nothing to
install.

To put it on your home screen:

- **iPhone / iPad (Safari):** Share → **Add to Home Screen**
- **Android (Chrome):** menu (⋮) → **Add to Home screen** / **Install app**

### Android (APK)

1. On your Android phone, open the
   [latest release](https://github.com/Surafel/soccer_coach_planner/releases/latest).
2. Download `soccer-coach-planner.apk`.
3. Open the downloaded file and allow "install from this source" if prompted.

The APK is rebuilt automatically from every commit to `main`. It is signed
with a debug key rather than a Play Store release key, so Android may show an
extra warning when installing.

### iOS

There is no App Store build. Use the web app above, or build from source with
Xcode (see below).

## Build from source

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) — CI uses
  Flutter **3.32.6**; the project needs Dart **3.8.1** or newer
- For Android: Android Studio or the Android SDK
- For iOS: a Mac with Xcode
- For web: Chrome

Check your setup with:

```bash
flutter doctor
```

### Run

```bash
git clone https://github.com/Surafel/soccer_coach_planner.git
cd soccer_coach_planner
flutter pub get
flutter run              # on a connected device or emulator
flutter run -d chrome    # in the browser
```

### Build a release

```bash
flutter build apk --release    # build/app/outputs/flutter-apk/app-release.apk
flutter build web --release    # build/web/
flutter build ios --release    # macOS + Xcode only
```

When hosting the web build under a sub-path, pass it as the base href, as the
GitHub Pages deploy does:

```bash
flutter build web --release --base-href /soccer_coach_planner/
```

### Test and lint

```bash
flutter analyze
flutter test
```

## Project structure

```
lib/
  main.dart      App entry point and theme
  data/          Built-in content: starter drills and the U10 season curriculum
  models/        Plain data classes (Drill, Session, Roster, Player, Coach, ...)
  services/      Repositories that persist each model, plus season auto-assignment
  screens/       One file per screen; root_screen.dart hosts the four tabs
  widgets/       Reusable UI pieces (cards, tiles, the YouTube embed)
  theme/         App colors
test/            Unit and widget tests
web/             Web shell; flutter_bootstrap.js loads CanvasKit from the app's own files, not a CDN
```

## Continuous deployment

Every push to `main` runs two GitHub Actions workflows, each of which runs
`flutter analyze` and `flutter test` first:

| Workflow | What it does |
| --- | --- |
| `.github/workflows/web-deploy.yml` | Builds the web app and publishes it to the `gh-pages` branch (GitHub Pages) |
| `.github/workflows/android-release.yml` | Builds a release APK and publishes it to the `latest` GitHub release |
