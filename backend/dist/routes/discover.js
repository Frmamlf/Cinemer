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
        const genre = req.query.genre;
        const year = req.query.year;
        const sortBy = req.query.sort_by || 'popularity.desc';
        const params = { page, sort_by: sortBy };
        if (genre)
            params.with_genres = genre;
        if (year)
            params.year = year;
        const results = await tmdbService_1.tmdbService.discoverMovies(params);
        res.json(results);
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to discover movies' });
    }
});
router.get('/tv-shows', async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const genre = req.query.genre;
        const year = req.query.year;
        const sortBy = req.query.sort_by || 'popularity.desc';
        const params = { page, sort_by: sortBy };
        if (genre)
            params.with_genres = genre;
        if (year)
            params.first_air_date_year = year;
        const results = await tmdbService_1.tmdbService.discoverTVShows(params);
        res.json(results);
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to discover TV shows' });
    }
});
exports.default = router;
//# sourceMappingURL=discover.js.map