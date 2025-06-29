"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.requireAuth = exports.extractUserInfo = void 0;
const extractUserInfo = (req, res, next) => {
    const authHeader = req.headers.authorization;
    if (authHeader && authHeader.startsWith('Bearer ')) {
        req.userId = authHeader.replace('Bearer ', '');
    }
    next();
};
exports.extractUserInfo = extractUserInfo;
const requireAuth = (req, res, next) => {
    const authHeader = req.headers.authorization;
    if (!authHeader) {
        res.status(401).json({
            error: 'Authentication required'
        });
        return;
    }
    req.userId = authHeader.replace('Bearer ', '');
    next();
};
exports.requireAuth = requireAuth;
//# sourceMappingURL=auth.js.map