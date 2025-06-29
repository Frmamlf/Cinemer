import axios from 'axios';

export interface TMDBUser {
  id: number;
  username: string;
  name: string;
  include_adult: boolean;
  iso_639_1: string;
  iso_3166_1: string;
  avatar?: {
    gravatar?: {
      hash: string;
    };
    tmdb?: {
      avatar_path: string | null;
    };
  };
}

export interface TMDBAuthResponse {
  success: boolean;
  expires_at: string;
  request_token: string;
}

export interface TMDBSessionResponse {
  success: boolean;
  session_id: string;
}

export class TMDBAuthService {
  private baseUrl = 'https://api.themoviedb.org/3';

  async createRequestToken(apiKey: string): Promise<TMDBAuthResponse> {
    try {
      const response = await axios.get(`${this.baseUrl}/authentication/token/new`, {
        params: { api_key: apiKey }
      });
      return response.data;
    } catch (error) {
      console.error('TMDB create request token error:', error);
      throw new Error('Failed to create TMDB request token');
    }
  }

  async validateWithLogin(apiKey: string, username: string, password: string, requestToken: string): Promise<TMDBAuthResponse> {
    try {
      const response = await axios.post(`${this.baseUrl}/authentication/token/validate_with_login`, {
        username,
        password,
        request_token: requestToken
      }, {
        params: { api_key: apiKey }
      });
      return response.data;
    } catch (error) {
      console.error('TMDB validate with login error:', error);
      throw new Error('Invalid TMDB credentials');
    }
  }

  async createSession(apiKey: string, requestToken: string): Promise<TMDBSessionResponse> {
    try {
      const response = await axios.post(`${this.baseUrl}/authentication/session/new`, {
        request_token: requestToken
      }, {
        params: { api_key: apiKey }
      });
      return response.data;
    } catch (error) {
      console.error('TMDB create session error:', error);
      throw new Error('Failed to create TMDB session');
    }
  }

  async getUserDetails(apiKey: string, sessionId: string): Promise<TMDBUser> {
    try {
      const response = await axios.get(`${this.baseUrl}/account`, {
        params: { 
          api_key: apiKey,
          session_id: sessionId
        }
      });
      return response.data;
    } catch (error) {
      console.error('TMDB get user details error:', error);
      throw new Error('Failed to get TMDB user details');
    }
  }

  async validateApiKey(apiKey: string): Promise<boolean> {
    try {
      await axios.get(`${this.baseUrl}/configuration`, {
        params: { api_key: apiKey }
      });
      return true;
    } catch (error) {
      return false;
    }
  }
}

export const tmdbAuthService = new TMDBAuthService();
