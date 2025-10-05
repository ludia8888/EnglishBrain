import { Router } from 'express';

import { firebaseAuth } from '../middleware/firebaseAuth';
import { getSamplePatternConquests } from '../services/patternService';
import {
  getUserProfile,
  updateUserProfile,
  buildHomeSummary,
  getWidgetSnapshot,
  applyTutorialCompletion,
} from '../services/userService';
import { ValidationError } from '../utils/errors';
import { validateTutorialCompletionPayload } from '../validation/tutorialCompletion';

const router = Router();

router.use(firebaseAuth);

router.get('/me', async (req, res) => {
  const uid = req.user?.uid;
  if (!uid) {
    res.status(401).json({ message: 'Unauthorized' });
    return;
  }
  const profile = await getUserProfile(uid);
  if (!profile) {
    res.status(404).json({ message: 'Profile not found' });
    return;
  }
  res.json(profile);
});

router.patch('/me', async (req, res) => {
  const uid = req.user?.uid;
  if (!uid) {
    res.status(401).json({ message: 'Unauthorized' });
    return;
  }
  const profile = await updateUserProfile(uid, req.body ?? {});
  res.json(profile);
});

router.get('/me/home', async (req, res) => {
  const uid = req.user?.uid;
  if (!uid) {
    res.status(401).json({ message: 'Unauthorized' });
    return;
  }
  const profile = await getUserProfile(uid);
  if (!profile) {
    res.status(404).json({ message: 'Profile not found' });
    return;
  }
  res.json(buildHomeSummary(profile));
});

router.get('/me/widget-snapshot', async (req, res) => {
  const uid = req.user?.uid;
  if (!uid) {
    res.status(401).json({ message: 'Unauthorized' });
    return;
  }
  const snapshot = await getWidgetSnapshot(uid);
  if (!snapshot) {
    res.status(404).json({ message: 'Snapshot unavailable' });
    return;
  }
  res.json(snapshot);
});

router.get('/me/pattern-conquests', async (req, res) => {
  const uid = req.user?.uid;
  if (!uid) {
    res.status(401).json({ message: 'Unauthorized' });
    return;
  }
  // TODO: replace with Firestore-driven aggregation.
  const patterns = getSamplePatternConquests();
  res.json({ patterns });
});

router.post('/me/tutorial-completions', async (req, res) => {
  const uid = req.user?.uid;
  if (!uid) {
    return res.status(401).json({ message: 'Unauthorized' });
  }
  try {
    const { tutorialId, completedAt } = validateTutorialCompletionPayload(req.body);
    const resp = await applyTutorialCompletion(uid, tutorialId, completedAt);
    return res.status(202).json(resp);
  } catch (error) {
    if (error instanceof ValidationError) {
      return res.status(error.statusCode).json({ message: error.message });
    }
    console.error('Tutorial completion failed', error);
    return res.status(500).json({ message: 'Failed to mark tutorial completion' });
  }
});

export default router;
