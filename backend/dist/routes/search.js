"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const tmdbService_1 = require("../services/tmdbService");
const auth_1 = require("../middleware/auth");
const router = (0, express_1.Router)();
router.use(auth_1.extractUserInfo);
router.get('/movies', async (req, res) => {
    try {
        const query = req.query.q;
        const page = parseInt(req.query.page) || 1;
        if (!query) {
            res.status(400).json({ error: 'Query parameter is required' });
            return;
        }
        const results = await tmdbService_1.tmdbService.searchMovies(query, page);
        res.json(results);
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to search movies' });
    }
});
router.get('/tv-shows', async (req, res) => {
    try {
        const query = req.query.q;
        const page = parseInt(req.query.page) || 1;
        if (!query) {
            res.status(400).json({ error: 'Query parameter is required' });
            return;
        }
        const results = await tmdbService_1.tmdbService.searchTVShows(query, page);
        res.json(results);
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to search TV shows' });
    }
});
router.get('/all', async (req, res) => {
    try {
        const query = req.query.q;
        const page = parseInt(req.query.page) || 1;
        if (!query) {
            res.status(400).json({ error: 'Query parameter is required' });
            return;
        }
        const results = await tmdbService_1.tmdbService.searchMulti(query, page);
        res.json(results);
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to search content' });
    }
});
exports.default = router;
//# sourceMappingURL=search.js.map