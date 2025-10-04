import { Router } from 'express';

import { getPatternDefinitions } from '../services/patternService';

const router = Router();

router.get('/', (_req, res) => {
  res.json({ patterns: getPatternDefinitions() });
});

export default router;
