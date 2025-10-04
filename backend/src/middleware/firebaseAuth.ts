import { Request, Response, NextFunction } from 'express';
import * as admin from 'firebase-admin';

import { getAuth } from '../firebaseAdmin';

declare module 'express-serve-static-core' {
  interface Request {
    user?: {
      uid: string;
      token: admin.auth.DecodedIdToken;
    };
  }
}

export async function firebaseAuth(req: Request, res: Response, next: NextFunction) {
  const header = req.headers.authorization;
  if (!header?.startsWith('Bearer ')) {
    res.status(401).json({ message: 'Missing or invalid authorization header' });
    return;
  }

  const token = header.split(' ')[1];
  try {
    const decoded = await getAuth().verifyIdToken(token);
    req.user = { uid: decoded.uid, token: decoded };
    next();
  } catch (error) {
    res.status(401).json({ message: 'Invalid Firebase ID token' });
    return;
  }
}
