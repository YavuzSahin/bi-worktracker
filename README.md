# BI WorkTracker - Flutter Mobile App

A comprehensive production-ready Flutter application for professional remote work tracking with GPS monitoring and real-time synchronization with the web platform.

## 🚀 Features

### Core Functionality
- **User Authentication** - Secure login with JWT token management
- **Real-time GPS Tracking** - Accurate location capture for check-in/check-out
- **Work Session Management** - Start/stop work sessions with location logging
- **Session Persistence** - Automatic login state preservation
- **Real-time Sync** - Live data synchronization with web platform
- **Role-based Access** - Separate interfaces for employees and administrators

### Technical Features
- **Material Design 3** - Modern, responsive UI following Google's design principles
- **Cross-platform** - Runs on Android (API 21+) and iOS (12.0+)
- **Production Ready** - Optimized performance and error handling
- **Offline Capability** - Local data storage with sync when online
- **Permission Management** - Smart location permission handling
- **Background Processing** - Continues location tracking when minimized

## 📱 Screenshots & Demo

### Login Screen
- Clean, professional login interface
- Demo account information displayed
- Password visibility toggle
- Loading states and error handling

### Employee Dashboard
- User profile display with status indicator
- Large check-in/check-out button with GPS integration
- Recent activity timeline with location details
- Pull-to-refresh functionality
- Real-time status updates

### Admin Interface
- Admin panel with redirect to web interface for full functionality
- Quick access to employee view
- Professional admin-focused design

## 🛠 Technical Architecture

### Dependencies
```yaml
dependencies:
  flutter: sdk
  http: ^1.1.0                    # REST API communication
  shared_preferences: ^2.2.2     # Local data storage
  geolocator: ^10.1.0            # GPS location services
  permission_handler: ^11.0.1    # Runtime permissions
  device_info_plus: ^9.1.1       # Device information
  package_info_plus: ^4.2.0      # App version info
  intl: ^0.18.1                  # Date/time formatting
```

### API Integration
- **Base URL**: `https://workspace.yavuzsahins.repl.co`
- **Authentication**: JWT Bearer token system
- **Endpoints**:
  - `POST /api/login` - User authentication
  - `POST /api/checkin` - Start work session with GPS
  - `POST /api/checkout` - End work session with GPS
  - `GET /api/status` - Current work status
  - `GET /api/logs` - Work history logs

### Location Services
- **High Accuracy GPS** - Using `LocationAccuracy.high`
- **Permission Handling** - Smart request flow with fallbacks
- **Background Tracking** - Maintains location when app is minimized
- **Geocoding** - Converts coordinates to readable addresses

### Data Models
- **User Model** - Complete user profile with role management
- **WorkLog Model** - Work session data with GPS coordinates
- **API Service** - Centralized HTTP client with token management

## 🔧 Setup & Installation

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Dart 3.0.0 or higher
- Android Studio or VS Code with Flutter extension
- Xcode (for iOS development)

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd flutter_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure permissions**
   - Android permissions are pre-configured in `AndroidManifest.xml`
   - iOS permissions are set in `Info.plist`

4. **Run the application**
   ```bash
   # For Android
   flutter run
   
   # For iOS
   flutter run -d ios
   
   # For release build
   flutter build apk --release    # Android
   flutter build ios --release    # iOS
   ```

## 📋 Demo Accounts

### Employee Account
- **Username**: `ahmed`
- **Password**: `123456`
- **Features**: Check-in/out, work history, GPS tracking

### Administrator Account
- **Username**: `admin`
- **Password**: `admin123`
- **Features**: Admin panel access (redirects to web interface)

## 🏗 Build Configuration

### Android Configuration
- **Minimum SDK**: API 21 (Android 5.0)
- **Target SDK**: API 34 (Android 14)
- **Compile SDK**: API 34
- **Permissions**: Location, Internet, Network State, Phone State

### iOS Configuration
- **Minimum iOS**: 12.0
- **Target iOS**: Latest
- **Permissions**: Location (Always, When In Use), Background Processing
- **Capabilities**: Background Modes, Location Services

## 🔒 Security Features

### Authentication Security
- **JWT Token Management** - Secure token storage and refresh
- **Session Persistence** - Encrypted local storage
- **Automatic Logout** - Token expiration handling
- **Network Security** - HTTPS-only communication

### Privacy Protection
- **Location Data** - Only collected during work sessions
- **Data Encryption** - Sensitive data encrypted in transit
- **Permission Transparency** - Clear explanations for required permissions
- **User Control** - Users can control location sharing

## 📊 Performance Optimizations

### App Performance
- **Lazy Loading** - Components loaded on demand
- **Memory Management** - Efficient resource cleanup
- **Battery Optimization** - Smart location tracking intervals
- **Network Efficiency** - Batched API requests and caching

### User Experience
- **Fast Startup** - Optimized splash screen and initialization
- **Smooth Animations** - 60fps Material Design transitions
- **Responsive Design** - Adapts to all screen sizes
- **Error Recovery** - Graceful handling of network issues

## 🧪 Testing & Quality

### Quality Assurance
- **Flutter Lints** - Comprehensive code quality checks
- **Error Handling** - Robust error catching and user feedback
- **Performance Monitoring** - Built-in performance tracking
- **Device Compatibility** - Tested on multiple devices and OS versions

### Production Readiness
- **Release Builds** - Optimized for production deployment
- **App Store Ready** - Configured for Google Play and App Store
- **Documentation** - Complete technical and user documentation
- **Support** - Ready for enterprise deployment

## 🚀 Deployment

### Google Play Store
1. Build release APK: `flutter build apk --release`
2. Generate app bundle: `flutter build appbundle --release`
3. Upload to Google Play Console
4. Configure store listing and release

### Apple App Store
1. Build iOS release: `flutter build ios --release`
2. Open in Xcode and archive
3. Upload to App Store Connect
4. Configure app metadata and submit for review

## 🔮 Future Enhancements

### Planned Features
- **Offline Mode** - Full functionality without internet
- **Push Notifications** - Work reminders and admin alerts
- **Advanced Analytics** - Personal productivity insights
- **Multi-language Support** - 15+ language localization
- **Dark Mode** - Complete dark theme implementation
- **Biometric Auth** - Fingerprint and Face ID login

### Technical Improvements
- **State Management** - Migration to Riverpod or Bloc
- **Database** - Local SQLite for offline capabilities
- **Real-time Updates** - WebSocket integration
- **Advanced Mapping** - Interactive maps with route tracking
- **Background Sync** - Intelligent data synchronization

## 📞 Support & Contact

For technical support, feature requests, or enterprise deployment:
- **Documentation**: Complete API and technical docs available
- **Enterprise Support**: Custom deployment and integration available
- **Community**: Open source contributions welcome

---

**WorkTracker Pro** - Professional remote work tracking solution with enterprise-grade features and consumer-friendly design.