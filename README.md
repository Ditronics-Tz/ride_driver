# RideApp Driver - Ride Sharing Driver App

A comprehensive Flutter application for ride-share drivers built with modern architecture and clean design principles.

## 🚀 Features

### ✅ Completed Features
- **Authentication System**
  - Welcome screen with modern UI
  - Login with email/phone and password
  - Registration with validation
  - OTP verification flow
  - Driver onboarding process

- **Driver Verification/KYC**
  - Document upload (car photo, driver ID)
  - Real-time verification status tracking
  - Status updates (Pending, Approved, Rejected)
  - Form validation with proper error handling

- **Home Dashboard**
  - Interactive map with current location
  - Quick stats overview
  - Route management interface
  - Real-time notifications

- **Route Creation**
  - Interactive map-based location selection
  - Automatic distance and fare calculation
  - Seat availability configuration
  - Route publishing system

- **State Management**
  - Complete Riverpod providers for all features
  - AuthProvider - authentication and session management
  - DriverProvider - verification and profile management
  - RouteProvider - route creation and management
  - RequestProvider - ride request handling
  - TripProvider - active trip management
  - EarningsProvider - earnings tracking and history

### 🚧 In Development
- Ride Requests Management
- Active Trip Monitoring
- Passenger Communication
- Earnings & History Details
- Profile & Settings
- Push Notifications

## 🛠 Tech Stack

- **Framework**: Flutter 3.8.1+
- **State Management**: Riverpod
- **Maps**: flutter_map + OpenStreetMap
- **Location**: geolocator + geocoding
- **UI Components**: getwidget
- **Form Validation**: form_validator
- **Notifications**: awesome_snackbar_content
- **Storage**: shared_preferences
- **Fonts**: Google Fonts (Poppins)

## 📱 App Architecture

```
lib/
├── main.dart                          # App entry point
├── routes/
│   └── route.dart                     # Navigation routing
├── providers/                         # Riverpod state management
│   ├── auth_provider.dart            # Authentication logic
│   ├── driver_provider.dart          # Driver verification & profile
│   ├── route_provider.dart           # Route creation & management
│   ├── request_provider.dart         # Ride requests handling
│   ├── trip_provider.dart            # Active trip management
│   └── earnings_provider.dart        # Earnings & payment history
├── Screens/
│   ├── welcome.dart                   # Welcome/landing screen
│   ├── AuthScreens/                   # Authentication flow
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── onboarding.dart
│   │   └── otp.dart
│   └── DriverScreens/                 # Main driver features
│       ├── main_navigation.dart       # Navigation wrapper
│       ├── home_screen.dart          # Dashboard & map
│       ├── driver_verification_screen.dart
│       └── route_creation_screen.dart
└── core/                              # Utilities and constants
    ├── constants.dart
    ├── theme.dart
    └── utils.dart
```

## 🎯 Getting Started

### Prerequisites
- Flutter SDK 3.8.1 or higher
- Dart SDK
- Android Studio / VS Code
- Device/Emulator for testing

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd ride_driver
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 🧪 Testing Guide

### Navigation Flow
The app includes a comprehensive navigation system for testing all features:

1. **Start at Welcome Screen** - Tap the start button
2. **Login Screen** - Use any email/phone and password (6+ chars)
3. **Main Navigation** - Access all features via the drawer menu

### Testing Features

#### 1. Authentication
- **Login**: Enter any valid email/phone and 6+ character password
- **Registration**: Complete form and accept terms (bypassed for testing)
- **OTP**: Enter any 4-digit code for verification

#### 2. Driver Verification
- **Document Upload**: Tap photo cards to simulate image selection
- **Status Testing**: Use the refresh button in the app bar to cycle through verification statuses
- **Form Validation**: Try submitting with incomplete information

#### 3. Route Creation
- **Map Interaction**: 
  - Tap "Start Location" → Tap on map to select
  - Tap "Destination" → Tap on map to select
  - Automatic distance/fare calculation
- **Seat Selection**: Choose 1-4 available seats
- **Publishing**: Complete form to publish route

#### 4. Mock Data & Testing
- **Status Updates**: Use the "Mock Status Update" option in the navigation drawer
- **Live Data**: Providers include realistic mock data for testing
- **Responsive UI**: Test on different screen sizes

### Navigation Drawer Options
Access via hamburger menu in the top-left:
- 🏠 **Home** - Dashboard with map and statistics
- ✅ **Verification** - KYC document upload and status
- 📍 **Create Route** - Interactive route creation
- 👥 **Requests** - Ride requests (coming soon)
- 🚗 **Active Trip** - Trip management (coming soon)
- 👤 **Passengers** - Passenger communication (coming soon)
- 💰 **Earnings** - Financial tracking (coming soon)
- ⚙️ **Profile** - Settings and preferences (coming soon)
- 🔔 **Notifications** - Alert management (coming soon)

## 🎨 Design System

### Colors
- **Primary**: `#2563EB` (Blue)
- **Secondary**: `#10B981` (Green)
- **Warning**: `#F59E0B` (Amber)
- **Error**: `#EF4444` (Red)
- **Background**: `#F8F9FA` (Light Gray)

### Typography
- **Font Family**: Poppins (Google Fonts)
- **Weights**: 400 (Regular), 500 (Medium), 600 (SemiBold), 700 (Bold)

### Components
- **Rounded corners**: 8-16px radius
- **Shadows**: Subtle elevation with blur
- **Spacing**: 8px grid system (8, 16, 24, 32px)

## 📊 State Management

### Provider Structure
```dart
// Authentication
ref.watch(authProvider)              // Complete auth state
ref.watch(isAuthenticatedProvider)   // Boolean auth status

// Driver Management
ref.watch(driverProvider)            // Driver info & verification
ref.watch(verificationStatusProvider) // Current verification status
ref.watch(isDriverVerifiedProvider)  // Boolean verification status

// Route Management  
ref.watch(routeProvider)             // Route creation state
ref.watch(publishedRoutesProvider)   // All published routes
ref.watch(activeRouteProvider)       // Currently active route

// Requests & Trips
ref.watch(requestProvider)           // Incoming ride requests
ref.watch(tripProvider)              // Active trip management
ref.watch(earningsProvider)          // Financial data
```

## 🔧 Mock Data

The app includes comprehensive mock data for testing:
- **Verification statuses** with realistic messages
- **Route calculations** with distance/time estimates  
- **Ride requests** with passenger details and ratings
- **Trip history** with earnings and statistics
- **Real-time updates** with periodic data changes

## 🚀 Next Steps

### Immediate Priorities
1. **Ride Requests Screen** - Accept/reject incoming requests
2. **Active Trip Screen** - Real-time trip monitoring
3. **Passenger Communication** - In-app messaging/calling
4. **Earnings Dashboard** - Detailed financial analytics

### Future Enhancements
- Push notifications integration
- Offline mode support
- Advanced route optimization
- Driver analytics and insights
- Multi-language support

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

For questions and support:
- Create an issue in the repository
- Contact the development team
- Check the documentation for common issues

---

**Happy Driving! 🚗💨**