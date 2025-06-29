"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.errorHandler = void 0;
const errorHandler = (err, req, res, next) => {
    console.error('Error:', err.message);
    console.error('Stack:', err.stack);
    let error = {
        message: err.message || 'Internal Server Error',
        status: 500,
    };
    if (err.name === 'ValidationError') {
        error.status = 400;
        error.message = 'Validation Error';
    }
    if (err.name === 'CastError') {
        error.status = 400;
        error.message = 'Resource not found';
    }
    res.status(error.status).json({
        success: false,
        error: error.message,
        ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
    });
};
exports.errorHandler = errorHandler;
//# sourceMappingURL=errorHandler.js.map