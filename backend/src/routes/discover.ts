import { Router, Response } from 'express';
import { tmdbService } from '../services/tmdbService';
import { extractUserInfo, AuthenticatedRequest } from '../middleware/auth';

const router = Router();

// Apply middleware to extract user info (optional)
router.use(extractUserInfo);

// Discover movies
router.get('/movies', async (req: AuthenticatedRequest, res: Response) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const genre = req.query.genre as string;
    const year = req.query.year as string;
    const sortBy = req.query.sort_by as string || 'popularity.desc';
    
    const params: Record<string, any> = { page, sort_by: sortBy };
    
    if (genre) params.with_genres = genre;
    if (year) params.year = year;

    const results = await tmdbService.discoverMovies(params);
    res.json(results);
  } catch (error) {
    res.status(500).json({ error: 'Failed to discover movies' });
  }
});

// Discover TV shows
router.get('/tv-shows', async (req: AuthenticatedRequest, res: Response) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const genre = req.query.genre as string;
    const year = req.query.year as string;
    const sortBy = req.query.sort_by as string || 'popularity.desc';
    
    const params: Record<string, any> = { page, sort_by: sortBy };
    
    if (genre) params.with_genres = genre;
    if (year) params.first_air_date_year = year;

    const results = await tmdbService.discoverTVShows(params);
    res.json(results);
  } catch (error) {
    res.status(500).json({ error: 'Failed to discover TV shows' });
  }
});

export default router;
