import { Router } from 'express';

import { firebaseAuth } from '../middleware/firebaseAuth';
import { submitLevelTest } from '../services/levelTestService';
import { LevelTestSubmissionPayload } from '../types/levelTest';
import { ValidationError } from '../utils/errors';
import { validateLevelTestPayload } from '../validation/levelTest';

const router = Router();

router.use(firebaseAuth);

router.post('/', async (req, res) => {
  const uid = req.user?.uid;
  if (!uid) {
    return res.status(401).json({ message: 'Unauthorized' });
  }

  try {
    const payload = req.body as LevelTestSubmissionPayload;
    validateLevelTestPayload(payload);
    const result = await submitLevelTest(uid, payload);
    return res.status(200).json(result);
  } catch (error) {
    if (error instanceof ValidationError) {
      return res.status(error.statusCode).json({ message: error.message });
    }
    console.error('Level test submission failed', error);
    return res.status(500).json({ message: 'Failed to submit level test' });
  }
});

export default router;
