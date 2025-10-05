import cors from 'cors';
import express from 'express';

import levelTestsRouter from './levelTestsRouter';
import patternsRouter from './patternsRouter';
import sessionsRouter from './sessionsRouter';
import usersRouter from './usersRouter';

const app = express();

app.use(cors({ origin: true }));
app.use(express.json());

app.get('/health', (_req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.use('/patterns', patternsRouter);
app.use('/users', usersRouter);
app.use('/sessions', sessionsRouter);
app.use('/level-tests', levelTestsRouter);

export default app;
