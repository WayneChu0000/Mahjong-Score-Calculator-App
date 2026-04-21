# Mahjong Score Calculator App

Flutter mobile app for Mahjong score calculation, round tracking, and player/group record management.

## What This App Includes

- Score calculation workflow for Mahjong rounds.
- Optional image-based tile recognition via a configurable Vision API.
- Player group and game history persistence with Firebase.
- Localization support (English and Traditional Chinese).
- App theme preference support (light, dark, follow system).

## Tech Stack

- Flutter (SDK constraint in this repo: Dart ^3.8.1)
- Provider for state management
- Firebase Core + Cloud Firestore + Firebase Auth
- HTTP + image_picker for Vision API flow
- flutter_dotenv for environment configuration

## Prerequisites

- Flutter SDK installed and available in PATH
- A Firebase project (for Firestore/Auth features)
- A Vision API endpoint/key if you want image-based detection

## Setup

1. Install packages:

```bash
flutter pub get
```

2. Configure environment variables:

PowerShell:

```powershell
Copy-Item .env.example .env
```

macOS/Linux:

```bash
cp .env.example .env
```

Windows CMD:

```cmd
copy .env.example .env
```

Update .env values as needed:

```env
VISION_API_URL=https://predict.ultralytics.com
VISION_API_KEY=YOUR_API_KEY_HERE
VISION_MODEL_URL=https://hub.ultralytics.com/models/YOUR_MODEL_ID_HERE
VISION_CONF=0.25
VISION_IOU=0.7
VISION_IMGSZ=640
```

Notes:

- .env is loaded at app startup in main.
- You can override values with --dart-define at build/run time.

3. Configure Firebase:

- Android: add google-services.json to android/app/google-services.json.
- iOS: add GoogleService-Info.plist to ios/Runner/GoogleService-Info.plist.
- Ensure Cloud Firestore and Authentication are enabled in your Firebase project.

This app currently initializes Firebase with Firebase.initializeApp() and expects platform Firebase config files to be present.

## Database Guide

This project uses Firebase Authentication + Cloud Firestore.

### What to provide (for assignment/report handover)

1. Database platform: Firebase Cloud Firestore.
2. Enabled services: Authentication (Email/Password) and Cloud Firestore.
3. Firebase app config placement:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`
4. Firestore data model summary (collections, document IDs, and key fields).
5. Security rules and test account strategy.

### Firestore structure used by the app

```text
users/{uid}
  language: string
  theme: string
  lastUpdated: timestamp

users/{uid}/player_groups/{groupName}
  name: string
  players: string[]
  createdAt: ISO datetime string
  lastPlayedAt: ISO datetime string?
  currentScores: map<string, int>?
  currentRound: int?
  dealerIndex: int?
  prevalentWindIndex: int?
  currentDealerGameCount: int?
  totalWindRounds: int?
  totalGamesPlayedInGroup: int
  playerStats: map<string, object>?
  roundHistory: object[]?
  minFan: int
  maxFan: int
  gameMode: string
  laState: map<string, dynamic>?

users/{uid}/player_groups/{groupName}/achievements/{playerId}
  counters: map<string, dynamic>
  progress: map<string, object>
```

### Security rule baseline (example)

```text
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
  }
}
```

### Sensitive data guidance

- Do not publish real API keys, production Firebase credentials, or user data in README.
- Keep `.env` local and committed secrets out of version control.
- Share only sample values in docs (`.env.example`).

## Installation Guide (Submission Ready)

1. Install Flutter SDK and verify with `flutter doctor`.
2. Get project dependencies:

```bash
flutter pub get
```

3. Create environment file from sample (`.env.example` -> `.env`) and fill values.
4. Add Firebase platform files:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
5. In Firebase Console, ensure Authentication and Cloud Firestore are enabled.
6. Start the app:

```bash
flutter run
```

7. Run tests:

```bash
flutter test
```

8. Optional quality checks:

```bash
flutter analyze
```

## Run

```bash
flutter run
```

## Test

```bash
flutter test
```

## Useful Commands

```bash
flutter analyze
flutter pub get
flutter test
```

## Project Layout

- lib/main.dart: App entry point, environment loading, Firebase initialization, providers.
- lib/config/: Runtime and environment configuration.
- lib/controllers/: Controller logic for app features.
- lib/logic/: Core Mahjong and rule evaluation logic.
- lib/models/: Data models.
- lib/screens/: UI screens.
- lib/services/: Data and integration services (score, settings, auth, player groups, vision).
- lib/localization/ and lib/l10n/: Localization resources and generated language support.
- test/: Unit and scenario tests.

## Troubleshooting

- No Firebase App '[DEFAULT]' has been created:
  - Verify Firebase config files are placed in platform folders.
  - Rebuild the app after adding config files.

- Vision API requests fail:
  - Check VISION_API_URL and VISION_API_KEY in .env.
  - Confirm your endpoint accepts multipart file uploads.

- Localization not updating as expected:
  - Verify selected language in app settings.
  - Restart app after changing localization-related configuration.
