import { Router } from 'express';

import { firebaseAuth } from '../middleware/firebaseAuth';
import {
  createSession,
  getSession,
  listSessions,
  listAttempts,
  logAttempt,
  logCheckpoint,
  updateSession,
} from '../services/sessionService';
import {
  AttemptSubmissionPayload,
  CheckpointSubmissionPayload,
  SessionCreatePayload,
  SessionUpdatePayload,
} from '../types/session';

const router = Router();

router.use(firebaseAuth);

router.post('/', async (req, res) => {
  const uid = req.user?.uid;
  if (!uid) {
    res.status(401).json({ message: 'Unauthorized' });
    return;
  }
  try {
    const payload: SessionCreatePayload = req.body;
    const session = await createSession(uid, payload);
    res.status(201).json(session);
  } catch (error) {
    res.status(500).json({ message: (error as Error).message });
  }
});

router.get('/', async (req, res) => {
  const uid = req.user?.uid;
  if (!uid) {
    res.status(401).json({ message: 'Unauthorized' });
    return;
  }
  const limit = req.query.limit ? Number(req.query.limit) : 20;
  const sessions = await listSessions(uid, limit);
  res.json({ sessions, nextCursor: null });
});

router.get('/:sessionId', async (req, res) => {
  const uid = req.user?.uid;
  if (!uid) {
    res.status(401).json({ message: 'Unauthorized' });
    return;
  }
  const session = await getSession(uid, req.params.sessionId);
  if (!session) {
    res.status(404).json({ message: 'Session not found' });
    return;
  }
  res.json(session);
});

router.patch('/:sessionId', async (req, res) => {
  const uid = req.user?.uid;
  if (!uid) {
    res.status(401).json({ message: 'Unauthorized' });
    return;
  }
  try {
    const payload: SessionUpdatePayload = req.body;
    const updated = await updateSession(uid, req.params.sessionId, payload);
    res.json(updated);
  } catch (error) {
    res.status(404).json({ message: (error as Error).message });
  }
});

router.post('/:sessionId/checkpoints', async (req, res) => {
  const uid = req.user?.uid;
  if (!uid) {
    res.status(401).json({ message: 'Unauthorized' });
    return;
  }
  try {
    const payload: CheckpointSubmissionPayload = req.body;
    const checkpoint = await logCheckpoint(uid, req.params.sessionId, payload);
    res.status(201).json(checkpoint);
  } catch (error) {
    res.status(404).json({ message: (error as Error).message });
  }
});

router.post('/:sessionId/attempts', async (req, res) => {
  const uid = req.user?.uid;
  if (!uid) {
    res.status(401).json({ message: 'Unauthorized' });
    return;
  }
  try {
    const payload: AttemptSubmissionPayload = req.body;
    const attempt = await logAttempt(uid, req.params.sessionId, payload);
    res.status(201).json(attempt);
  } catch (error) {
    res.status(404).json({ message: (error as Error).message });
  }
});

router.get('/:sessionId/attempts', async (req, res) => {
  const uid = req.user?.uid;
  if (!uid) {
    res.status(401).json({ message: 'Unauthorized' });
    return;
  }
  try {
    const attempts = await listAttempts(uid, req.params.sessionId, req.query.verdict as string | undefined);
    res.json({ attempts });
  } catch (error) {
    res.status(404).json({ message: (error as Error).message });
  }
});

export default router;
