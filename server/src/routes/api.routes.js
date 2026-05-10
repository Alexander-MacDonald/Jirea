import express from 'express';
import { getPrototypeRows } from '../db/pool.js';
import { requireAuth } from '../middleware/requireAuth.js';

export const apiRouter = express.Router();

apiRouter.get('/me', requireAuth, (req, res) => {
  res.json({
    user: req.session.user,
  });
});

apiRouter.get('/prototype-test', requireAuth, async (req, res, next) => {
  try {
    const rows = await getPrototypeRows();

    res.json({
      query: 'SELECT test FROM PROTOTYPE',
      rows,
    });
  } catch (error) {
    next(error);
  }
});