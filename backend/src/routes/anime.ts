import { Router, Response } from 'express';
import { tmdbService } from '../services/tmdbService';
import { extractUserInfo, AuthenticatedRequest } from '../middleware/auth';

const router = Router();

// Apply middleware to extract user info (optional)
router.use(extractUserInfo);

// Get anime movies
router.get('/movies', async (req: AuthenticatedRequest, res: Response) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const animeMovies = await tmdbService.getAnimeMovies(page);
    res.json(animeMovies);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch anime movies' });
  }
});

// Get anime TV shows
router.get('/tv-shows', async (req: AuthenticatedRequest, res: Response) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const animeTVShows = await tmdbService.getAnimeTVShows(page);
    res.json(animeTVShows);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch anime TV shows' });
  }
});

// Get popular anime (combination of movies and TV shows)
router.get('/popular', async (req: AuthenticatedRequest, res: Response) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const [animeMovies, animeTVShows] = await Promise.all([
      tmdbService.getAnimeMovies(page),
      tmdbService.getAnimeTVShows(page)
    ]);
    
    const combinedResults = [
      ...animeMovies.results,
      ...animeTVShows.results
    ].sort((a, b) => b.popularity - a.popularity);

    res.json({
      page,
      results: combinedResults,
      total_pages: Math.max(animeMovies.total_pages, animeTVShows.total_pages),
      total_results: animeMovies.total_results + animeTVShows.total_results
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch popular anime' });
  }
});

export default router;
