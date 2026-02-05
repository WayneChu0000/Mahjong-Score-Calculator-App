# Mahjong Score Calculator App

## Overview
This is a Flutter-based mobile application designed to assist Mahjong players in calculating scores, managing player groups, and recording game history. It features automated hand scoring using computer vision (OCR) to recognize Mahjong tiles and supports customizable rules and scoring tables.

## Features

### 🀄 Game Score Calculation
- **Hand Recognition**: Capture an image of your Mahjong hand to automatically detect tiles and calculate potential Fan (points).
- **Manual Entry**: Manually select tiles and special conditions (e.g., Self-Draw, Winning on Kong).
- **Fan Calculation**: Auto-calculates Fan based on selected tiles, conditions, and active rules (e.g., Mixed Suits, All Pongs).
- **Score Table**: Lookup precise scores based on the Fan count (supports limits like 13 Fan).

### 👥 Group & Player Management
- **Player Groups**: Create and manage different groups of players.
- **Persistent Stats**: Tracks scores, win/loss records, and history for each player in a group via **Firebase**.
- **Dealer Rotation**: Automatically handles wind rotation (East/South/West/North) and Dealer placement after each round.

### 📊 History & Records
- **Game History**: detailed logs of past games, including who won, who discarded, and the final scores.
- **Statistics**: View individual player performance within a group.

### 🌍 Localization & Customization
- **Multi-language Support**: Fully localized for English and Traditional Chinese.
- **Dark/Light Mode**: Adapts to system theme preferences.

## Getting Started

### Prerequisites
- **Flutter SDK**: Version 3.8.1 or later.
- **Dart SDK**: Compatible with Flutter version.
- **Firebase Account**: Required for backend services (Firestore, Auth).

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/mahjong-score-calculator.git
   cd Mahjong-Score-Calculator-App
   ```

2. **Install Dependencies:**
   ```bash
   flutter pub get
   ```

### Configuration (Crucial Step)

This project relies on **Firebase** for data persistence. You must provide your own Firebase configuration files for the app to run successfully.

1. **Create a Firebase Project:**
   - Go to the [Firebase Console](https://console.firebase.google.com/).
   - Create a new project.
   - Enable **Cloud Firestore** and **Authentication** (if used).

2. **Android Setup:**
   - Register an Android app in your Firebase project (package name usually found in `android/app/build.gradle` - confirm it matches `com.example.flutter_application_1` or your custom ID).
   - Download `google-services.json`.
   - Place it in: `android/app/google-services.json`.

3. **iOS Setup (If applicable):**
   - Register an iOS app in Firebase.
   - Download `GoogleService-Info.plist`.
   - Place it in: `ios/Runner/GoogleService-Info.plist`.

### Running the App

Connect a physical device or start an emulator, then run:

```bash
flutter run
```

## Project Structure

- **`lib/main.dart`**: Entry point of the application; initializes Firebase and providers.
- **`lib/screens/`**: UI screens (Score Calculation, Home, Group Details, etc.).
- **`lib/services/`**: logic for backend interactions.
  - `score_service.dart`: Logic for calculating scores.
  - `vision_service.dart`: Handles image processing for tile recognition.
  - `player_group_service.dart`: Manages Firestore data for groups.
- **`lib/models/`**: Data models (Player, Rule, GameRecord).
- **`lib/localization/`**: Localization files for internationalization.

## Troubleshooting

- **"No Firebase App '[DEFAULT]' has been created"**: Ensure you have added the `google-services.json` file and that `Firebase.initializeApp()` is called in `main.dart` (this is already handled in the codebase).
- **Camera/Image Picker Issues**: Ensure you have added the necessary permissions to `AndroidManifest.xml` and `Info.plist` for camera access.

## License
[MIT License](LICENSE)
