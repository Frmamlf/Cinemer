# TMDB Setup Guide

Cinemer now uses The Movie Database (TMDB) for authentication and movie/TV show data. This guide will help you set up TMDB authentication.

## What You Need

1. **TMDB API Key** - Required for the app to work
2. **TMDB Account** - Optional, for full user features

## Getting Your TMDB API Key

1. Go to [https://www.themoviedb.org/](https://www.themoviedb.org/)
2. Create a free account if you don't have one
3. Go to your account settings
4. Navigate to the "API" section
5. Request an API key (choose "Developer" option)
6. Fill out the application form with your app details
7. Once approved, copy your API key

## Configuring the App

1. Open `/workspaces/Cinemer/mobile/lib/core/utils/constants.dart`
2. Replace `YOUR_TMDB_API_KEY` with your actual API key:

```dart
static const String tmdbApiKey = 'your_actual_api_key_here';
```

## Authentication Options

### Option 1: Full TMDB Account Login
- Requires TMDB username and password
- Full access to your TMDB account features
- Can rate movies, manage watchlists, etc.
- Your data syncs with TMDB

### Option 2: Guest Session (Recommended for Testing)
- No username/password required
- Basic app functionality
- Cannot save preferences or sync data
- Perfect for trying out the app

## Building the App

After adding your API key:

```bash
cd /workspaces/Cinemer/mobile
flutter clean
flutter pub get
flutter build apk --release
```

The APK will be available at:
`/workspaces/Cinemer/mobile/build/app/outputs/flutter-apk/app-release.apk`

## Testing Authentication

1. Build and install the app
2. Try Guest Mode first (no credentials needed)
3. For full login, use your TMDB username and password

## Troubleshooting

- **"Invalid API key" error**: Double-check your API key in `constants.dart`
- **"Login failed" error**: Verify your TMDB username and password
- **Guest mode not working**: Check your API key is valid

## Security Note

Never commit your actual API key to version control. The placeholder `YOUR_TMDB_API_KEY` should be replaced only in your local environment.
