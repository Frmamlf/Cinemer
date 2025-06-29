"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const tmdbService_1 = require("../services/tmdbService");
const auth_1 = require("../middleware/auth");
const router = (0, express_1.Router)();
router.use(auth_1.extractUserInfo);
router.get('/movies', async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const animeMovies = await tmdbService_1.tmdbService.getAnimeMovies(page);
        res.json(animeMovies);
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to fetch anime movies' });
    }
});
router.get('/tv-shows', async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const animeTVShows = await tmdbService_1.tmdbService.getAnimeTVShows(page);
        res.json(animeTVShows);
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to fetch anime TV shows' });
    }
});
router.get('/popular', async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const [animeMovies, animeTVShows] = await Promise.all([
            tmdbService_1.tmdbService.getAnimeMovies(page),
            tmdbService_1.tmdbService.getAnimeTVShows(page)
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
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to fetch popular anime' });
    }
});
exports.default = router;
//# sourceMappingURL=anime.js.map