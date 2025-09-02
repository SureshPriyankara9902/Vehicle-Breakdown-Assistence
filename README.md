# 🚗 Vehicle Breakdown Assistance System

[![Flutter](https://img.shields.io/badge/Flutter-3.6.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)

## 📋 Table of Contents
- [Overview](#overview)
- [Features](#features)
- [System Architecture](#system-architecture)
- [Screenshots](#screenshots)
- [Technologies Used](#technologies-used)
- [Project Structure](#project-structure)
- [Installation & Setup](#installation--setup)
- [Firebase Configuration](#firebase-configuration)
- [Usage](#usage)
- [API Integration](#api-integration)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

## 🎯 Overview

**Vehicle Breakdown Assistance** is a comprehensive cross-platform Flutter application designed to connect users experiencing vehicle breakdowns with nearby assistance helpers. This dual-app ecosystem consists of two interconnected applications:

- **User App**: For vehicle owners requesting assistance
- **Helper App**: For service providers offering breakdown assistance

The system leverages real-time location tracking, Firebase backend services, and Google Maps integration to provide seamless, efficient vehicle breakdown assistance with features like live chat, trip management, and secure payment processing.

### 🌟 Why Vehicle Breakdown Assistance?

This project simplifies building, configuring, and deploying complex multi-platform apps for emergency vehicle assistance. The core features include:

- 🔧 **Cross-Platform Compatibility**: Supports Flutter, Linux, iOS, Android, Windows, Web, and macOS, ensuring broad reach
- 🛠️ **Robust Build & Plugin Management**: Manages dependencies, plugin registration, and build configurations effortlessly
- 📍 **Real-Time Location & Map Integration**: Facilitates live tracking, route visualization, and location-based services
- 🔥 **Firebase Integration**: Seamlessly connects with Firebase for authentication, database, messaging, and notifications
- 🎨 **Developer-Friendly UI & Themes**: Offers customizable themes, onboarding, and UI components for a polished user experience
- ⚡ **Streamlined Development Workflow**: Supports debugging, onboarding, and project upgrades for efficient development

## ✨ Features

### 👤 User App Features
- **🔐 User Authentication**: Secure registration and login with Firebase Auth
- **📍 Real-time Location Tracking**: GPS-based location services
- **🗺️ Interactive Maps**: Google Maps integration for location visualization
- **🔍 Helper Search**: Find nearby available helpers
- **💬 In-app Messaging**: Real-time chat with assigned helpers
- **📱 Trip Management**: Request, track, and manage assistance requests
- **⭐ Rating System**: Rate and review helper services
- **📊 Trip History**: Complete history of past assistance requests
- **🌍 Weather Integration**: Real-time weather information
- **📞 Emergency Contacts**: Quick access to emergency services
- **💳 Secure Payments**: Integrated payment processing
- **🌙 Dark/Light Theme**: Customizable UI themes

### 🔧 Helper App Features
- **🔐 Helper Authentication**: Secure registration with vehicle information
- **📍 Live Location Broadcasting**: Real-time location sharing
- **📬 Request Management**: Accept/decline assistance requests
- **🗺️ Navigation**: Turn-by-turn directions to user location
- **💬 Client Communication**: Real-time messaging with users
- **💰 Earnings Tracking**: Trip history and earnings management
- **🚗 Vehicle Management**: Register and manage service vehicles
- **⏰ Availability Status**: Online/offline status management
- **📊 Performance Analytics**: Service statistics and ratings
- **🔔 Push Notifications**: Real-time request notifications

### 🏗️ Technical Features
- **🔄 Real-time Synchronization**: Firebase Realtime Database
- **🗺️ Advanced Mapping**: Google Maps with polylines and markers
- **📱 Cross-platform Support**: Android, iOS, Web, Windows, macOS, Linux
- **🔐 Secure Data Storage**: Encrypted local storage
- **📡 Offline Capability**: Essential features work offline
- **🌐 RESTful APIs**: HTTP integration for external services
- **🎵 Audio Notifications**: Sound alerts for important events
- **📸 Image Upload**: Profile pictures and vehicle documentation

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Vehicle Breakdown                    │
│                   Assistance System                     │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
        ┌─────────────────────────────────────────┐
        │            Firebase Backend             │
        │  ┌─────────────┬─────────────────────┐  │
        │  │ Firestore   │ Realtime Database   │  │
        │  │ Auth        │ Cloud Storage       │  │
        │  │ Messaging   │ Cloud Functions     │  │
        │  └─────────────┴─────────────────────┘  │
        └─────────────────────────────────────────┘
                            │
        ┌───────────────────┴───────────────────┐
        │                                       │
        ▼                                       ▼
┌───────────────┐                    ┌──────────────────┐
│   User App    │                    │   Helper App     │
│               │                    │                  │
│ • Trip Request│ ◄─────────────────► │ • Accept Trips   │
│ • Live Track  │                    │ • Navigation     │
│ • Chat        │                    │ • Earnings       │
│ • Payments    │                    │ • Vehicle Info   │
│ • History     │                    │ • Live Location  │
└───────────────┘                    └──────────────────┘
        │                                       │
        ▼                                       ▼
┌───────────────┐                    ┌──────────────────┐
│ Google Maps   │                    │  External APIs   │
│ • Directions  │                    │ • Weather API    │
│ • Geocoding   │                    │ • Payment Gateway│
│ • Places API  │                    │ • SMS Gateway    │
└───────────────┘                    └──────────────────┘
```

## 📱 Screenshots

> **Note**: The following screenshots showcase the key features and user interface of both applications.

### User App Interface
![User App Overview]<img width="363" height="807" alt="image" src="https://github.com/user-attachments/assets/496e6fa8-3c29-483c-a091-a47eb038b9e7" />

<img width="430" height="867" alt="image" src="https://github.com/user-attachments/assets/d7ec7f89-d2e6-45d6-8d2a-cf6098742797" />
<img width="426" height="947" alt="image" src="https://github.com/user-attachments/assets/047a544f-50f9-4abd-b0d4-a8a8cee90e99" />
<img width="426" height="887" alt="image" src="https://github.com/user-attachments/assets/150b3863-9ba7-4626-96cf-8ef0f4175f26" />



*Main interface showing map integration and user features*

### Helper App Interface  
![Helper App Overview]<img width="408" height="906" alt="image" src="https://github.com/user-attachments/assets/0060deb3-e478-47dc-b175-6caf97012b2e" />

<img width="416" height="911" alt="image" src="https://github.com/user-attachments/assets/33551f8c-f399-4b71-89f3-ca24f1861b6b" />

<img width="404" height="836" alt="image" src="https://github.com/user-attachments/assets/44441bdd-b6c5-4651-a68c-110fc49fd4fc" />

<img width="852" height="854" alt="image" src="https://github.com/user-attachments/assets/fd55f1b7-2d1b-4007-8932-a1129e1162f7" />

*Helper dashboard with trip management and navigation features*

## 🛠️ Technologies Used

### Frontend
- **[Flutter 3.6.0+](https://flutter.dev)** - Cross-platform app development framework
- **[Dart](https://dart.dev)** - Programming language for Flutter
- **[Provider](https://pub.dev/packages/provider)** - State management solution

### Backend & Services
- **[Firebase](https://firebase.google.com)**
  - Authentication - User/Helper login and registration
  - Realtime Database - Live data synchronization
  - Cloud Storage - Image and file storage
  - Cloud Messaging - Push notifications
  - Cloud Functions - Server-side logic
- **[Google Maps Platform](https://developers.google.com/maps)**
  - Maps SDK - Interactive maps
  - Directions API - Route calculation
  - Places API - Location search
  - Geocoding API - Address conversion

### Key Dependencies

#### User App
```yaml
dependencies:
  flutter: sdk: flutter
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.4
  firebase_database: ^11.2.0
  firebase_storage: ^12.3.7
  firebase_messaging: ^15.1.6
  google_maps_flutter: ^2.10.0
  geolocator: ^13.0.2
  flutter_polyline_points: ^1.0.0
  provider: ^6.1.2
  http: ^0.13.1
  cached_network_image: ^3.3.1
  shared_preferences: ^2.2.2
  image_picker: ^1.1.2
```

#### Helper App
```yaml
dependencies:
  flutter: sdk: flutter
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.4
  firebase_database: ^11.2.0
  google_maps_flutter: ^2.10.0
  flutter_geofire: ^2.0.4
  location: ^7.0.1
  just_audio: ^0.9.42
  flutter_secure_storage: ^9.2.4
  encrypt: ^5.0.3
  url_launcher: ^6.3.1
```

## 📁 Project Structure

```
Vehicle-Breakdown-Assistance/
├── 📁 apps/
│   ├── 📁 user/                    # User Application
│   │   ├── 📁 lib/
│   │   │   ├── 📁 screens/         # UI Screens
│   │   │   │   ├── login_screen.dart
│   │   │   │   ├── main_screen.dart
│   │   │   │   ├── profile_screen.dart
│   │   │   │   ├── chat_screen.dart
│   │   │   │   ├── weather_screen.dart
│   │   │   │   └── trips_history_screen.dart
│   │   │   ├── 📁 models/          # Data Models
│   │   │   ├── 📁 widgets/         # Reusable Widgets
│   │   │   ├── 📁 Assistants/      # Helper Classes
│   │   │   ├── 📁 global/          # Global Variables
│   │   │   └── main.dart
│   │   ├── 📁 android/             # Android Configuration
│   │   ├── 📁 ios/                 # iOS Configuration
│   │   └── pubspec.yaml
│   │
│   ├── 📁 helper/                  # Helper Application
│   │   ├── 📁 lib/
│   │   │   ├── 📁 screens/         # UI Screens
│   │   │   │   ├── login_screen.dart
│   │   │   │   ├── new_trip_screen.dart
│   │   │   │   ├── vehicle_info_screen.dart
│   │   │   │   ├── RideRequestScreen.dart
│   │   │   │   └── trips_history_screen.dart
│   │   │   ├── 📁 models/          # Data Models
│   │   │   ├── 📁 widgets/         # Reusable Widgets
│   │   │   ├── 📁 Assistants/      # Helper Classes
│   │   │   └── main.dart
│   │   ├── 📁 android/             # Android Configuration
│   │   ├── 📁 ios/                 # iOS Configuration
│   │   └── pubspec.yaml
│   │
│   ├── 📄 README.md                # This file
│   └── 📄 LICENSE                  # MIT License
│
├── 📁 firebase/                    # Firebase Configuration
│   ├── firestore.rules
│   ├── database.rules.json
│   └── firebase.json
│
└── 📁 docs/                        # Documentation
    ├── installation.md
    ├── api-documentation.md
    └── deployment-guide.md
```

## ⚙️ Installation & Setup

### Prerequisites
- **Flutter SDK** (3.6.0 or higher)
- **Dart SDK** (3.0.0 or higher)  
- **Android Studio** / **VS Code** with Flutter plugins
- **Firebase CLI** (for backend configuration)
- **Google Cloud Console** account (for Maps API)

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/vehicle-breakdown-assistance.git
cd vehicle-breakdown-assistance
```

### 2. Install Dependencies

#### For User App:
```bash
cd apps/user
flutter pub get
```

#### For Helper App:
```bash
cd apps/helper
flutter pub get
```

### 3. Flutter Setup Verification
```bash
flutter doctor -v
```
Ensure all requirements are met before proceeding.

## 🔥 Firebase Configuration

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project named "vehicle-breakdown-assistance"
3. Enable Google Analytics (optional)

### 2. Configure Authentication
```bash
# Enable Email/Password and Google Sign-in
# Navigate to Authentication > Sign-in method
# Enable Email/Password and Google providers
```

### 3. Setup Realtime Database
```javascript
// Database Rules (database.rules.json)
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    },
    "helpers": {
      "$uid": {
        ".read": "$uid === auth.uid", 
        ".write": "$uid === auth.uid"
      }
    },
    "trips": {
      ".read": "auth != null",
      ".write": "auth != null"
    }
  }
}
```

### 4. Configure Android Apps
```bash
# Download google-services.json for both apps
# Place in: apps/user/android/app/google-services.json
# Place in: apps/helper/android/app/google-services.json
```

### 5. Environment Variables
Create `.env` files in both app directories:

```env
# apps/user/.env
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
FIREBASE_PROJECT_ID=your_firebase_project_id
WEATHER_API_KEY=your_weather_api_key

# apps/helper/.env  
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
FIREBASE_PROJECT_ID=your_firebase_project_id
```

## 🚀 Usage

### Running the Applications

#### User App:
```bash
cd apps/user
flutter run
```

#### Helper App:
```bash
cd apps/helper  
flutter run
```

### Building for Production

#### Android APK:
```bash
# User App
cd apps/user
flutter build apk --release

# Helper App  
cd apps/helper
flutter build apk --release
```

#### iOS:
```bash
# User App
cd apps/user
flutter build ios --release

# Helper App
cd apps/helper
flutter build ios --release
```

### Testing
```bash
# Run unit tests
flutter test

# Run integration tests
flutter drive --target=test_driver/app.dart
```

## 🌐 API Integration

### Google Maps Integration
```dart
// Initialize Google Maps
GoogleMap(
  initialCameraPosition: CameraPosition(
    target: LatLng(userLatitude, userLongitude),
    zoom: 14.0,
  ),
  onMapCreated: (GoogleMapController controller) {
    _mapController = controller;
  },
)
```

### Firebase Realtime Database
```dart
// Listen to trip updates
DatabaseReference tripRef = FirebaseDatabase.instance
    .ref()
    .child("trips")
    .child(tripId);
    
tripRef.onValue.listen((event) {
  // Handle real-time updates
});
```

### Location Services
```dart
// Get current location
Position position = await Geolocator.getCurrentPosition(
  desiredAccuracy: LocationAccuracy.high,
);
```

## 🤝 Contributing

We welcome contributions to improve the Vehicle Breakdown Assistance System! Please follow these steps:

### 1. Fork the Repository
```bash
git fork https://github.com/yourusername/vehicle-breakdown-assistance.git
```

### 2. Create Feature Branch
```bash
git checkout -b feature/your-feature-name
```

### 3. Commit Changes
```bash
git commit -m "Add: Your descriptive commit message"
```

### 4. Push and Create PR
```bash
git push origin feature/your-feature-name
# Create Pull Request on GitHub
```

### Development Guidelines
- Follow [Flutter Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Write unit tests for new features
- Update documentation for API changes
- Ensure all tests pass before submitting PR

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2024 Vehicle Breakdown Assistance

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

## 📞 Contact

### Project Information
- **Project**: Vehicle Breakdown Assistance System
- **University**: Final Year Project
- **Academic Year**: 2024
- **Course**: Information Technology

### Developer Contact
- **Developer**: Suresh
- **Email**: Suresh68004@gmail.com
- **GitHub**: [My Github Profile](https://github.com/SureshPriyankara9902)
- **LinkedIn**: [My LinkedIn Profile](http://linkedin.com/in/suresh-priyankara-753319284)

### Project Links
- **GitHub Repository**: [Vehicle Breakdown Assistance](https://github.com/yourusername/vehicle-breakdown-assistance)
- **Documentation**: [Project Wiki](https://github.com/yourusername/vehicle-breakdown-assistance/wiki)
- **Issue Tracker**: [GitHub Issues](https://github.com/yourusername/vehicle-breakdown-assistance/issues)

---

### 🎓 Academic Note
This project is submitted as part of the final year project requirements for HORIZON CAMPUS, Department of Information Technology. The application demonstrates practical implementation of mobile app development, real-time systems, and cloud integration technologies.

### 🙏 Acknowledgments
- **University Faculty** for guidance and support
- **Firebase** for backend infrastructure
- **Google Maps Platform** for mapping services
- **Flutter Community** for excellent documentation and packages
- **Open Source Contributors** for the amazing packages used in this project

---

**⭐ If you find this project helpful, please consider giving it a star on GitHub!**


*Last Updated: September 2025*

