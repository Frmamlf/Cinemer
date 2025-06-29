import { Router, Response } from 'express';
import { tmdbService } from '../services/tmdbService';
import { extractUserInfo, AuthenticatedRequest } from '../middleware/auth';

const router = Router();

// Apply middleware to extract user info (optional)
router.use(extractUserInfo);

// Get popular TV shows
router.get('/popular', async (req: AuthenticatedRequest, res: Response) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const tvShows = await tmdbService.getPopularTVShows(page);
    res.json(tvShows);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch popular TV shows' });
  }
});

// Get top rated TV shows
router.get('/top-rated', async (req: AuthenticatedRequest, res: Response) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const tvShows = await tmdbService.getTopRatedTVShows(page);
    res.json(tvShows);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch top rated TV shows' });
  }
});

// Get on the air TV shows
router.get('/on-the-air', async (req: AuthenticatedRequest, res: Response) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const tvShows = await tmdbService.getOnTheAirTVShows(page);
    res.json(tvShows);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch on the air TV shows' });
  }
});

// Get airing today TV shows
router.get('/airing-today', async (req: AuthenticatedRequest, res: Response) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const tvShows = await tmdbService.getAiringTodayTVShows(page);
    res.json(tvShows);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch airing today TV shows' });
  }
});

// Get TV show details
router.get('/:id', async (req: AuthenticatedRequest, res: Response) => {
  try {
    const id = parseInt(req.params.id as string);
    if (isNaN(id)) {
      res.status(400).json({ error: 'Invalid TV show ID' });
      return;
    }
    const tvShow = await tmdbService.getTVShowDetails(id);
    res.json(tvShow);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch TV show details' });
  }
});

export default router;
