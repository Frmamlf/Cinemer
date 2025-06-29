import { Router, Request, Response } from 'express';
import { tmdbAuthService } from '../services/authService';

const router = Router();

interface AuthRequest extends Request {
  user?: {
    apiKey: string;
    sessionId: string;
    userId: number;
  };
}

// POST /api/auth/login
router.post('/login', async (req: Request, res: Response) => {
  try {
    const { username, email, password } = req.body;
    
    // Support both username and email
    const loginIdentifier = username || email;

    if (!loginIdentifier || !password) {
      res.status(400).json({
        error: 'Username/email and password are required'
      });
      return;
    }

    // Use the environment API key
    const apiKey = process.env.TMDB_API_KEY;
    if (!apiKey) {
      res.status(500).json({
        error: 'TMDB API key not configured'
      });
      return;
    }

    // Create request token
    const tokenResponse = await tmdbAuthService.createRequestToken(apiKey);
    
    // Validate credentials
    const validatedToken = await tmdbAuthService.validateWithLogin(
      apiKey,
      loginIdentifier,
      password,
      tokenResponse.request_token
    );

    // Create session
    const sessionResponse = await tmdbAuthService.createSession(
      apiKey,
      validatedToken.request_token
    );

    // Get user details
    const userDetails = await tmdbAuthService.getUserDetails(
      apiKey,
      sessionResponse.session_id
    );

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

  } catch (error) {
    console.error('Login error:', error);
    res.status(401).json({
      error: error instanceof Error ? error.message : 'Authentication failed'
    });
  }
});

// POST /api/auth/validate-api-key
router.post('/validate-api-key', async (req: Request, res: Response) => {
  try {
    const { apiKey } = req.body;

    if (!apiKey) {
      res.status(400).json({
        error: 'API key is required'
      });
      return;
    }

    const isValid = await tmdbAuthService.validateApiKey(apiKey);
    
    res.json({
      valid: isValid
    });

  } catch (error) {
    console.error('API key validation error:', error);
    res.status(500).json({
      error: 'Failed to validate API key'
    });
  }
});

// GET /api/auth/user
router.get('/user', async (req: AuthRequest, res: Response) => {
  try {
    const authHeader = req.headers.authorization;
    const sessionId = req.headers['x-session-id'] as string;
    
    if (!authHeader || !sessionId) {
      res.status(401).json({
        error: 'Authorization header and session ID are required'
      });
      return;
    }

    const apiKey = authHeader.replace('Bearer ', '');
    
    const userDetails = await tmdbAuthService.getUserDetails(apiKey, sessionId);
    
    res.json({
      user: {
        id: userDetails.id,
        username: userDetails.username,
        name: userDetails.name,
        avatar: userDetails.avatar
      }
    });

  } catch (error) {
    console.error('Get user error:', error);
    res.status(401).json({
      error: 'Failed to get user details'
    });
  }
});

// POST /api/auth/logout
router.post('/logout', (req: Request, res: Response) => {
  // Since we're using TMDB sessions, we just need to clear client-side data
  res.json({
    success: true,
    message: 'Logged out successfully'
  });
});

export default router;
