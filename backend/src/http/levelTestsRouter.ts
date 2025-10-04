import { Router } from 'express';

import { firebaseAuth } from '../middleware/firebaseAuth';
import { submitLevelTest, validateLevelTestPayload } from '../services/levelTestService';
import { LevelTestSubmissionPayload } from '../types/levelTest';

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
    return res.status(400).json({ message: (error as Error).message });
  }
});

export default router;
