"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.tmdbAuthService = exports.TMDBAuthService = void 0;
const axios_1 = __importDefault(require("axios"));
class TMDBAuthService {
    constructor() {
        this.baseUrl = 'https://api.themoviedb.org/3';
    }
    async createRequestToken(apiKey) {
        try {
            const response = await axios_1.default.get(`${this.baseUrl}/authentication/token/new`, {
                params: { api_key: apiKey }
            });
            return response.data;
        }
        catch (error) {
            console.error('TMDB create request token error:', error);
            throw new Error('Failed to create TMDB request token');
        }
    }
    async validateWithLogin(apiKey, username, password, requestToken) {
        try {
            const response = await axios_1.default.post(`${this.baseUrl}/authentication/token/validate_with_login`, {
                username,
                password,
                request_token: requestToken
            }, {
                params: { api_key: apiKey }
            });
            return response.data;
        }
        catch (error) {
            console.error('TMDB validate with login error:', error);
            throw new Error('Invalid TMDB credentials');
        }
    }
    async createSession(apiKey, requestToken) {
        try {
            const response = await axios_1.default.post(`${this.baseUrl}/authentication/session/new`, {
                request_token: requestToken
            }, {
                params: { api_key: apiKey }
            });
            return response.data;
        }
        catch (error) {
            console.error('TMDB create session error:', error);
            throw new Error('Failed to create TMDB session');
        }
    }
    async getUserDetails(apiKey, sessionId) {
        try {
            const response = await axios_1.default.get(`${this.baseUrl}/account`, {
                params: {
                    api_key: apiKey,
                    session_id: sessionId
                }
            });
            return response.data;
        }
        catch (error) {
            console.error('TMDB get user details error:', error);
            throw new Error('Failed to get TMDB user details');
        }
    }
    async validateApiKey(apiKey) {
        try {
            await axios_1.default.get(`${this.baseUrl}/configuration`, {
                params: { api_key: apiKey }
            });
            return true;
        }
        catch (error) {
            return false;
        }
    }
}
exports.TMDBAuthService = TMDBAuthService;
exports.tmdbAuthService = new TMDBAuthService();
//# sourceMappingURL=authService.js.map