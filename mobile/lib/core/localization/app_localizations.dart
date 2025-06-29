import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('ar', 'SA'),
  ];

  Map<String, String> get _localizedStrings {
    switch (locale.languageCode) {
      case 'ar':
        return _arabicStrings;
      default:
        return _englishStrings;
    }
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // Navigation
  String get home => translate('home');
  String get library => translate('library');
  String get profile => translate('profile');
  String get search => translate('search');
  String get settings => translate('settings');
  String get downloads => translate('downloads');

  // Content Types
  String get movies => translate('movies');
  String get tvShows => translate('tv_shows');
  String get anime => translate('anime');
  String get trending => translate('trending');
  String get popular => translate('popular');
  String get topRated => translate('top_rated');
  String get upcoming => translate('upcoming');
  String get nowPlaying => translate('now_playing');
  String get onTheAir => translate('on_the_air');
  String get airingToday => translate('airing_today');

  // Actions
  String get play => translate('play');
  String get pause => translate('pause');
  String get stop => translate('stop');
  String get download => translate('download');
  String get share => translate('share');
  String get favorite => translate('favorite');
  String get bookmark => translate('bookmark');
  String get add => translate('add');
  String get remove => translate('remove');
  String get edit => translate('edit');
  String get delete => translate('delete');
  String get cancel => translate('cancel');
  String get save => translate('save');
  String get ok => translate('ok');
  String get yes => translate('yes');
  String get no => translate('no');
  String get retry => translate('retry');
  String get refresh => translate('refresh');

  // Media
  String get watchTrailer => translate('watch_trailer');
  String get trailer => translate('trailer');
  String get details => translate('details');
  String get moreInfo => translate('more_info');
  String get cast => translate('cast');
  String get crew => translate('crew');
  String get director => translate('director');
  String get producer => translate('producer');
  String get writer => translate('writer');
  String get genres => translate('genres');
  String get releaseDate => translate('release_date');
  String get duration => translate('duration');
  String get rating => translate('rating');
  String get overview => translate('overview');
  String get synopsis => translate('synopsis');

  // Settings
  String get language => translate('language');
  String get theme => translate('theme');
  String get darkMode => translate('dark_mode');
  String get lightMode => translate('light_mode');
  String get systemMode => translate('system_mode');
  String get notifications => translate('notifications');
  String get downloadQuality => translate('download_quality');
  String get autoPlay => translate('auto_play');
  String get subtitles => translate('subtitles');
  String get playbackSpeed => translate('playback_speed');
  String get videoQuality => translate('video_quality');

  // User Profile
  String get login => translate('login');
  String get logout => translate('logout');
  String get signUp => translate('sign_up');
  String get username => translate('username');
  String get email => translate('email');
  String get password => translate('password');
  String get confirmPassword => translate('confirm_password');
  String get forgotPassword => translate('forgot_password');
  String get createAccount => translate('create_account');
  String get welcomeBack => translate('welcome_back');

  // Categories and Sections
  String get myLibrary => translate('my_library');
  String get watchlist => translate('watchlist');
  String get favorites => translate('favorites');
  String get history => translate('history');
  String get continueWatching => translate('continue_watching');
  String get recommendedForYou => translate('recommended_for_you');
  String get newReleases => translate('new_releases');
  String get featuredContent => translate('featured_content');

  // Search
  String get searchHint => translate('search_hint');
  String get searchResults => translate('search_results');
  String get noResults => translate('no_results');
  String get searchMovies => translate('search_movies');
  String get searchTvShows => translate('search_tv_shows');
  String get searchAnime => translate('search_anime');
  String get all => translate('all');
  String get searchForMoviesTv => translate('search_for_movies_tv');
  String get enterTitleActor => translate('enter_title_actor');
  String get searchFailed => translate('search_failed');
  String get noResultsFound => translate('no_results_found');
  String get tryDifferentKeywords => translate('try_different_keywords');

  // Player
  String get fullscreen => translate('fullscreen');
  String get exitFullscreen => translate('exit_fullscreen');
  String get volume => translate('volume');
  String get mute => translate('mute');
  String get unmute => translate('unmute');
  String get forward => translate('forward');
  String get rewind => translate('rewind');
  String get skipNext => translate('skip_next');
  String get skipPrevious => translate('skip_previous');
  String get pictureInPicture => translate('picture_in_picture');
  String get aspectRatio => translate('aspect_ratio');
  String get playbackSettings => translate('playback_settings');
  String get videoError => translate('video_error');
  String get videoSettings => translate('video_settings');
  String get lockControls => translate('lock_controls');
  String get unlockControls => translate('unlock_controls');
  String get toggleZoom => translate('toggle_zoom');
  String get videoZoom => translate('video_zoom');
  String get availableTrailers => translate('available_trailers');
  String get downloadOptions => translate('download_options');
  String get downloadedVideo => translate('downloaded_video');
  String get downloadComplete => translate('download_complete');
  String get downloadingTrailer => translate('downloading_trailer');

  // Error Messages
  String get error => translate('error');
  String get networkError => translate('network_error');
  String get loadingError => translate('loading_error');
  String get downloadError => translate('download_error');
  String get playbackError => translate('playback_error');
  String get connectionLost => translate('connection_lost');
  String get tryAgain => translate('try_again');
  String get noInternetConnection => translate('no_internet_connection');

  // Success Messages
  String get addedToFavorites => translate('added_to_favorites');
  String get removedFromFavorites => translate('removed_from_favorites');
  String get addedToWatchlist => translate('added_to_watchlist');
  String get removedFromWatchlist => translate('removed_from_watchlist');

  // Time and Dates
  String get today => translate('today');
  String get yesterday => translate('yesterday');
  String get thisWeek => translate('this_week');
  String get thisMonth => translate('this_month');
  String get thisYear => translate('this_year');
  String get recently => translate('recently');

  // Quality Options
  String get auto => translate('auto');
  String get low => translate('low');
  String get medium => translate('medium');
  String get high => translate('high');
  String get ultra => translate('ultra');
  String get hd => translate('hd');
  String get fullHd => translate('full_hd');
  String get fourK => translate('4k');

  // Miscellaneous
  String get loading => translate('loading');
  String get comingSoon => translate('coming_soon');
  String get available => translate('available');
  String get unavailable => translate('unavailable');
  String get free => translate('free');
  String get premium => translate('premium');
  String get episode => translate('episode');
  String get season => translate('season');
  String get episodes => translate('episodes');
  String get seasons => translate('seasons');
  String get year => translate('year');
  String get years => translate('years');
  String get minute => translate('minute');
  String get minutes => translate('minutes');
  String get hour => translate('hour');
  String get hours => translate('hours');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// English Strings
const Map<String, String> _englishStrings = {
  // Navigation
  'home': 'Home',
  'library': 'Library',
  'profile': 'Profile',
  'search': 'Search',
  'settings': 'Settings',
  'downloads': 'Downloads',

  // Content Types
  'movies': 'Movies',
  'tv_shows': 'TV Shows',
  'anime': 'Anime',
  'trending': 'Trending',
  'popular': 'Popular',
  'top_rated': 'Top Rated',
  'upcoming': 'Upcoming',
  'now_playing': 'Now Playing',
  'on_the_air': 'On The Air',
  'airing_today': 'Airing Today',

  // Actions
  'play': 'Play',
  'pause': 'Pause',
  'stop': 'Stop',
  'download': 'Download',
  'share': 'Share',
  'favorite': 'Favorite',
  'bookmark': 'Bookmark',
  'add': 'Add',
  'remove': 'Remove',
  'edit': 'Edit',
  'delete': 'Delete',
  'cancel': 'Cancel',
  'save': 'Save',
  'ok': 'OK',
  'yes': 'Yes',
  'no': 'No',
  'retry': 'Retry',
  'refresh': 'Refresh',

  // Media
  'watch_trailer': 'Watch Trailer',
  'trailer': 'Trailer',
  'details': 'Details',
  'more_info': 'More Info',
  'cast': 'Cast',
  'crew': 'Crew',
  'director': 'Director',
  'producer': 'Producer',
  'writer': 'Writer',
  'genres': 'Genres',
  'release_date': 'Release Date',
  'duration': 'Duration',
  'rating': 'Rating',
  'overview': 'Overview',
  'synopsis': 'Synopsis',

  // Settings
  'language': 'Language',
  'theme': 'Theme',
  'dark_mode': 'Dark Mode',
  'light_mode': 'Light Mode',
  'system_mode': 'System Mode',
  'notifications': 'Notifications',
  'download_quality': 'Download Quality',
  'auto_play': 'Auto Play',
  'subtitles': 'Subtitles',
  'playback_speed': 'Playback Speed',
  'video_quality': 'Video Quality',

  // User Profile
  'login': 'Login',
  'logout': 'Logout',
  'sign_up': 'Sign Up',
  'username': 'Username',
  'email': 'Email',
  'password': 'Password',
  'confirm_password': 'Confirm Password',
  'forgot_password': 'Forgot Password',
  'create_account': 'Create Account',
  'welcome_back': 'Welcome Back',

  // Categories and Sections
  'my_library': 'My Library',
  'watchlist': 'Watchlist',
  'favorites': 'Favorites',
  'history': 'History',
  'continue_watching': 'Continue Watching',
  'recommended_for_you': 'Recommended for You',
  'new_releases': 'New Releases',
  'featured_content': 'Featured Content',

  // Search
  'search_hint': 'Search movies, TV shows...',
  'search_results': 'Search Results',
  'no_results': 'No Results Found',
  'search_movies': 'Search Movies',
  'search_tv_shows': 'Search TV Shows',
  'search_anime': 'Search Anime',
  'all': 'All',
  'search_for_movies_tv': 'Search for movies and TV shows',
  'enter_title_actor': 'Enter a title, actor, or keyword above',
  'search_failed': 'Search failed',
  'no_results_found': 'No results found',
  'try_different_keywords': 'Try searching with different keywords',

  // Player
  'fullscreen': 'Fullscreen',
  'exit_fullscreen': 'Exit Fullscreen',
  'volume': 'Volume',
  'mute': 'Mute',
  'unmute': 'Unmute',
  'forward': 'Forward',
  'rewind': 'Rewind',
  'skip_next': 'Skip Next',
  'skip_previous': 'Skip Previous',
  'picture_in_picture': 'Picture in Picture',
  'aspect_ratio': 'Aspect Ratio',
  'playback_settings': 'Playback Settings',
  'video_error': 'Video Error',
  'video_settings': 'Video Settings',
  'lock_controls': 'Lock Controls',
  'unlock_controls': 'Unlock Controls',
  'toggle_zoom': 'Toggle Zoom',
  'video_zoom': 'Video Zoom',
  'available_trailers': 'Available Trailers',
  'download_options': 'Download Options',
  'downloaded_video': 'Downloaded Video',

  // Error Messages
  'error': 'Error',
  'network_error': 'Network Error',
  'loading_error': 'Loading Error',
  'download_error': 'Download Error',
  'playback_error': 'Playback Error',
  'connection_lost': 'Connection Lost',
  'try_again': 'Try Again',
  'no_internet_connection': 'No Internet Connection',

  // Success Messages
  'download_complete': 'Download Complete',
  'downloading_trailer': 'Downloading Trailer',
  'added_to_favorites': 'Added to Favorites',
  'removed_from_favorites': 'Removed from Favorites',
  'added_to_watchlist': 'Added to Watchlist',
  'removed_from_watchlist': 'Removed from Watchlist',

  // Time and Dates
  'today': 'Today',
  'yesterday': 'Yesterday',
  'this_week': 'This Week',
  'this_month': 'This Month',
  'this_year': 'This Year',
  'recently': 'Recently',

  // Quality Options
  'auto': 'Auto',
  'low': 'Low',
  'medium': 'Medium',
  'high': 'High',
  'ultra': 'Ultra',
  'hd': 'HD',
  'full_hd': 'Full HD',
  '4k': '4K',

  // Miscellaneous
  'loading': 'Loading',
  'coming_soon': 'Coming Soon',
  'available': 'Available',
  'unavailable': 'Unavailable',
  'free': 'Free',
  'premium': 'Premium',
  'episode': 'Episode',
  'season': 'Season',
  'episodes': 'Episodes',
  'seasons': 'Seasons',
  'year': 'Year',
  'years': 'Years',
  'minute': 'Minute',
  'minutes': 'Minutes',
  'hour': 'Hour',
  'hours': 'Hours',
};

// Arabic Strings
const Map<String, String> _arabicStrings = {
  // Navigation
  'home': 'الرئيسية',
  'library': 'المكتبة',
  'profile': 'الملف الشخصي',
  'search': 'البحث',
  'settings': 'الإعدادات',
  'downloads': 'التحميلات',

  // Content Types
  'movies': 'الأفلام',
  'tv_shows': 'المسلسلات',
  'anime': 'الأنمي',
  'trending': 'الرائج',
  'popular': 'الشائع',
  'top_rated': 'الأعلى تقييماً',
  'upcoming': 'قريباً',
  'now_playing': 'يُعرض الآن',
  'on_the_air': 'على الهواء',
  'airing_today': 'يُعرض اليوم',

  // Actions
  'play': 'تشغيل',
  'pause': 'إيقاف مؤقت',
  'stop': 'توقف',
  'download': 'تحميل',
  'share': 'مشاركة',
  'favorite': 'المفضلة',
  'bookmark': 'إشارة مرجعية',
  'add': 'إضافة',
  'remove': 'إزالة',
  'edit': 'تعديل',
  'delete': 'حذف',
  'cancel': 'إلغاء',
  'save': 'حفظ',
  'ok': 'موافق',
  'yes': 'نعم',
  'no': 'لا',
  'retry': 'إعادة المحاولة',
  'refresh': 'تحديث',

  // Media
  'watch_trailer': 'مشاهدة الإعلان',
  'trailer': 'الإعلان',
  'details': 'التفاصيل',
  'more_info': 'مزيد من المعلومات',
  'cast': 'طاقم التمثيل',
  'crew': 'طاقم العمل',
  'director': 'المخرج',
  'producer': 'المنتج',
  'writer': 'الكاتب',
  'genres': 'الأنواع',
  'release_date': 'تاريخ الإصدار',
  'duration': 'المدة',
  'rating': 'التقييم',
  'overview': 'نظرة عامة',
  'synopsis': 'الملخص',

  // Settings
  'language': 'اللغة',
  'theme': 'السمة',
  'dark_mode': 'الوضع المظلم',
  'light_mode': 'الوضع الفاتح',
  'system_mode': 'وضع النظام',
  'notifications': 'الإشعارات',
  'download_quality': 'جودة التحميل',
  'auto_play': 'التشغيل التلقائي',
  'subtitles': 'الترجمة',
  'playback_speed': 'سرعة التشغيل',
  'video_quality': 'جودة الفيديو',

  // User Profile
  'login': 'تسجيل الدخول',
  'logout': 'تسجيل الخروج',
  'sign_up': 'إنشاء حساب',
  'username': 'اسم المستخدم',
  'email': 'البريد الإلكتروني',
  'password': 'كلمة المرور',
  'confirm_password': 'تأكيد كلمة المرور',
  'forgot_password': 'نسيت كلمة المرور',
  'create_account': 'إنشاء حساب',
  'welcome_back': 'مرحباً بعودتك',

  // Categories and Sections
  'my_library': 'مكتبتي',
  'watchlist': 'قائمة المشاهدة',
  'favorites': 'المفضلة',
  'history': 'التاريخ',
  'continue_watching': 'متابعة المشاهدة',
  'recommended_for_you': 'مُوصى لك',
  'new_releases': 'إصدارات جديدة',
  'featured_content': 'المحتوى المميز',

  // Search
  'search_hint': 'البحث في الأفلام والمسلسلات...',
  'search_results': 'نتائج البحث',
  'no_results': 'لا توجد نتائج',
  'search_movies': 'البحث في الأفلام',
  'search_tv_shows': 'البحث في المسلسلات',
  'search_anime': 'البحث في الأنمي',
  'all': 'الكل',
  'search_for_movies_tv': 'البحث عن الأفلام والمسلسلات',
  'enter_title_actor': 'أدخل عنواناً أو ممثلاً أو كلمة مفتاحية أعلاه',
  'search_failed': 'فشل البحث',
  'no_results_found': 'لم يتم العثور على نتائج',
  'try_different_keywords': 'جرب البحث بكلمات مفتاحية مختلفة',

  // Player
  'fullscreen': 'ملء الشاشة',
  'exit_fullscreen': 'الخروج من ملء الشاشة',
  'volume': 'الصوت',
  'mute': 'كتم الصوت',
  'unmute': 'إلغاء كتم الصوت',
  'forward': 'للأمام',
  'rewind': 'للخلف',
  'skip_next': 'التالي',
  'skip_previous': 'السابق',
  'picture_in_picture': 'صورة في صورة',
  'aspect_ratio': 'نسبة العرض إلى الارتفاع',
  'playback_settings': 'إعدادات التشغيل',
  'video_error': 'خطأ في الفيديو',
  'video_settings': 'إعدادات الفيديو',
  'lock_controls': 'قفل الأزرار',
  'unlock_controls': 'إلغاء قفل الأزرار',
  'toggle_zoom': 'تبديل التكبير',
  'video_zoom': 'تكبير الفيديو',
  'available_trailers': 'العروض المتاحة',
  'download_options': 'خيارات التحميل',
  'downloaded_video': 'الفيديو المحمل',

  // Error Messages
  'error': 'خطأ',
  'network_error': 'خطأ في الشبكة',
  'loading_error': 'خطأ في التحميل',
  'download_error': 'خطأ في التحميل',
  'playback_error': 'خطأ في التشغيل',
  'connection_lost': 'انقطع الاتصال',
  'try_again': 'حاول مرة أخرى',
  'no_internet_connection': 'لا يوجد اتصال بالإنترنت',

  // Success Messages
  'download_complete': 'اكتمل التحميل',
  'downloading_trailer': 'تحميل العرض',
  'added_to_favorites': 'تم إضافته إلى المفضلة',
  'removed_from_favorites': 'تم حذفه من المفضلة',
  'added_to_watchlist': 'تم إضافته إلى قائمة المشاهدة',
  'removed_from_watchlist': 'تم حذفه من قائمة المشاهدة',

  // Time and Dates
  'today': 'اليوم',
  'yesterday': 'أمس',
  'this_week': 'هذا الأسبوع',
  'this_month': 'هذا الشهر',
  'this_year': 'هذا العام',
  'recently': 'مؤخراً',

  // Quality Options
  'auto': 'تلقائي',
  'low': 'منخفض',
  'medium': 'متوسط',
  'high': 'عالي',
  'ultra': 'فائق',
  'hd': 'عالي الدقة',
  'full_hd': 'عالي الدقة كاملاً',
  '4k': '4K',

  // Miscellaneous
  'loading': 'جاري التحميل',
  'coming_soon': 'قريباً',
  'available': 'متاح',
  'unavailable': 'غير متاح',
  'free': 'مجاني',
  'premium': 'مميز',
  'episode': 'حلقة',
  'season': 'موسم',
  'episodes': 'حلقات',
  'seasons': 'مواسم',
  'year': 'سنة',
  'years': 'سنوات',
  'minute': 'دقيقة',
  'minutes': 'دقائق',
  'hour': 'ساعة',
  'hours': 'ساعات',
};
