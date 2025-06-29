export interface TMDBConfig {
    apiKey: string;
    baseUrl: string;
}
export interface Movie {
    id: number;
    title: string;
    overview: string;
    poster_path: string | null;
    backdrop_path: string | null;
    release_date: string;
    vote_average: number;
    vote_count: number;
    genre_ids: number[];
    adult: boolean;
    original_language: string;
    original_title: string;
    popularity: number;
    video: boolean;
}
export interface TVShow {
    id: number;
    name: string;
    overview: string;
    poster_path: string | null;
    backdrop_path: string | null;
    first_air_date: string;
    vote_average: number;
    vote_count: number;
    genre_ids: number[];
    origin_country: string[];
    original_language: string;
    original_name: string;
    popularity: number;
}
export interface TMDBResponse<T> {
    page: number;
    results: T[];
    total_pages: number;
    total_results: number;
}
export declare class TMDBService {
    private defaultApiKey;
    private baseUrl;
    constructor();
    private makeRequest;
    getPopularMovies(page?: number): Promise<TMDBResponse<Movie>>;
    getTopRatedMovies(page?: number): Promise<TMDBResponse<Movie>>;
    getUpcomingMovies(page?: number): Promise<TMDBResponse<Movie>>;
    getNowPlayingMovies(page?: number): Promise<TMDBResponse<Movie>>;
    getMovieDetails(id: number): Promise<Movie>;
    getPopularTVShows(page?: number): Promise<TMDBResponse<TVShow>>;
    getTopRatedTVShows(page?: number): Promise<TMDBResponse<TVShow>>;
    getOnTheAirTVShows(page?: number): Promise<TMDBResponse<TVShow>>;
    getAiringTodayTVShows(page?: number): Promise<TMDBResponse<TVShow>>;
    getTVShowDetails(id: number): Promise<TVShow>;
    searchMovies(query: string, page?: number): Promise<TMDBResponse<Movie>>;
    searchTVShows(query: string, page?: number): Promise<TMDBResponse<TVShow>>;
    searchMulti(query: string, page?: number): Promise<TMDBResponse<Movie | TVShow>>;
    discoverMovies(params?: Record<string, any>): Promise<TMDBResponse<Movie>>;
    discoverTVShows(params?: Record<string, any>): Promise<TMDBResponse<TVShow>>;
    getTrendingMovies(timeWindow?: 'day' | 'week'): Promise<TMDBResponse<Movie>>;
    getTrendingTVShows(timeWindow?: 'day' | 'week'): Promise<TMDBResponse<TVShow>>;
    getTrendingAll(timeWindow?: 'day' | 'week'): Promise<TMDBResponse<Movie | TVShow>>;
    getAnimeMovies(page?: number): Promise<TMDBResponse<Movie>>;
    getAnimeTVShows(page?: number): Promise<TMDBResponse<TVShow>>;
    getAccountWatchlist(accountId: string, sessionId: string, page?: number): Promise<TMDBResponse<Movie | TVShow>>;
    getAccountFavorites(accountId: string, sessionId: string, page?: number): Promise<TMDBResponse<Movie | TVShow>>;
    getAccountLists(accountId: string, sessionId: string, page?: number): Promise<any>;
    addToWatchlist(accountId: string, sessionId: string, mediaType: string, mediaId: number, watchlist: boolean): Promise<any>;
    addToFavorites(accountId: string, sessionId: string, mediaType: string, mediaId: number, favorite: boolean): Promise<any>;
    createList(sessionId: string, name: string, description: string, isPublic: boolean): Promise<any>;
    deleteList(listId: number, sessionId: string): Promise<any>;
    addToList(listId: number, sessionId: string, mediaType: string, mediaId: number): Promise<any>;
    removeFromList(listId: number, sessionId: string, mediaType: string, mediaId: number): Promise<any>;
}
export declare const tmdbService: TMDBService;
//# sourceMappingURL=tmdbService.d.ts.map