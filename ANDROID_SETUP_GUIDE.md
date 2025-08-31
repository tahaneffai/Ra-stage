# 🚂 TrainSight Android Setup Guide

## 📱 Converting from Web Mode to Mobile Android Emulator Mode

This guide will help you set up your TrainSight Flutter project for Android development and testing.

## 🔧 Prerequisites

### 1. Enable Developer Mode on Windows
- Press `Windows + R` and type: `ms-settings:developers`
- Enable "Developer Mode" to allow symlink support for Flutter

### 2. Install Android Studio
- Download from: https://developer.android.com/studio
- Install with default settings
- Launch Android Studio and complete the setup wizard

### 3. Install Android SDK
- In Android Studio, go to `Tools > SDK Manager`
- Install the following:
  - Android SDK Platform 34 (API Level 34)
  - Android SDK Build-Tools 34.0.0
  - Android SDK Command-line Tools
  - Android Emulator
  - Android SDK Platform-Tools

### 4. Create Android Virtual Device (AVD)
- In Android Studio, go to `Tools > AVD Manager`
- Click "Create Virtual Device"
- Select a phone (e.g., Pixel 7)
- Choose a system image (e.g., API 34)
- Complete the AVD creation

## 🚀 Project Configuration

### Android Build Configuration ✅
- `android/app/build.gradle.kts` - Configured with proper SDK versions
- `android/app/src/main/AndroidManifest.xml` - Updated with mobile permissions
- `android/app/src/main/kotlin/com/tahaneffai/trainsight/MainActivity.kt` - Updated package name

### Key Configuration Details
```kotlin
// build.gradle.kts
compileSdk = 34
minSdk = 21
targetSdk = 34
applicationId = "com.tahaneffai.trainsight"
```

### Permissions Added
- Internet access
- Location services
- Camera (for AR features)
- Storage access
- Network state

## 📱 Mobile Optimizations

### Main App Configuration ✅
- Portrait orientation lock
- Full-screen mobile experience
- Transparent system UI
- Mobile-specific text scaling

### UI Responsiveness ✅
- `SingleChildScrollView` for overflow prevention
- Responsive layouts with `Expanded` widgets
- Mobile-optimized button sizes
- Touch-friendly interactions

### Screen Optimizations
- **Home Screen**: Fully responsive with scroll support
- **Map Screen**: Mobile-optimized map interactions
- **AR Screen**: Camera permissions and mobile layout
- **Interactive Map**: Touch-friendly controls

## 🧪 Testing Commands

### 1. Check Flutter Setup
```bash
flutter doctor
```

### 2. List Available Devices
```bash
flutter devices
```

### 3. List Available Emulators
```bash
flutter emulators
```

### 4. Start an Emulator
```bash
flutter emulators --launch <emulator_name>
```

### 5. Run on Android
```bash
flutter run
```

## 🔍 Troubleshooting

### Common Issues

#### 1. "Building with plugins requires symlink support"
- **Solution**: Enable Developer Mode in Windows Settings

#### 2. "Unable to locate Android SDK"
- **Solution**: Install Android Studio and SDK

#### 3. "No emulator sources available"
- **Solution**: Create AVD in Android Studio

#### 4. Build Failures
- **Solution**: Run `flutter clean` then `flutter pub get`

### Verification Steps

1. **Check Android Toolchain**
   ```bash
   flutter doctor -v
   ```

2. **Verify Emulator**
   ```bash
   flutter emulators
   ```

3. **Test Build**
   ```bash
   flutter build apk --debug
   ```

## 📱 Mobile Features

### Current Mobile Optimizations
- ✅ Portrait orientation lock
- ✅ Full-screen experience
- ✅ Touch-friendly UI elements
- ✅ Responsive scrolling
- ✅ Mobile-optimized layouts
- ✅ Camera permissions for AR
- ✅ Location services
- ✅ Internet connectivity

### Planned Mobile Enhancements
- [ ] Push notifications
- [ ] Offline mode support
- [ ] Mobile-specific animations
- [ ] Haptic feedback
- [ ] Biometric authentication

## 🚀 Next Steps

1. **Complete Android Studio Installation**
2. **Create and Launch Android Emulator**
3. **Test the App**: `flutter run`
4. **Verify Mobile Features**
5. **Test on Physical Device** (optional)

## 📞 Support

If you encounter issues:
1. Check `flutter doctor` output
2. Verify Android Studio installation
3. Ensure Developer Mode is enabled
4. Check AVD creation in Android Studio

---

**Status**: ✅ Android configuration complete, ⏳ Ready for emulator testing
