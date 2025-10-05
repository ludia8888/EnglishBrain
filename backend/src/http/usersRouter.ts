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
  const { tutorialId, completedAt } = req.body ?? {};
  if (typeof tutorialId !== 'string' || tutorialId.trim().length === 0) {
    return res.status(400).json({ message: 'tutorialId is required' });
  }
  if (typeof completedAt !== 'string' || Number.isNaN(Date.parse(completedAt))) {
    return res.status(400).json({ message: 'completedAt must be an ISO date-time string' });
  }
  try {
    const resp = await applyTutorialCompletion(uid, tutorialId, completedAt);
    return res.status(202).json(resp);
  } catch (e) {
    return res.status(500).json({ message: (e as Error).message });
  }
});

export default router;
