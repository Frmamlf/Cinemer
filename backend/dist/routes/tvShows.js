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
        const tvShows = await tmdbService_1.tmdbService.getPopularTVShows(page);
        res.json(tvShows);
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to fetch popular TV shows' });
    }
});
router.get('/top-rated', async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const tvShows = await tmdbService_1.tmdbService.getTopRatedTVShows(page);
        res.json(tvShows);
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to fetch top rated TV shows' });
    }
});
router.get('/on-the-air', async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const tvShows = await tmdbService_1.tmdbService.getOnTheAirTVShows(page);
        res.json(tvShows);
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to fetch on the air TV shows' });
    }
});
router.get('/airing-today', async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const tvShows = await tmdbService_1.tmdbService.getAiringTodayTVShows(page);
        res.json(tvShows);
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to fetch airing today TV shows' });
    }
});
router.get('/:id', async (req, res) => {
    try {
        const id = parseInt(req.params.id);
        if (isNaN(id)) {
            res.status(400).json({ error: 'Invalid TV show ID' });
            return;
        }
        const tvShow = await tmdbService_1.tmdbService.getTVShowDetails(id);
        res.json(tvShow);
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to fetch TV show details' });
    }
});
exports.default = router;
//# sourceMappingURL=tvShows.js.map