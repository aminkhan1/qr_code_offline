# QR Generator

> **100% Free · Fully Offline · No Ads · No Account Required**

A clean, fast, and privacy-first QR code generator built with Flutter. Works entirely on-device — no internet connection needed, ever.

---

## ✦ Features

- **Offline-first** — generates QR codes with zero network requests
- **Free forever** — no subscriptions, no paywalls, no hidden fees
- **History** — every QR code you create is saved locally on your device
- **Full-screen preview** — tap any saved QR to view it in full detail
- **Share as image** — export any QR code as a PNG and share it anywhere
- **Dark UI** — sleek dark theme with neon blue and purple accents
- **Cross-platform** — runs on Android, iOS, and macOS

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- Android Studio or VS Code
- An Android/iOS device or simulator, or macOS

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/your-username/qr_generator.git
cd qr_generator

# 2. Install dependencies
flutter pub get

# 3. Add Vazirmatn font files to assets/fonts/
#    Download from: https://github.com/rastikerdar/vazirmatn/releases/latest
#    Required files:
#      assets/fonts/Vazirmatn-Regular.ttf
#      assets/fonts/Vazirmatn-Medium.ttf
#      assets/fonts/Vazirmatn-SemiBold.ttf
#      assets/fonts/Vazirmatn-Bold.ttf
#      assets/fonts/Vazirmatn-Black.ttf

# 4. Run
flutter run
```

### Run on macOS

```bash
flutter config --enable-macos-desktop
flutter create --platforms=macos .
flutter run -d macos
```

---

## Platform Setup

### Android

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

### iOS

Add to `ios/Runner/Info.plist`:

```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Save QR codes to your photo library</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Access photos to share QR codes</string>
```

Ensure `ios/Podfile` targets at minimum:

```ruby
platform :ios, '12.0'
```

Then run:

```bash
cd ios && pod install && cd ..
```

### macOS

Add to both `macos/Runner/Release.entitlements` and `macos/Runner/DebugProfile.entitlements`:

```xml
<key>com.apple.security.files.downloads.read-write</key>
<true/>
<key>com.apple.security.files.user-selected.read-write</key>
<true/>
```

---

## Project Structure

```
qr_generator/
├── lib/
│   ├── main.dart                     # App entry point & theme
│   ├── models/
│   │   └── qr_item.dart              # QR code data model
│   ├── services/
│   │   └── storage_service.dart      # Local persistence (SharedPreferences)
│   └── screens/
│       ├── home_screen.dart          # Root scaffold with bottom nav
│       ├── generate_screen.dart      # QR code creation
│       ├── history_screen.dart       # Saved QR code list
│       └── qr_detail_screen.dart    # Full-screen QR viewer
├── assets/
│   └── fonts/                        # Vazirmatn font files (add manually)
└── pubspec.yaml
```

---

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `qr_flutter` | ^4.1.0 | QR code rendering (fully offline) |
| `share_plus` | ^7.2.2 | Native share sheet |
| `shared_preferences` | ^2.2.2 | Local history storage |
| `path_provider` | ^2.1.2 | Temp file directory access |
| `uuid` | ^4.3.3 | Unique ID generation |
| `intl` | ^0.19.0 | Date formatting |

All packages fully support Android, iOS, and macOS.

---

## Privacy

This app collects **no data whatsoever**.

- No analytics
- No crash reporting
- No network requests of any kind
- No account or sign-in required
- All data stays on your device, always

QR codes and history are stored locally using `SharedPreferences` and are never transmitted anywhere.

---

## License

MIT License — free to use, modify, and distribute.

---

<p align="center">Built with Flutter &nbsp;·&nbsp; 100% offline &nbsp;·&nbsp; Always free</p>