# Smart Share Hub 📱📡

**Ethical Hotspot Sharing Manager** — a Flutter app that helps you organize, track,
and share your mobile hotspot sessions in a controlled way. It does **not** connect
to any telecom operator API and does **not** modify, hack, or bypass any network or
billing system. It is purely a local session organizer that works alongside your
phone's built-in hotspot feature.

---

## ✨ Features

1. **Hotspot Session Manager** — Start/End session, choose duration (15 min, 1 hr,
   2 hr, custom, or unlimited), live session timer with countdown/progress bar.
2. **QR Code Sharing** — Generates a standard `WIFI:` QR code (SSID + password you
   enter manually) that any phone camera can scan to join the network instantly.
3. **Connected Devices Tracker** — Simulated local connection log (Android does not
   allow third-party apps to read the real hotspot client list without root/VPN
   privileges, so this is clearly disclosed in the UI).
4. **Data Usage Display** — Per-session usage, daily/weekly/all-time totals, and a
   7-day bar chart.
5. **Session History** — Stored in a local SQLite database with duration, usage,
   timestamps, and device counts. Deletable individually or in bulk.
6. **Modern UI** — Material 3 design, dashboard, big Start/Stop button, full dark
   mode support.
7. **In-App "How to Use" Guide** — Step-by-step instructions + safety tips.

---

## 📂 Project Structure

```
smart_share_hub/
├── android/                     # Native Android project (Gradle)
│   ├── app/
│   │   ├── build.gradle
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       ├── kotlin/.../MainActivity.kt
│   │       └── res/             # Icons, themes, launch background
│   ├── build.gradle
│   ├── settings.gradle
│   ├── gradle.properties
│   └── local.properties         # ⚠️ edit this before building
├── lib/
│   ├── main.dart                # App entry point
│   ├── models/
│   │   └── session_model.dart   # HotspotSession & ConnectedDevice models
│   ├── providers/
│   │   └── session_provider.dart # State management (Provider/ChangeNotifier)
│   ├── services/
│   │   ├── database_service.dart # SQLite (sqflite) persistence
│   │   └── preferences_service.dart # SharedPreferences (theme, last creds)
│   ├── screens/
│   │   ├── dashboard_screen.dart
│   │   ├── start_session_screen.dart
│   │   ├── qr_display_screen.dart
│   │   ├── session_history_screen.dart
│   │   ├── how_to_use_screen.dart
│   │   └── settings_screen.dart
│   ├── widgets/
│   │   ├── usage_card.dart
│   │   └── connected_devices_card.dart
│   └── utils/
│       ├── app_theme.dart
│       └── formatters.dart
├── pubspec.yaml
└── analysis_options.yaml
```

---

## 🛠 Tech Stack

- **Flutter 3.x** (Dart 3)
- **State management:** `provider` (ChangeNotifier)
- **Local storage:** `sqflite` (SQLite) for sessions/devices, `shared_preferences`
  for theme + last-used WiFi credentials
- **QR generation:** `qr_flutter`
- **Charts:** `fl_chart`
- (`mobile_scanner` and `permission_handler` are included as dependencies for future
  optional QR-scanning/permission features — the core flow does not require camera
  permissions to function)

---

## ⚙️ Setup Instructions

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.16+ recommended)
- Android Studio (for SDK/emulator) or a physical Android device with USB debugging
- A connected Android device or emulator running **Android 6.0 (API 23) or higher**

### 1. Get the code
Place the `smart_share_hub` folder anywhere on your machine, then open a terminal
inside it.

### 2. Configure `android/local.properties`
Edit `android/local.properties` and set the correct paths for your machine:

```properties
sdk.dir=/Users/yourname/Library/Android/sdk
flutter.sdk=/Users/yourname/flutter
flutter.versionName=1.0.0
flutter.versionCode=1
```

> On Windows, paths look like `C:\\Users\\yourname\\AppData\\Local\\Android\\sdk`.
> You can find your SDK path in Android Studio → Settings → Languages & Frameworks
> → Android SDK.

### 3. Install dependencies
```bash
flutter pub get
```

### 4. Verify your setup
```bash
flutter doctor
```
Resolve any issues it reports (Android licenses, missing toolchains, etc.).

---

## ▶️ How to Run on Android

### Using an emulator
```bash
flutter emulators --launch <emulator_id>   # or open one from Android Studio
flutter run
```

### Using a physical device
1. Enable **Developer Options** → **USB Debugging** on your phone.
2. Connect via USB and accept the debugging prompt.
3. Confirm the device is detected:
   ```bash
   flutter devices
   ```
4. Run the app:
   ```bash
   flutter run
   ```

The app will hot-reload — press `r` to hot reload or `R` to hot restart while
`flutter run` is active.

---

## 📦 Building the APK

### Debug APK (quick testing)
```bash
flutter build apk --debug
```
Output: `build/app/outputs/flutter-apk/app-debug.apk`

### Release APK (for installing/sharing)
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

> The project ships with the **debug signing config** applied to the release build
> type so `flutter build apk --release` works immediately without extra setup.
> For a Play Store submission, generate your own keystore and update
> `android/app/build.gradle` → `signingConfigs` accordingly (see
> [Flutter's signing guide](https://docs.flutter.dev/deployment/android#signing-the-app)).

### Split APKs per architecture (smaller file size)
```bash
flutter build apk --split-per-abi
```

### Install the APK on your device
```bash
flutter install
# or manually:
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## 📖 How to Use (also built into the app under "Help")

1. **Start a Hotspot Session**
   - Turn ON your phone's mobile hotspot from system settings first.
   - Note your hotspot's WiFi name (SSID) and password.
   - In Smart Share Hub, tap **"Start Hotspot Session"**, enter the same SSID and
     password, pick a duration, and tap **Start Session & Generate QR**.

2. **Generate & Share the QR Code**
   - A standard `WIFI:` QR code is generated automatically.
   - Tap **View QR Code** any time during a session to display it again.

3. **How Others Connect**
   - The other person scans the QR with their phone's camera app.
   - Their phone prompts "Join Network" — tapping it connects them automatically.
   - If scanning isn't supported, they can type the SSID/password shown in the app.

4. **End a Session**
   - Tap **End Session** and confirm. The session is saved to History with
     duration, data usage, and timestamps.
   - Sessions also auto-end when the chosen duration timer expires.
   - Remember to turn OFF your hotspot in system settings afterward.

5. **Safety Tips**
   - Only share with trusted people; use strong passwords (8+ characters).
   - Prefer timed sessions over "Unlimited" with new contacts.
   - Monitor usage regularly and turn off the hotspot when done.
   - Rotate your password periodically.

---

## ⚠️ Important Notes & Limitations

- **No telecom integration**: This app never communicates with Jazz, Telenor,
  Zong, Ufone, or any carrier API. It does not read SIM data, balances, or
  packages.
- **No network hacking**: The app does not bypass, spoof, or interfere with any
  network authentication or billing system.
- **Connected devices are simulated**: Standard Android apps cannot query the
  real list of devices connected to a personal hotspot without system/root
  privileges. The "Connected Devices" feature simulates realistic activity for
  tracking/demo purposes and clearly discloses this in the UI.
- **Data usage is approximate/simulated**: Since reading real-time per-app/
  per-hotspot traffic requires elevated permissions (`READ_PHONE_STATE` /
  `NetworkStatsManager` with special grants), usage figures are generated locally
  to demonstrate the tracking and history features. You can swap in real
  `NetworkStatsManager`-based readings later if you grant the appropriate
  permissions on a rooted/managed device.
- **All data is local**: Everything is stored in a local SQLite database and
  SharedPreferences. Nothing is uploaded anywhere.

---

## 🧩 Troubleshooting

| Issue | Fix |
|---|---|
| `flutter.sdk not set in local.properties` | Edit `android/local.properties` with your real Flutter SDK path |
| Gradle sync fails | Run `flutter clean && flutter pub get` then rebuild |
| App icon not showing | Re-run `flutter build apk` after confirming PNGs exist under `android/app/src/main/res/mipmap-*` |
| QR not scanning on other phone | Ensure password is at least 8 characters (required by WPA QR format) |

---

## 📄 License

This project is provided as-is for personal/educational use. Customize freely.
