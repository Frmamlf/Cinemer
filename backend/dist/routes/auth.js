"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const authService_1 = require("../services/authService");
const router = (0, express_1.Router)();
router.post('/login', async (req, res) => {
    try {
        const { username, email, password } = req.body;
        const loginIdentifier = username || email;
        if (!loginIdentifier || !password) {
            res.status(400).json({
                error: 'Username/email and password are required'
            });
            return;
        }
        const apiKey = process.env.TMDB_API_KEY;
        if (!apiKey) {
            res.status(500).json({
                error: 'TMDB API key not configured'
            });
            return;
        }
        const tokenResponse = await authService_1.tmdbAuthService.createRequestToken(apiKey);
        const validatedToken = await authService_1.tmdbAuthService.validateWithLogin(apiKey, loginIdentifier, password, tokenResponse.request_token);
        const sessionResponse = await authService_1.tmdbAuthService.createSession(apiKey, validatedToken.request_token);
        const userDetails = await authService_1.tmdbAuthService.getUserDetails(apiKey, sessionResponse.session_id);
        res.json({
            success: true,
            user: {
                id: userDetails.id,
                username: userDetails.username,
                name: userDetails.name,
                avatar: userDetails.avatar
            },
            session: {
                sessionId: sessionResponse.session_id,
                apiKey: apiKey
            }
        });
    }
    catch (error) {
        console.error('Login error:', error);
        res.status(401).json({
            error: error instanceof Error ? error.message : 'Authentication failed'
        });
    }
});
router.post('/validate-api-key', async (req, res) => {
    try {
        const { apiKey } = req.body;
        if (!apiKey) {
            res.status(400).json({
                error: 'API key is required'
            });
            return;
        }
        const isValid = await authService_1.tmdbAuthService.validateApiKey(apiKey);
        res.json({
            valid: isValid
        });
    }
    catch (error) {
        console.error('API key validation error:', error);
        res.status(500).json({
            error: 'Failed to validate API key'
        });
    }
});
router.get('/user', async (req, res) => {
    try {
        const authHeader = req.headers.authorization;
        const sessionId = req.headers['x-session-id'];
        if (!authHeader || !sessionId) {
            res.status(401).json({
                error: 'Authorization header and session ID are required'
            });
            return;
        }
        const apiKey = authHeader.replace('Bearer ', '');
        const userDetails = await authService_1.tmdbAuthService.getUserDetails(apiKey, sessionId);
        res.json({
            user: {
                id: userDetails.id,
                username: userDetails.username,
                name: userDetails.name,
                avatar: userDetails.avatar
            }
        });
    }
    catch (error) {
        console.error('Get user error:', error);
        res.status(401).json({
            error: 'Failed to get user details'
        });
    }
});
router.post('/logout', (req, res) => {
    res.json({
        success: true,
        message: 'Logged out successfully'
    });
});
exports.default = router;
//# sourceMappingURL=auth.js.map