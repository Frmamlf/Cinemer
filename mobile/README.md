# mobile

# Cinemer Mobile App

A modern Flutter application for browsing movies, TV shows, and anime powered by TMDB (The Movie Database) API.

## 🎬 Features

- **Browse Content**: Discover popular, top-rated, and upcoming movies
- **TV Shows & Anime**: Explore television series and anime content
- **Search**: Find specific movies, shows, or anime across all categories
- **User Authentication**: Secure login with TMDB integration
- **Modern UI**: Material You design with adaptive themes
- **Responsive**: Optimized for both Android and iOS devices

## 🛠️ Technology Stack

- **Framework**: Flutter 3.22.0
- **Language**: Dart
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **API**: TMDB (The Movie Database)
- **UI/UX**: Material Design with Flex Color Scheme

## 📱 Supported Platforms

- Android (API 21+)
- iOS

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.22.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code
- Android device or emulator
- iOS device or simulator (for iOS development)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd cinemer/mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building for Release

**Android APK:**
```bash
flutter build apk
```

**iOS (requires macOS):**
```bash
flutter build ios
```

## 📁 Project Structure

```
lib/
├── core/           # Core utilities and configurations
├── features/       # Feature-based modules
└── main.dart      # Application entry point

assets/
├── icons/         # App icons and adaptive icons
├── images/        # Static images
└── animations/    # Animation files

android/           # Android-specific configuration
ios/              # iOS-specific configuration
test/             # Unit and widget tests
```

## 🔧 Configuration

The app uses TMDB API for fetching movie and TV show data. Make sure to configure your API keys in the appropriate configuration files.

## 🧪 Testing

Run tests using:
```bash
flutter test
```

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📞 Support

For support and questions, please open an issue in the repository.

---

**Built with ❤️ using Flutter**

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
