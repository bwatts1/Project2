# Flutter + Firebase Message Board App

## Setup Instructions

### 1. Firebase Configuration

You need to configure Firebase for your project. Follow these steps:

#### Option A: Using FlutterFire CLI (Recommended)

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Login to Firebase
firebase login

# Configure Firebase for your Flutter project
flutterfire configure
```

This will automatically generate the `firebase_options.dart` file.

#### Option B: Manual Configuration

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select an existing one
3. Add an Android app and/or iOS app to your Firebase project
4. Download the configuration files:
   - Android: `google-services.json` → place in `android/app/`
   - iOS: `GoogleService-Info.plist` → place in `ios/Runner/`
5. Follow Firebase setup instructions for each platform

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Services Setup

In the Firebase Console, enable the following services:

#### Authentication
1. Go to Authentication → Sign-in method
2. Enable "Email/Password" provider

#### Cloud Firestore
1. Go to Firestore Database
2. Click "Create database"
3. Start in **test mode** (for development) or set up security rules

#### Recommended Firestore Security Rules

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Message boards
    match /boards/{boardId}/messages/{messageId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
                             request.auth.uid == resource.data.userId;
    }
  }
}
```

### 4. Run the App

```bash
flutter run
```

## Project Structure

```
lib/
 ├── main.dart                    # Entry point
 ├── firebase_options.dart        # Firebase configuration (auto-generated)
 ├── screens/
 │    ├── splash_screen.dart      # Initial loading screen
 │    ├── login_screen.dart       # User login
 │    ├── register_screen.dart    # User registration
 │    ├── home_screen.dart        # Message boards list
 │    ├── chat_screen.dart        # Real-time chat
 │    ├── profile_screen.dart     # Editable user profile
 │    └── settings_screen.dart    # Settings & logout
 └── widgets/
      └── app_drawer.dart         # Navigation drawer
```

## Features

✅ Firebase Authentication (email/password)  
✅ Cloud Firestore integration  
✅ Splash screen with auto-login  
✅ User registration with Firestore document creation  
✅ Message boards with hardcoded list  
✅ Real-time chat using Firestore streams  
✅ Drawer navigation (Home, Profile, Settings)  
✅ Editable user profile  
✅ Settings screen with personal info display  
✅ Logout functionality  

## Firebase Data Structure

### Users Collection
```
users/{userId}
  - uid: string
  - firstName: string
  - lastName: string
  - role: string
  - registrationDatetime: timestamp
```

### Message Boards Collection
```
boards/{boardId}/messages/{messageId}
  - text: string
  - username: string
  - userId: string
  - timestamp: timestamp
```

## Troubleshooting

### Common Issues

1. **Firebase not initialized**
   - Make sure `firebase_options.dart` exists
   - Run `flutterfire configure` if missing

2. **Build errors**
   - Run `flutter clean`
   - Run `flutter pub get`
   - Rebuild the project

3. **Authentication errors**
   - Verify Email/Password is enabled in Firebase Console
   - Check Firebase project settings

4. **Firestore permission denied**
   - Update Firestore security rules as shown above
   - Make sure user is authenticated

## Assignment Requirements Met

✅ Flutter mobile app (not web)  
✅ Firebase Authentication (email/password)  
✅ Cloud Firestore integration  
✅ Splash screen  
✅ User registration & login pages  
✅ Firestore user document with required fields (uid, firstName, lastName, role, registrationDatetime)  
✅ Ordered list of message boards with icons  
✅ Scaffold with Drawer navigation  
✅ Drawer contains: Message Boards, Profile, Settings  
✅ Real-time chat with message text, username, and datetime  
✅ Board name shown in AppBar  
✅ Messages update in real-time using Firestore streams  

## Notes

- No third-party chat UI packages used
- Uses null safety
- No deprecated Firebase APIs
- Simple, clean UI
- Should compile on Flutter stable / FlutLab
