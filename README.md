<div align="center">

# ✦ Nylab

<samp>ニャラボ — Premium Mobile Anime Streaming Experience</samp>

<br/>

[![Version](https://img.shields.io/badge/v1.0.0-a855f7?style=flat-square&label=release)](https://github.com/AnjishnuSengupta/nylab/releases)
[![Flutter](https://img.shields.io/badge/Flutter_3.10+-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![License](https://img.shields.io/badge/MIT-3b82f6?style=flat-square&label=license)](LICENSE)
[![Stars](https://img.shields.io/github/stars/AnjishnuSengupta/nylab?style=flat-square&color=fbbf24)](https://github.com/AnjishnuSengupta/nylab/stargazers)

<br/>

<kbd>[🌐 **Web Version**](https://nyanime.tech)</kbd>&nbsp;&nbsp;
<kbd>[🖥️ **Terminal Client**](https://github.com/AnjishnuSengupta/ny-cli)</kbd>&nbsp;&nbsp;
<kbd>[🐛 **Report Bug**](https://github.com/AnjishnuSengupta/nylab/issues)</kbd>

<br/>

</div>

---

<br/>

## 🎯 What's New in v1.0.0

<table>
<tr>
<td>🎨</td>
<td><b>Material You Design</b></td>
<td>Modern glassmorphism effects with dynamic color schemes and smooth animations</td>
</tr>
<tr>
<td>📱</td>
<td><b>Native Mobile Experience</b></td>
<td>Flutter-powered cross-platform app for Android, iOS, Linux, and more</td>
</tr>
<tr>
<td>🎬</td>
<td><b>HLS Video Streaming</b></td>
<td>Adaptive quality streaming with offline caching and resume playback</td>
</tr>
<tr>
<td>☁️</td>
<td><b>Firebase Sync</b></td>
<td>Cloud synchronization for watchlist, watch history, and user preferences</td>
</tr>
<tr>
<td>🌓</td>
<td><b>Cyber-Themed UI</b></td>
<td>Neon effects, animated particles, and matrix rain background for immersive experience</td>
</tr>
<tr>
<td>⚡</td>
<td><b>Offline Mode</b></td>
<td>Full local caching with Hive for offline browsing and watching</td>
</tr>
</table>

<br/>

---

<br/>

## ✨ Features

<div align="center">

```
╭─────────────────────────────────────────────────────────────────╮
│                                                                 │
│   🎬  STREAMING          👤  EXPERIENCE        🔧  TECHNICAL    │
│   ───────────────        ───────────────       ───────────────  │
│                                                                 │
│   ▸ HLS Adaptive         ▸ User Accounts       ▸ Flutter 3.10+  │
│   ▸ Multi-Server         ▸ Watch History       ▸ Riverpod State │
│   ▸ Sub/Dub Toggle       ▸ Watchlist Sync      ▸ Dio HTTP       │
│   ▸ Offline Caching      ▸ Cross-Device        ▸ Hive Storage   │
│   ▸ Resume Playback      ▸ Cloud Profiles      ▸ Firebase Auth  │
│   ▸ Auto Quality         ▸ Custom Avatars      ▸ Material You   │
│                                                                 │
╰─────────────────────────────────────────────────────────────────╯
```

</div>

<br/>

<details>
<summary><b>📺 Video Player Highlights</b></summary>

<br/>

| Feature | Description |
|:--------|:------------|
| **🔄 Adaptive Streaming** | HLS with automatic quality switching based on network conditions |
| **📥 Offline Episodes** | Download episodes for offline viewing with Hive caching |
| **📍 Resume Playback** | Continue from exactly where you left off across devices |
| **🎚️ Source Selector** | Switch between multiple streaming servers seamlessly |
| **🔁 Auto-Retry** | Automatic server fallback and error recovery |
| **🎭 Sub/Dub** | Easy toggle between subtitled and dubbed versions |

</details>

<details>
<summary><b>👤 User Features</b></summary>

<br/>

| Feature | Description |
|:--------|:------------|
| **🔐 Secure Auth** | Firebase authentication with anonymous and email/password |
| **📜 Watch History** | Track all watched episodes with timestamps and progress |
| **❤️ Watchlist** | Save your favorite anime with custom status tags |
| **☁️ Cloud Sync** | Seamless sync across all your devices via Firebase |
| **🎨 Customization** | Material You dynamic theming with glassmorphism effects |
| **🌐 Offline Mode** | Full functionality even without internet connection |

</details>

<details>
<summary><b>🎨 UI/UX Excellence</b></summary>

<br/>

| Feature | Description |
|:--------|:------------|
| **✨ Glassmorphism** | Modern frosted glass effects with backdrop blur |
| **🌈 Neon Accents** | Cyber-themed neon colors (cyan, purple, pink gradients) |
| **💫 Smooth Animations** | Flutter Animate for fluid transitions and micro-interactions |
| **🎭 Particle Effects** | Floating neon particles and matrix rain background |
| **📱 Responsive Design** | Perfectly adapted for phones, tablets, and desktops |
| **🌓 Dark Theme** | Beautiful default dark theme with vibrant accents |

</details>

<br/>

---

<br/>

## 🚀 Quick Start

<br/>

### Prerequisites

- **Flutter SDK** 3.10+ 
- **Dart SDK** 3.10.8+
- **Android Studio** / **Xcode** (for mobile development)
- **Firebase** project (optional, for cloud sync)

<br/>

### Installation

```bash
# Clone the repository
git clone https://github.com/AnjishnuSengupta/nylab.git

# Navigate to project
cd nylab

# Install dependencies
flutter pub get

# Run code generation for Hive
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

<br/>

### Platform-Specific Setup

<details>
<summary><b>🤖 Android</b></summary>

```bash
# Enable developer mode on your device
# Connect via USB or use emulator

flutter run -d android
```

**Minimum SDK:** Android 6.0 (API 23)

</details>

<details>
<summary><b>🍎 iOS</b></summary>

```bash
# Open iOS folder in Xcode
cd ios && pod install && cd ..

# Run on simulator or device
flutter run -d ios
```

**Requirements:** macOS with Xcode 14+, iOS 11+

</details>

<details>
<summary><b>🪟 Windows / 🐧 Linux / 🍎 macOS</b></summary>

```bash
# Desktop support
flutter config --enable-windows-desktop
flutter config --enable-linux-desktop
flutter config --enable-macos-desktop

# Run on desktop
flutter run -d windows
flutter run -d linux
flutter run -d macos
```

</details>

<br/>

### Firebase Setup (Optional but Recommended)

<details>
<summary><b>📋 Step-by-Step Firebase Configuration</b></summary>

<br/>

#### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **"Create a project"** or **"Add project"**
3. Name it (e.g., `nylab`) and click Continue
4. Disable Google Analytics (optional) and click **Create Project**

#### 2. Add Android App

1. In your Firebase project, click the **Android icon**
2. **Package name**: Find in `android/app/build.gradle.kts` → `applicationId` (e.g., `com.example.nylab`)
3. Click **Register app**
4. Download **`google-services.json`**
5. Place it in **`android/app/google-services.json`**

#### 3. Add iOS App (if deploying to iOS)

1. Click the **iOS icon** in Firebase Console
2. **Bundle ID**: Find in `ios/Runner.xcodeproj/project.pbxproj` or Xcode
3. Download **`GoogleService-Info.plist`**
4. Place it in **`ios/Runner/GoogleService-Info.plist`**

#### 4. Enable Authentication

1. In Firebase Console, go to **Build → Authentication**
2. Click **Get Started**
3. Go to **Sign-in method** tab
4. Enable **Anonymous** sign-in and **Email/Password**
5. Click **Save**

#### 5. Enable Cloud Firestore

1. In Firebase Console, go to **Build → Firestore Database**
2. Click **Create database**
3. Choose **Start in test mode** (for development)
4. Pick a region close to you and click **Enable**

#### 6. Install FlutterFire CLI & Configure

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your Flutter project
flutterfire configure --project=YOUR_PROJECT_ID
```

This generates `lib/firebase_options.dart`.

#### 7. Initialize Firebase in App

Add to `lib/main.dart` (after line 15):

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // ... rest of your initialization
}
```

</details>

<br/>

**Without Firebase:** App works fully in offline mode with local storage only. Cloud sync features are automatically disabled.

<br/>

---

<br/>

## 🛠️ Tech Stack

<br/>

<div align="center">

| Layer | Technologies |
|:-----:|:-------------|
| **Framework** | ![Flutter](https://img.shields.io/badge/Flutter_3.10+-02569B?style=flat-square&logo=flutter&logoColor=white) ![Dart](https://img.shields.io/badge/Dart_3.10+-0175C2?style=flat-square&logo=dart&logoColor=white) |
| **State** | ![Riverpod](https://img.shields.io/badge/Riverpod-a855f7?style=flat-square) ![Hooks](https://img.shields.io/badge/Flutter_Hooks-02569B?style=flat-square) |
| **Network** | ![Dio](https://img.shields.io/badge/Dio-0080FF?style=flat-square) ![Connectivity](https://img.shields.io/badge/Connectivity_Plus-4CAF50?style=flat-square) |
| **Storage** | ![Hive](https://img.shields.io/badge/Hive-F9A825?style=flat-square&logo=hive&logoColor=black) ![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=flat-square&logo=firebase&logoColor=black) |
| **Video** | ![Chewie](https://img.shields.io/badge/Chewie-FF6B6B?style=flat-square) ![Video_Player](https://img.shields.io/badge/Video_Player-02569B?style=flat-square) |
| **UI/UX** | ![Material](https://img.shields.io/badge/Material_You-03DAC6?style=flat-square&logo=materialdesign&logoColor=white) ![Google_Fonts](https://img.shields.io/badge/Google_Fonts-4285F4?style=flat-square&logo=google&logoColor=white) |
| **APIs** | ![Aniwatch](https://img.shields.io/badge/Aniwatch_API-a855f7?style=flat-square) ![HLS](https://img.shields.io/badge/HLS_Streaming-FF6600?style=flat-square) |

</div>

<br/>

---

<br/>

## 📁 Project Structure

```
nylab/
├── 📂 lib/
│   ├── 📄 main.dart                    # App entry point
│   └── 📂 src/
│       ├── 📂 core/                    # Core utilities
│       │   ├── constants.dart          # App constants & colors
│       │   ├── network_service.dart    # Network monitoring
│       │   └── theme.dart              # App theme config
│       ├── 📂 data/                    # Data layer
│       │   ├── 📂 api/
│       │   │   └── aniwatch_api.dart   # Aniwatch API client
│       │   ├── 📂 models/              # Data models
│       │   │   ├── anime.dart
│       │   │   ├── episode.dart
│       │   │   └── watchlist.dart
│       │   ├── 📂 repositories/        # Data repositories
│       │   │   ├── anime_repository.dart
│       │   │   └── user_repository.dart
│       │   └── 📂 services/
│       │       └── local_storage.dart  # Hive storage
│       ├── 📂 domain/                  # Business logic
│       │   └── 📂 repositories/
│       ├── 📂 presentation/            # UI layer
│       │   ├── 📂 providers/           # Riverpod providers
│       │   ├── 📂 router/              # GoRouter navigation
│       │   ├── 📂 screens/             # App screens
│       │   │   ├── home/
│       │   │   ├── details/
│       │   │   ├── player/
│       │   │   ├── search/
│       │   │   ├── watchlist/
│       │   │   └── profile/
│       │   └── 📂 widgets/             # Reusable widgets
│       └── 📂 utils/                   # Helper functions
├── 📂 assets/                          # Static assets
│   ├── 📂 lottie/                      # Lottie animations
│   └── 📂 images/                      # App images
├── 📂 android/                         # Android config
├── 📂 ios/                             # iOS config
├── 📂 linux/                           # Linux config
├── 📂 macos/                           # macOS config
├── 📂 windows/                         # Windows config
├── 📄 pubspec.yaml                     # Dependencies
└── 📄 analysis_options.yaml            # Linter rules
```

<br/>

---

<br/>

## 🏗️ Architecture

<div align="center">

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                       │
│  ┌───────────────────────────────────────────────────────┐ │
│  │  Screens (Home, Details, Player, Search, Profile)    │ │
│  │        ↓           ↓           ↓           ↓          │ │
│  │  Providers (Riverpod State Management)               │ │
│  │        ↓           ↓           ↓           ↓          │ │
│  │  Widgets (Reusable UI Components)                    │ │
│  └───────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│                     DOMAIN LAYER                            │
│  ┌───────────────────────────────────────────────────────┐ │
│  │  Business Logic & Use Cases                          │ │
│  │  Repository Interfaces                               │ │
│  └───────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│                      DATA LAYER                             │
│  ┌────────────────────┐  ┌────────────────────┐           │
│  │  Remote Data       │  │  Local Data        │           │
│  │  ├─ Aniwatch API   │  │  ├─ Hive DB        │           │
│  │  ├─ Firebase Auth  │  │  ├─ Cache          │           │
│  │  └─ Firestore      │  │  └─ Preferences    │           │
│  └────────────────────┘  └────────────────────┘           │
└─────────────────────────────────────────────────────────────┘
```

</div>

<br/>

**Design Pattern:** Clean Architecture with Repository Pattern  
**State Management:** Riverpod (Provider-based)  
**Navigation:** GoRouter with declarative routing  
**Storage:** Hive (local) + Firebase Firestore (cloud)

<br/>

---

<br/>

## 🎨 Screenshots

<div align="center">

### Home Screen
*Beautiful glassmorphism carousel with trending anime*

### Anime Details
*Rich anime information with episode list and stats*

### Video Player
*Immersive HLS player with adaptive quality*

### Watchlist
*Organize your anime with custom status tags*

### Profile
*Track your stats and sync across devices*

</div>

<br/>

> **Note:** Screenshots coming soon! Stay tuned for the first release.

<br/>

---

<br/>

## 🚢 Deployment

<br/>

### Building for Release

<details>
<summary><b>🤖 Android APK/AAB</b></summary>

```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release

# Output locations:
# APK: build/app/outputs/flutter-apk/app-release.apk
# AAB: build/app/outputs/bundle/release/app-release.aab
```

</details>

<details>
<summary><b>🍎 iOS IPA</b></summary>

```bash
# Build for iOS (requires macOS)
flutter build ios --release

# Archive in Xcode for App Store
# Open ios/Runner.xcworkspace in Xcode
# Product → Archive → Distribute App
```

</details>

<details>
<summary><b>🪟 Windows EXE</b></summary>

```bash
# Build Windows executable
flutter build windows --release

# Output: build/windows/runner/Release/
# Distribute the entire Release folder
```

</details>

<details>
<summary><b>🐧 Linux Binary</b></summary>

```bash
# Build Linux executable
flutter build linux --release

# Output: build/linux/x64/release/bundle/
# Create a snap/flatpak for distribution
```

</details>

<br/>

---

<br/>

## 🤝 Contributing

<br/>

Contributions are welcome! Here's how you can help:

```bash
# 1. Fork the repository

# 2. Create your feature branch
git checkout -b feature/amazing-feature

# 3. Commit your changes
git commit -m "feat: add amazing feature"

# 4. Push to the branch
git push origin feature/amazing-feature

# 5. Open a Pull Request
```

<br/>

### Development Guidelines

- Follow [Flutter Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Write meaningful commit messages
- Add tests for new features
- Update documentation as needed
- Keep code clean and well-commented

<br/>

---

<br/>

## 🔗 Links & Resources

<br/>

<div align="center">

| | |
|:-:|:-:|
| 🌐 **Web Version** | [NyAnime](https://nyanime.tech) |
| 🖥️ **Terminal Client** | [NY-CLI](https://github.com/AnjishnuSengupta/ny-cli) |
| 📚 **Aniwatch API** | [ghoshRitesh12/aniwatch-api](https://github.com/ghoshRitesh12/aniwatch-api) |
| 📱 **Flutter** | [flutter.dev](https://flutter.dev) |
| 🔥 **Firebase** | [firebase.google.com](https://firebase.google.com) |

</div>

<br/>

---

<br/>

## 📜 License

<br/>

<div align="center">

This project is licensed under the **MIT License**.

See [LICENSE](LICENSE) file for details.

Use freely. Give credit. Build cool things. 💜

</div>

<br/>

---

<br/>

<div align="center">

### ⚠️ Disclaimer

<samp>
This is an educational project. No video content is hosted on our servers.<br/>
All streams are fetched from third-party sources. Use responsibly.
</samp>

<br/>
<br/>

---

<br/>

<img src="https://capsule-render.vercel.app/api?type=waving&color=a855f7&height=100&section=footer" width="100%" />

<br/>

<samp>

*"Cross-platform anime streaming, powered by Flutter."* ✦

</samp>

<br/>

**Made with 💜 by [Anjishnu](https://github.com/AnjishnuSengupta)**

[![Instagram](https://img.shields.io/badge/@anjishnu.prolly-E4405F?style=for-the-badge&logo=instagram&logoColor=white)](https://www.instagram.com/anjishnu.prolly)

<br/>

⭐ Star this repo if you found it useful!

<br/>

**Part of the NyAnime ecosystem:**  
[NyAnime Web](https://github.com/AnjishnuSengupta/nyanime) • [NY-CLI Terminal](https://github.com/AnjishnuSengupta/ny-cli) • **Nylab Mobile**

</div>
