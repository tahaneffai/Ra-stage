# 🚂 TrainSight App - Setup Guide

## 📋 Overview
This is a Flutter application with a Node.js backend that displays train stations in Morocco with Google Maps integration and AR panorama features.

## 🛠️ Prerequisites

### 1. Install Flutter
1. **Download Flutter SDK** from [flutter.dev](https://flutter.dev/docs/get-started/install)
2. **Extract the zip file** to a location like `C:\flutter` (Windows)
3. **Add Flutter to PATH**:
   - Open System Properties → Advanced → Environment Variables
   - Add `C:\flutter\bin` to the Path variable
4. **Verify installation**:
   ```bash
   flutter doctor
   ```
   Fix any issues shown by the doctor command.

### 2. Install Android Studio
1. **Download Android Studio** from [developer.android.com](https://developer.android.com/studio)
2. **Install with default settings**
3. **Open Android Studio** and complete the setup wizard
4. **Install Android SDK**:
   - Go to Tools → SDK Manager
   - Install Android SDK (API level 33 or higher)
   - Install Android SDK Build-Tools
5. **Create an Android Virtual Device (AVD)**:
   - Go to Tools → AVD Manager
   - Create a new virtual device (Pixel 4 or similar)

### 3. Install Node.js
1. **Download Node.js** from [nodejs.org](https://nodejs.org/)
2. **Install with default settings**
3. **Verify installation**:
   ```bash
   node --version
   npm --version
   ```

### 4. Install PostgreSQL
1. **Download PostgreSQL** from [postgresql.org](https://www.postgresql.org/download/)
2. **Install with default settings**
3. **Remember the password** you set for the postgres user
4. **Verify installation**:
   ```bash
   psql --version
   ```

## 🚀 Project Setup

### Step 1: Extract and Navigate
1. **Extract the downloaded zip file**
2. **Open terminal/command prompt**
3. **Navigate to the project folder**:
   ```bash
   cd path/to/RA
   ```

### Step 2: Backend Setup

1. **Install backend dependencies**:
   ```bash
   npm install
   ```

2. **Create environment file**:
   ```bash
   copy env.example .env
   ```

3. **Edit the .env file** with your PostgreSQL credentials:
   ```env
   DB_HOST=localhost
   DB_PORT=5432
   DB_USER=postgres
   DB_PASSWORD=your_postgres_password
   DB_NAME=gares_db
   PORT=3000
   NODE_ENV=development
   ```

4. **Create the database**:
   - Open pgAdmin or use psql command line
   - Create a new database named `gares_db`

5. **Initialize the database**:
   ```bash
   node init-db.js
   ```

6. **Start the backend server**:
   ```bash
   npm run dev
   ```
   The server should start on `http://localhost:3000`

### Step 3: Flutter App Setup

1. **Install Flutter dependencies**:
   ```bash
   flutter pub get
   ```

2. **Check Flutter setup**:
   ```bash
   flutter doctor
   ```
   Make sure all checks pass (green checkmarks).

3. **Run the app**:
   ```bash
   flutter run
   ```

## 📱 Running the Application

### Option 1: Android Emulator
1. **Start Android Studio**
2. **Open AVD Manager** (Tools → AVD Manager)
3. **Start your virtual device**
4. **Run the Flutter app**:
   ```bash
   flutter run
   ```

### Option 2: Physical Android Device
1. **Enable Developer Options** on your Android device:
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
2. **Enable USB Debugging**:
   - Go to Settings → Developer Options
   - Enable "USB Debugging"
3. **Connect your device** via USB
4. **Run the app**:
   ```bash
   flutter run
   ```

### Option 3: Web Browser
1. **Run Flutter web**:
   ```bash
   flutter run -d chrome
   ```

## 🔧 Troubleshooting

### Common Issues and Solutions

#### 1. Flutter Doctor Issues
- **Android license not accepted**: Run `flutter doctor --android-licenses`
- **Android SDK not found**: Install Android SDK through Android Studio
- **Flutter not in PATH**: Add Flutter bin directory to your system PATH

#### 2. Backend Connection Issues
- **Database connection failed**: Check PostgreSQL is running and credentials are correct
- **Port already in use**: Change PORT in .env file or kill the process using port 3000

#### 3. Flutter Build Issues
- **Dependencies not found**: Run `flutter clean` then `flutter pub get`
- **Android build failed**: Check Android SDK installation and AVD setup

#### 4. Google Maps Issues
- **Maps not loading**: The app uses demo mode for Google Maps
- **API key issues**: The app is configured for demo purposes

## 📁 Project Structure

```
RA/
├── lib/                    # Flutter app source code
│   ├── main.dart          # App entry point
│   ├── screens/           # App screens
│   ├── models/            # Data models
│   ├── services/          # API services
│   └── widgets/           # Reusable widgets
├── assets/                # Images and resources
├── index.js              # Backend server
├── db.js                 # Database configuration
├── routes/               # API routes
└── pubspec.yaml          # Flutter dependencies
```

## 🎯 Features

- **Interactive Map**: View train stations on Google Maps
- **Station Details**: Information about each station
- **AR Panoramas**: 360° views of stations (demo mode)
- **Real-time Data**: Backend API for station information
- **Modern UI**: Material Design with custom themes

## 📞 Support

If you encounter any issues:
1. Check the troubleshooting section above
2. Verify all prerequisites are installed correctly
3. Make sure both backend and Flutter app are running
4. Check console logs for error messages

## 🚀 Next Steps

Once everything is running:
1. Explore the app features
2. Test the map functionality
3. Try the AR panorama features
4. Check the backend API endpoints

Happy coding! 🚂✨ 