import axios from 'axios';

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

export class TMDBService {
  private defaultApiKey: string;
  private baseUrl: string;

  constructor() {
    this.defaultApiKey = process.env.TMDB_API_KEY || '';
    this.baseUrl = process.env.TMDB_BASE_URL || 'https://api.themoviedb.org/3';
  }

  private async makeRequest<T>(endpoint: string, params: Record<string, any> = {}, method: 'GET' | 'POST' | 'DELETE' = 'GET'): Promise<T> {
    const apiKey = this.defaultApiKey;
    
    if (!apiKey) {
      throw new Error('TMDB API key is not configured');
    }

    try {
      let response;
      const config = {
        params: method === 'GET' ? { api_key: apiKey, ...params } : { api_key: apiKey },
        data: method !== 'GET' ? params : undefined,
      };

      switch (method) {
        case 'POST':
          response = await axios.post(`${this.baseUrl}${endpoint}`, config.data, { params: config.params });
          break;
        case 'DELETE':
          response = await axios.delete(`${this.baseUrl}${endpoint}`, { params: config.params });
          break;
        default:
          response = await axios.get(`${this.baseUrl}${endpoint}`, { params: config.params });
      }

      return response.data;
    } catch (error) {
      console.error(`TMDB API error for ${endpoint}:`, error);
      if (error instanceof Error) {
        console.error('Error message:', error.message);
      }
      throw new Error(`Failed to fetch data from TMDB: ${error}`);
    }
  }

  // Movies
  async getPopularMovies(page = 1): Promise<TMDBResponse<Movie>> {
    return this.makeRequest<TMDBResponse<Movie>>('/movie/popular', { page });
  }

  async getTopRatedMovies(page = 1): Promise<TMDBResponse<Movie>> {
    return this.makeRequest<TMDBResponse<Movie>>('/movie/top_rated', { page });
  }

  async getUpcomingMovies(page = 1): Promise<TMDBResponse<Movie>> {
    return this.makeRequest<TMDBResponse<Movie>>('/movie/upcoming', { page });
  }

  async getNowPlayingMovies(page = 1): Promise<TMDBResponse<Movie>> {
    return this.makeRequest<TMDBResponse<Movie>>('/movie/now_playing', { page });
  }

  async getMovieDetails(id: number): Promise<Movie> {
    return this.makeRequest<Movie>(`/movie/${id}`, {});
  }

  // TV Shows
  async getPopularTVShows(page = 1): Promise<TMDBResponse<TVShow>> {
    return this.makeRequest<TMDBResponse<TVShow>>('/tv/popular', { page });
  }

  async getTopRatedTVShows(page = 1): Promise<TMDBResponse<TVShow>> {
    return this.makeRequest<TMDBResponse<TVShow>>('/tv/top_rated', { page });
  }

  async getOnTheAirTVShows(page = 1): Promise<TMDBResponse<TVShow>> {
    return this.makeRequest<TMDBResponse<TVShow>>('/tv/on_the_air', { page });
  }

  async getAiringTodayTVShows(page = 1): Promise<TMDBResponse<TVShow>> {
    return this.makeRequest<TMDBResponse<TVShow>>('/tv/airing_today', { page });
  }

  async getTVShowDetails(id: number): Promise<TVShow> {
    return this.makeRequest<TVShow>(`/tv/${id}`, {});
  }

  // Search
  async searchMovies(query: string, page = 1): Promise<TMDBResponse<Movie>> {
    return this.makeRequest<TMDBResponse<Movie>>('/search/movie', { query, page });
  }

  async searchTVShows(query: string, page = 1): Promise<TMDBResponse<TVShow>> {
    return this.makeRequest<TMDBResponse<TVShow>>('/search/tv', { query, page });
  }

  async searchMulti(query: string, page = 1): Promise<TMDBResponse<Movie | TVShow>> {
    return this.makeRequest<TMDBResponse<Movie | TVShow>>('/search/multi', { query, page });
  }

  // Discover
  async discoverMovies(params: Record<string, any> = {}): Promise<TMDBResponse<Movie>> {
    return this.makeRequest<TMDBResponse<Movie>>('/discover/movie', params);
  }

  async discoverTVShows(params: Record<string, any> = {}): Promise<TMDBResponse<TVShow>> {
    return this.makeRequest<TMDBResponse<TVShow>>('/discover/tv', params);
  }

  // Trending
  async getTrendingMovies(timeWindow: 'day' | 'week' = 'week'): Promise<TMDBResponse<Movie>> {
    return this.makeRequest<TMDBResponse<Movie>>(`/trending/movie/${timeWindow}`, {});
  }

  async getTrendingTVShows(timeWindow: 'day' | 'week' = 'week'): Promise<TMDBResponse<TVShow>> {
    return this.makeRequest<TMDBResponse<TVShow>>(`/trending/tv/${timeWindow}`, {});
  }

  async getTrendingAll(timeWindow: 'day' | 'week' = 'week'): Promise<TMDBResponse<Movie | TVShow>> {
    return this.makeRequest<TMDBResponse<Movie | TVShow>>(`/trending/all/${timeWindow}`, {});
  }

  // Anime (using genre filtering)
  async getAnimeMovies(page = 1): Promise<TMDBResponse<Movie>> {
    return this.makeRequest<TMDBResponse<Movie>>('/discover/movie', {
      page,
      with_genres: '16', // Animation genre ID
      with_origin_country: 'JP', // Japanese origin
    });
  }

  async getAnimeTVShows(page = 1): Promise<TMDBResponse<TVShow>> {
    return this.makeRequest<TMDBResponse<TVShow>>('/discover/tv', {
      page,
      with_genres: '16', // Animation genre ID
      with_origin_country: 'JP', // Japanese origin
    });
  }

  // Account endpoints for TMDB sync
  async getAccountWatchlist(accountId: string, sessionId: string, page = 1): Promise<TMDBResponse<Movie | TVShow>> {
    return this.makeRequest<TMDBResponse<Movie | TVShow>>(`/account/${accountId}/watchlist/movies`, {
      page,
      session_id: sessionId,
    });
  }

  async getAccountFavorites(accountId: string, sessionId: string, page = 1): Promise<TMDBResponse<Movie | TVShow>> {
    return this.makeRequest<TMDBResponse<Movie | TVShow>>(`/account/${accountId}/favorite/movies`, {
      page,
      session_id: sessionId,
    });
  }

  async getAccountLists(accountId: string, sessionId: string, page = 1): Promise<any> {
    return this.makeRequest<any>(`/account/${accountId}/lists`, {
      page,
      session_id: sessionId,
    });
  }

  async addToWatchlist(accountId: string, sessionId: string, mediaType: string, mediaId: number, watchlist: boolean): Promise<any> {
    return this.makeRequest<any>(`/account/${accountId}/watchlist`, {
      session_id: sessionId,
      media_type: mediaType,
      media_id: mediaId,
      watchlist,
    }, 'POST');
  }

  async addToFavorites(accountId: string, sessionId: string, mediaType: string, mediaId: number, favorite: boolean): Promise<any> {
    return this.makeRequest<any>(`/account/${accountId}/favorite`, {
      session_id: sessionId,
      media_type: mediaType,
      media_id: mediaId,
      favorite,
    }, 'POST');
  }

  async createList(sessionId: string, name: string, description: string, isPublic: boolean): Promise<any> {
    return this.makeRequest<any>('/list', {
      session_id: sessionId,
      name,
      description,
      public: isPublic,
    }, 'POST');
  }

  async deleteList(listId: number, sessionId: string): Promise<any> {
    return this.makeRequest<any>(`/list/${listId}`, {
      session_id: sessionId,
    }, 'DELETE');
  }

  async addToList(listId: number, sessionId: string, mediaType: string, mediaId: number): Promise<any> {
    return this.makeRequest<any>(`/list/${listId}/add_item`, {
      session_id: sessionId,
      media_type: mediaType,
      media_id: mediaId,
    }, 'POST');
  }

  async removeFromList(listId: number, sessionId: string, mediaType: string, mediaId: number): Promise<any> {
    return this.makeRequest<any>(`/list/${listId}/remove_item`, {
      session_id: sessionId,
      media_type: mediaType,
      media_id: mediaId,
    }, 'POST');
  }

}

export const tmdbService = new TMDBService();
