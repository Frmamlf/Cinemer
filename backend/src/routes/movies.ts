import { Router, Response } from 'express';
import { tmdbService } from '../services/tmdbService';
import { extractUserInfo, AuthenticatedRequest } from '../middleware/auth';

const router = Router();

// Apply middleware to extract user info (optional)
router.use(extractUserInfo);

// Get popular movies
router.get('/popular', async (req: AuthenticatedRequest, res: Response) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const movies = await tmdbService.getPopularMovies(page);
    res.json(movies);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch popular movies' });
  }
});

// Get top rated movies
router.get('/top-rated', async (req: AuthenticatedRequest, res: Response) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const movies = await tmdbService.getTopRatedMovies(page);
    res.json(movies);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch top rated movies' });
  }
});

// Get upcoming movies
router.get('/upcoming', async (req: AuthenticatedRequest, res: Response) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const movies = await tmdbService.getUpcomingMovies(page);
    res.json(movies);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch upcoming movies' });
  }
});

// Get now playing movies
router.get('/now-playing', async (req: AuthenticatedRequest, res: Response) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const movies = await tmdbService.getNowPlayingMovies(page);
    res.json(movies);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch now playing movies' });
  }
});

// Get movie details
router.get('/:id', async (req: AuthenticatedRequest, res: Response) => {
  try {
    const id = parseInt(req.params.id as string);
    if (isNaN(id)) {
      res.status(400).json({ error: 'Invalid movie ID' });
      return;
    }
    const movie = await tmdbService.getMovieDetails(id);
    res.json(movie);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch movie details' });
  }
});

export default router;
