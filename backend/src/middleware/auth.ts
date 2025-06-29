import { Request, Response, NextFunction } from 'express';

export interface AuthenticatedRequest extends Request {
  userId?: string;
}

// Simple middleware that extracts user info but doesn't require API key
export const extractUserInfo = (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
  // Try to get user session from Authorization header
  const authHeader = req.headers.authorization;
  if (authHeader && authHeader.startsWith('Bearer ')) {
    req.userId = authHeader.replace('Bearer ', '');
  }
  
  // Always allow access - API key is handled by the server
  next();
};

export const requireAuth = (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
  const authHeader = req.headers.authorization;
  
  if (!authHeader) {
    res.status(401).json({
      error: 'Authentication required'
    });
    return;
  }
  
  req.userId = authHeader.replace('Bearer ', '');
  next();
};
