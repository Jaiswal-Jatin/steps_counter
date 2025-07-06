# Steps Counter App 🏃‍♂️

A modern, feature-rich fitness tracking app built with Flutter that helps users monitor their daily steps, calories burned, distance traveled, water intake, and nutrition.

## ✨ Features

### 📱 Core Functionality
- **Real-time Step Tracking**: Uses pedometer sensors to track steps in real-time
- **Calorie Calculation**: Automatically calculates calories burned based on user profile
- **Distance Tracking**: Converts steps to distance using personalized stride length
- **Goal Setting**: Customizable daily step goals with progress tracking
- **Water Intake Monitoring**: Track daily water consumption with visual indicators
- **Nutrition Tracking**: Log meals and monitor carbs, protein, and fat intake

### 📊 Analytics & Insights
- **Weekly Statistics**: Detailed charts showing progress over time
- **Performance Insights**: AI-powered insights about activity patterns
- **Goal Achievement**: Celebration screens for reaching daily targets
- **Streak Tracking**: Monitor consecutive days of goal achievement
- **Progress Visualization**: Beautiful circular progress indicators and charts

### 🎯 User Experience
- **Modern UI/UX**: Clean, intuitive interface with smooth animations
- **Dark/Light Theme**: Adaptive theme based on system preferences
- **Personalized Dashboard**: Customizable home screen with key metrics
- **Achievement System**: Rewards and badges for reaching milestones
- **Social Sharing**: Share achievements with friends and family

### 🔧 Technical Features
- **Background Tracking**: Continues tracking even when app is closed
- **Data Persistence**: Local storage of all fitness data
- **Home Screen Widget**: Android widget for quick step count viewing
- **Push Notifications**: Reminders and achievement notifications
- **Ad Integration**: Monetized with Google Mobile Ads
- **Permission Management**: Handles activity recognition permissions

## 📱 Screenshots

The app includes multiple screens:
- **Dashboard**: Main screen with step counter, progress rings, and quick stats
- **Statistics**: Detailed charts and weekly/monthly analytics
- **Nutrition**: Meal logging and nutrition tracking
- **Profile**: User settings and personal information
- **Goal Achievement**: Celebration screens and reward system
- **Notifications**: Activity reminders and achievement alerts

## 🛠️ Technical Stack

- **Framework**: Flutter 3.8.1+
- **Language**: Dart
- **State Management**: Provider
- **Local Storage**: SharedPreferences
- **Charts**: FL Chart
- **Step Tracking**: Pedometer plugin
- **Permissions**: Permission Handler
- **Ads**: Google Mobile Ads
- **Home Widget**: Home Widget plugin

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  pedometer: ^4.0.2
  permission_handler: ^11.3.1
  provider: ^6.1.2
  shared_preferences: ^2.2.3
  fl_chart: ^0.68.0
  flutter_svg: ^2.0.10+1
  intl: ^0.19.0
  google_mobile_ads: ^5.1.0
  home_widget: ^0.4.1
```

## 🚀 Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/steps-counter-app.git
   cd steps-counter-app
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure permissions** (Android):
   - The app requires `ACTIVITY_RECOGNITION` permission
   - Permissions are automatically requested on first launch

4. **Run the app**:
   ```bash
   flutter run
   ```

## 📱 Android Home Screen Widget

The app includes a native Android widget that displays:
- Current step count
- Daily goal progress
- Distance walked
- Calories burned

To add the widget:
1. Long press on home screen
2. Select "Widgets"
3. Find "Steps Counter" widget
4. Drag to home screen

## 🎨 UI/UX Design

The app features:
- **Color Scheme**: Modern purple gradient with accent colors
- **Typography**: Clean, readable fonts with proper hierarchy
- **Animations**: Smooth transitions and micro-interactions
- **Icons**: Consistent iconography throughout the app
- **Layout**: Responsive design that works on all screen sizes

## 🔐 Privacy & Permissions

The app requests the following permissions:
- **Activity Recognition**: To track steps and physical activity
- **Internet**: For ads and potential cloud sync
- **Network State**: To check connection for ads

All data is stored locally on the device and never shared without explicit user consent.

## 💰 Monetization

The app includes demo ads that can be replaced with your own ad unit IDs:
- **Banner Ads**: Displayed at the bottom of the main screen
- **Interstitial Ads**: Shown occasionally when switching screens
- **Rewarded Ads**: Users can watch ads to earn bonus points

To configure your own ads:
1. Replace ad unit IDs in `lib/services/ad_service.dart`
2. Update the AdMob App ID in `android/app/src/main/AndroidManifest.xml`

## 🔧 Configuration

### User Profile Setup
Users can configure:
- Name and personal details
- Height and weight for accurate calculations
- Daily step goal
- Water intake goal
- Notification preferences

### Data Storage
All data is stored locally using SharedPreferences:
- Daily step counts
- User profile information
- Water intake records
- Nutrition logs
- Achievement data

## 🏗️ Architecture

The app follows a clean architecture pattern:

```
lib/
├── models/          # Data models
├── providers/       # State management
├── screens/         # UI screens
├── widgets/         # Reusable UI components
├── services/        # External services (ads, widgets)
├── theme/          # App theming and styles
└── main.dart       # App entry point
```

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Plugin authors for the various packages used
- Design inspiration from modern fitness apps
- Community feedback and suggestions

## 📞 Support

For support, email support@stepsapp.com or join our Discord server.

---

**Made with ❤️ using Flutter**
