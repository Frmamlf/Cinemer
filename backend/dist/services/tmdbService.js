"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.tmdbService = exports.TMDBService = void 0;
const axios_1 = __importDefault(require("axios"));
class TMDBService {
    constructor() {
        this.defaultApiKey = process.env.TMDB_API_KEY || '';
        this.baseUrl = process.env.TMDB_BASE_URL || 'https://api.themoviedb.org/3';
    }
    async makeRequest(endpoint, params = {}, method = 'GET') {
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
                    response = await axios_1.default.post(`${this.baseUrl}${endpoint}`, config.data, { params: config.params });
                    break;
                case 'DELETE':
                    response = await axios_1.default.delete(`${this.baseUrl}${endpoint}`, { params: config.params });
                    break;
                default:
                    response = await axios_1.default.get(`${this.baseUrl}${endpoint}`, { params: config.params });
            }
            return response.data;
        }
        catch (error) {
            console.error(`TMDB API error for ${endpoint}:`, error);
            throw new Error(`Failed to fetch data from TMDB`);
        }
    }
    async getPopularMovies(page = 1) {
        return this.makeRequest('/movie/popular', { page });
    }
    async getTopRatedMovies(page = 1) {
        return this.makeRequest('/movie/top_rated', { page });
    }
    async getUpcomingMovies(page = 1) {
        return this.makeRequest('/movie/upcoming', { page });
    }
    async getNowPlayingMovies(page = 1) {
        return this.makeRequest('/movie/now_playing', { page });
    }
    async getMovieDetails(id) {
        return this.makeRequest(`/movie/${id}`, {});
    }
    async getPopularTVShows(page = 1) {
        return this.makeRequest('/tv/popular', { page });
    }
    async getTopRatedTVShows(page = 1) {
        return this.makeRequest('/tv/top_rated', { page });
    }
    async getOnTheAirTVShows(page = 1) {
        return this.makeRequest('/tv/on_the_air', { page });
    }
    async getAiringTodayTVShows(page = 1) {
        return this.makeRequest('/tv/airing_today', { page });
    }
    async getTVShowDetails(id) {
        return this.makeRequest(`/tv/${id}`, {});
    }
    async searchMovies(query, page = 1) {
        return this.makeRequest('/search/movie', { query, page });
    }
    async searchTVShows(query, page = 1) {
        return this.makeRequest('/search/tv', { query, page });
    }
    async searchMulti(query, page = 1) {
        return this.makeRequest('/search/multi', { query, page });
    }
    async discoverMovies(params = {}) {
        return this.makeRequest('/discover/movie', params);
    }
    async discoverTVShows(params = {}) {
        return this.makeRequest('/discover/tv', params);
    }
    async getTrendingMovies(timeWindow = 'week') {
        return this.makeRequest(`/trending/movie/${timeWindow}`, {});
    }
    async getTrendingTVShows(timeWindow = 'week') {
        return this.makeRequest(`/trending/tv/${timeWindow}`, {});
    }
    async getTrendingAll(timeWindow = 'week') {
        return this.makeRequest(`/trending/all/${timeWindow}`, {});
    }
    async getAnimeMovies(page = 1) {
        return this.makeRequest('/discover/movie', {
            page,
            with_genres: '16',
            with_origin_country: 'JP',
        });
    }
    async getAnimeTVShows(page = 1) {
        return this.makeRequest('/discover/tv', {
            page,
            with_genres: '16',
            with_origin_country: 'JP',
        });
    }
    async getAccountWatchlist(accountId, sessionId, page = 1) {
        return this.makeRequest(`/account/${accountId}/watchlist/movies`, {
            page,
            session_id: sessionId,
        });
    }
    async getAccountFavorites(accountId, sessionId, page = 1) {
        return this.makeRequest(`/account/${accountId}/favorite/movies`, {
            page,
            session_id: sessionId,
        });
    }
    async getAccountLists(accountId, sessionId, page = 1) {
        return this.makeRequest(`/account/${accountId}/lists`, {
            page,
            session_id: sessionId,
        });
    }
    async addToWatchlist(accountId, sessionId, mediaType, mediaId, watchlist) {
        return this.makeRequest(`/account/${accountId}/watchlist`, {
            session_id: sessionId,
            media_type: mediaType,
            media_id: mediaId,
            watchlist,
        }, 'POST');
    }
    async addToFavorites(accountId, sessionId, mediaType, mediaId, favorite) {
        return this.makeRequest(`/account/${accountId}/favorite`, {
            session_id: sessionId,
            media_type: mediaType,
            media_id: mediaId,
            favorite,
        }, 'POST');
    }
    async createList(sessionId, name, description, isPublic) {
        return this.makeRequest('/list', {
            session_id: sessionId,
            name,
            description,
            public: isPublic,
        }, 'POST');
    }
    async deleteList(listId, sessionId) {
        return this.makeRequest(`/list/${listId}`, {
            session_id: sessionId,
        }, 'DELETE');
    }
    async addToList(listId, sessionId, mediaType, mediaId) {
        return this.makeRequest(`/list/${listId}/add_item`, {
            session_id: sessionId,
            media_type: mediaType,
            media_id: mediaId,
        }, 'POST');
    }
    async removeFromList(listId, sessionId, mediaType, mediaId) {
        return this.makeRequest(`/list/${listId}/remove_item`, {
            session_id: sessionId,
            media_type: mediaType,
            media_id: mediaId,
        }, 'POST');
    }
}
exports.TMDBService = TMDBService;
exports.tmdbService = new TMDBService();
//# sourceMappingURL=tmdbService.js.map