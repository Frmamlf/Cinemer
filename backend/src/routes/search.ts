import { Router, Response } from 'express';
import { tmdbService } from '../services/tmdbService';
import { extractUserInfo, AuthenticatedRequest } from '../middleware/auth';

const router = Router();

// Apply middleware to extract user info (optional)
router.use(extractUserInfo);

// Search movies
router.get('/movies', async (req: AuthenticatedRequest, res: Response) => {
  try {
    const query = req.query.q as string;
    const page = parseInt(req.query.page as string) || 1;
    
    if (!query) {
      res.status(400).json({ error: 'Query parameter is required' });
      return;
    }

    const results = await tmdbService.searchMovies(query, page);
    res.json(results);
  } catch (error) {
    res.status(500).json({ error: 'Failed to search movies' });
  }
});

// Search TV shows
router.get('/tv-shows', async (req: AuthenticatedRequest, res: Response) => {
  try {
    const query = req.query.q as string;
    const page = parseInt(req.query.page as string) || 1;
    
    if (!query) {
      res.status(400).json({ error: 'Query parameter is required' });
      return;
    }

    const results = await tmdbService.searchTVShows(query, page);
    res.json(results);
  } catch (error) {
    res.status(500).json({ error: 'Failed to search TV shows' });
  }
});

// Search everything (multi search)
router.get('/all', async (req: AuthenticatedRequest, res: Response) => {
  try {
    const query = req.query.q as string;
    const page = parseInt(req.query.page as string) || 1;
    
    if (!query) {
      res.status(400).json({ error: 'Query parameter is required' });
      return;
    }

    const results = await tmdbService.searchMulti(query, page);
    res.json(results);
  } catch (error) {
    res.status(500).json({ error: 'Failed to search content' });
  }
});

export default router;
