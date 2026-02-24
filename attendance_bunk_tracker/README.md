# 📱 Attendance Bunk Tracker

A Flutter mobile app to track class attendance, know exactly how many classes you can safely bunk, and get alerts when you're at risk.

---

## 🌟 Features

- **8 subjects** with fully editable names
- **Mark Present / Absent** per class from dashboard or detail screen
- **Live stats** per subject:
  - Current attendance %
  - How many classes you can safely bunk
  - How many classes you must attend to reach minimum
- **Overall attendance** dashboard with at-risk count
- **Attendance trend graph** per subject (cumulative % over time)
- **Editable minimum attendance** per subject (default 75%)
- **Undo last entry** & **reset subject data**
- **Local storage** — data persists across app restarts (SharedPreferences)
- **Dark mode UI** with modern card design
- Color-coded status: 🟢 Safe → 🟡 Edge → 🔴 At Risk

---

## 📁 Folder Structure

```
attendance_bunk_tracker/
├── pubspec.yaml
├── README.md
└── lib/
    ├── main.dart                        # App entry point
    ├── theme.dart                       # Dark theme & colors
    ├── models/
    │   └── subject.dart                # Subject & AttendanceRecord models
    ├── providers/
    │   └── attendance_provider.dart    # State management + persistence
    ├── screens/
    │   ├── dashboard_screen.dart       # Home screen with all subjects
    │   └── subject_detail_screen.dart  # Per-subject stats, graph, history
    └── widgets/
        ├── attendance_ring.dart        # Circular % indicator
        └── subject_card.dart           # Subject card with mark buttons
```

---

## 🚀 Setup & Run Instructions

### Prerequisites

1. **Flutter SDK** — Install from https://flutter.dev/docs/get-started/install
   - Minimum Flutter version: 3.10+
   - Dart SDK: >=3.0.0

2. **Android Studio or VS Code** with Flutter extension

3. **Device or Emulator**
   - Android emulator (API 21+) or physical Android/iOS device
   - For iOS: macOS with Xcode required

---

### Step 1 — Clone / Extract the project

```bash
# If you downloaded a zip, extract it then:
cd attendance_bunk_tracker
```

### Step 2 — Install dependencies

```bash
flutter pub get
```

### Step 3 — Run the app

```bash
# List connected devices
flutter devices

# Run on connected device/emulator
flutter run

# Run in release mode (faster)
flutter run --release
```

### Step 4 — Build APK (Android)

```bash
# Debug APK
flutter build apk --debug

# Release APK (install on any Android device)
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### iOS (macOS only)

```bash
flutter build ios --release
# Then open ios/Runner.xcworkspace in Xcode to archive & deploy
```

---

## 📦 Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `provider` | ^6.1.1 | State management |
| `shared_preferences` | ^2.2.2 | Local data persistence |
| `fl_chart` | ^0.66.2 | Attendance trend graphs |
| `uuid` | ^4.2.2 | Unique subject IDs |
| `intl` | ^0.19.0 | Date formatting |

---

## 🎮 How to Use

### Dashboard
- Scroll through all 8 subjects
- Each card shows: attendance %, present/total, safe bunk count or classes needed
- Tap **Present ✓** or **Absent ✗** to mark the current class
- Tap anywhere on the card to open subject details

### Subject Detail Screen
- See full stats, attendance trend graph, and recent history
- Tap the **subject name** (pencil icon) to rename it
- Tap **⋮ menu** to:
  - Undo last entry
  - Edit minimum attendance %
  - Reset all data for that subject

### Color Coding
- 🟢 **Green** — Safe, attendance above minimum
- 🟡 **Yellow/Orange** — On the edge, no bunkable classes left
- 🔴 **Red** — Below minimum, classes needed

---

## 🧮 Math Behind It

**Can Bunk X classes:**
```
x = floor(attended * 100 / minPercent - total)
```

**Need to Attend X classes:**
```
x = ceil((minPercent/100 * total - attended) / (1 - minPercent/100))
```

---

## 🛠 Troubleshooting

**`flutter pub get` fails:**
```bash
flutter clean
flutter pub get
```

**Emulator not found:**
```bash
flutter emulators --launch <emulator_id>
```

**Build errors on Android:**
- Ensure `minSdkVersion` is 21 in `android/app/build.gradle`
- Run `flutter doctor` to check for issues
