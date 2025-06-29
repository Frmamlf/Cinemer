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
export declare class TMDBAuthService {
    private baseUrl;
    createRequestToken(apiKey: string): Promise<TMDBAuthResponse>;
    validateWithLogin(apiKey: string, username: string, password: string, requestToken: string): Promise<TMDBAuthResponse>;
    createSession(apiKey: string, requestToken: string): Promise<TMDBSessionResponse>;
    getUserDetails(apiKey: string, sessionId: string): Promise<TMDBUser>;
    validateApiKey(apiKey: string): Promise<boolean>;
}
export declare const tmdbAuthService: TMDBAuthService;
//# sourceMappingURL=authService.d.ts.map