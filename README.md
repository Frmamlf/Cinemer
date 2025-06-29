# Cinemer - Movie, TV Show & Anime Discovery App

A beautiful cross-platform application built with **TypeScript backend** and **Flutter frontend** that helps users discover movies, TV shows, and anime using TMDB API.

## 🎬 Features

### 🎭 **Content Discovery**
- **Movies**: Popular, top-rated, upcoming, now playing
- **TV Shows**: Popular, top-rated, on the air, airing today
- **Anime**: Discover Japanese animation movies and series
- **Search**: Advanced search across all content types
- **Filters**: Genre, year, language, and more

### 🎨 **Material 3 Design**
- **Beautiful UI**: Modern Material 3 design system
- **Multilingual**: Arabic and English support with Rubik font
- **Dark/Light Mode**: Automatic theme switching
- **Responsive**: Optimized for phones and tablets
- **Animations**: Smooth transitions and loading states

### 🔧 **Technical Features**
- **Offline Support**: Cache content for offline viewing
- **Performance**: Lazy loading and image caching
- **State Management**: Riverpod for reactive programming
- **Navigation**: Go Router for type-safe navigation
- **Local Storage**: Hive for fast local data storage

## 🏗️ Architecture

### Backend (TypeScript)
```
backend/
├── src/
│   ├── routes/          # API endpoints
│   │   ├── movies.ts    # Movie routes
│   │   ├── tvShows.ts   # TV show routes
│   │   ├── anime.ts     # Anime routes
│   │   ├── search.ts    # Search routes
│   │   └── discover.ts  # Discovery routes
│   ├── services/        # Business logic
│   │   └── tmdbService.ts
│   ├── middleware/      # Express middleware
│   │   └── errorHandler.ts
│   └── index.ts        # Main server file
├── package.json
└── tsconfig.json
```

### Frontend (Flutter)
```
mobile/
├── lib/
│   ├── core/
│   │   ├── theme/       # Material 3 theme
│   │   ├── router/      # Navigation
│   │   └── utils/       # Constants & helpers
│   ├── features/
│   │   ├── home/        # Home screen
│   │   ├── movies/      # Movie features
│   │   ├── tv_shows/    # TV show features
│   │   ├── anime/       # Anime features
│   │   ├── search/      # Search functionality
│   │   └── profile/     # User profile
│   └── main.dart
└── pubspec.yaml
```

## 🚀 Getting Started

### Prerequisites
- **Node.js** 18+ for backend
- **Flutter** 3.24+ for frontend
- **TMDB API Key** (free from [themoviedb.org](https://www.themoviedb.org/))

### Backend Setup
```bash
cd backend
npm install
cp .env.example .env
# Add your TMDB API key to .env
npm run dev
```

### Frontend Setup
```bash
cd mobile
flutter pub get
flutter run
```

## 🎨 Material 3 Theme Features

### **Segmented Buttons**
- Category selection (Movies, TV Shows, Anime)
- Sort options (Popular, Top Rated, Newest)
- Language switching (English, Arabic, Japanese)
- View type selection (Grid, List, Cards)

### **FABs & Buttons**
- Extended FAB for favorites
- Multiple FABs for different actions
- Elevated buttons for primary actions
- Outlined buttons for secondary actions

### **Typography**
- **Rubik font** for both Arabic and English
- Proper RTL support for Arabic content
- Material 3 typography scale
- Responsive text sizing

### **Colors & Theming**
- Material 3 color system
- Dynamic color from seed color
- Dark and light theme support
- Proper contrast ratios

## 📱 Screens & Features

### **Home Screen**
- Category selection with segmented buttons
- Sort options and filters
- Featured content grid
- Quick action buttons
- Arabic/English text examples

### **Theme Showcase Screen**
- Demonstrates all Material 3 components
- Multiple segmented button groups
- Various button styles
- Typography examples in both languages
- Color scheme demonstrations

## 🌐 API Endpoints

### Movies
- `GET /api/movies/popular` - Popular movies
- `GET /api/movies/top-rated` - Top rated movies
- `GET /api/movies/upcoming` - Upcoming movies
- `GET /api/movies/now-playing` - Now playing movies
- `GET /api/movies/:id` - Movie details

### TV Shows
- `GET /api/tv-shows/popular` - Popular TV shows
- `GET /api/tv-shows/top-rated` - Top rated TV shows
- `GET /api/tv-shows/on-the-air` - Currently airing
- `GET /api/tv-shows/airing-today` - Airing today
- `GET /api/tv-shows/:id` - TV show details

### Anime
- `GET /api/anime/movies` - Anime movies
- `GET /api/anime/tv-shows` - Anime TV shows
- `GET /api/anime/popular` - Popular anime

### Search & Discovery
- `GET /api/search/movies?q=query` - Search movies
- `GET /api/search/tv-shows?q=query` - Search TV shows
- `GET /api/search/all?q=query` - Search all content
- `GET /api/discover/movies` - Discover movies with filters
- `GET /api/discover/tv-shows` - Discover TV shows with filters

## 🔧 Development

### Backend Commands
```bash
npm run dev      # Start development server
npm run build    # Build TypeScript
npm run start    # Start production server
npm run lint     # Run ESLint
npm test         # Run tests
```

### Frontend Commands
```bash
flutter run                    # Run app
flutter build apk             # Build Android APK
flutter build ipa             # Build iOS IPA
flutter test                  # Run tests
flutter pub outdated          # Check dependencies
```

## 📦 Dependencies

### Backend
- **Express** - Web framework
- **TypeScript** - Type safety
- **Axios** - HTTP client for TMDB API
- **Cors** - Cross-origin requests
- **Helmet** - Security middleware
- **Morgan** - Request logging
- **Joi** - Input validation

### Frontend
- **flutter_riverpod** - State management
- **go_router** - Navigation
- **google_fonts** - Rubik font
- **cached_network_image** - Image caching
- **dio** - HTTP client
- **hive** - Local storage
- **material_design_icons_flutter** - Icons

## 🎯 Next Steps

1. **Authentication**: Add user login/signup
2. **Favorites**: Implement user favorites
3. **Watchlist**: Personal watchlist feature
4. **Reviews**: User reviews and ratings
5. **Social**: Share and discuss content
6. **Offline**: Full offline mode
7. **Push Notifications**: Content updates
8. **Video Player**: In-app video streaming

## 📄 License

This project is licensed under the MIT License.

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines and submit pull requests.

---

**Built with ❤️ using TypeScript + Flutter + Material 3**