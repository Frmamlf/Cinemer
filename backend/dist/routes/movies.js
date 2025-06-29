"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const tmdbService_1 = require("../services/tmdbService");
const auth_1 = require("../middleware/auth");
const router = (0, express_1.Router)();
router.use(auth_1.extractUserInfo);
router.get('/popular', async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const movies = await tmdbService_1.tmdbService.getPopularMovies(page);
        res.json(movies);
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to fetch popular movies' });
    }
});
router.get('/top-rated', async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const movies = await tmdbService_1.tmdbService.getTopRatedMovies(page);
        res.json(movies);
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to fetch top rated movies' });
    }
});
router.get('/upcoming', async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const movies = await tmdbService_1.tmdbService.getUpcomingMovies(page);
        res.json(movies);
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to fetch upcoming movies' });
    }
});
router.get('/now-playing', async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const movies = await tmdbService_1.tmdbService.getNowPlayingMovies(page);
        res.json(movies);
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to fetch now playing movies' });
    }
});
router.get('/:id', async (req, res) => {
    try {
        const id = parseInt(req.params.id);
        if (isNaN(id)) {
            res.status(400).json({ error: 'Invalid movie ID' });
            return;
        }
        const movie = await tmdbService_1.tmdbService.getMovieDetails(id);
        res.json(movie);
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to fetch movie details' });
    }
});
exports.default = router;
//# sourceMappingURL=movies.js.map