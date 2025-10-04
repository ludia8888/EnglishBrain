import type { Request, Response, NextFunction } from 'express';

import { firebaseAuth } from '../src/middleware/firebaseAuth';
import { getAuth } from '../src/firebaseAdmin';

jest.mock('../src/firebaseAdmin', () => ({
  getAuth: jest.fn(),
}));

describe('firebaseAuth middleware', () => {
  const mockVerifyIdToken = jest.fn();
  const mockGetAuth = getAuth as jest.Mock;

  const createResponse = () => {
    const res: Partial<Response> = {};
    const status = jest.fn().mockImplementation(() => res as Response);
    const json = jest.fn();
    res.status = status as unknown as Response['status'];
    res.json = json as unknown as Response['json'];
    return { res: res as Response, status, json };
  };

  beforeEach(() => {
    jest.clearAllMocks();
    mockGetAuth.mockReturnValue({
      verifyIdToken: mockVerifyIdToken,
    });
  });

  it('rejects requests without an Authorization header', async () => {
    const req = { headers: {} } as Request;
    const { res, status, json } = createResponse();
    const next = jest.fn();

    await firebaseAuth(req, res, next as unknown as NextFunction);

    expect(status).toHaveBeenCalledWith(401);
    expect(json).toHaveBeenCalledWith({ message: 'Missing or invalid authorization header' });
    expect(next).not.toHaveBeenCalled();
  });

  it('rejects requests with invalid tokens', async () => {
    const req = {
      headers: {
        authorization: 'Bearer invalid',
      },
    } as unknown as Request;

    const { res, status, json } = createResponse();
    const next = jest.fn();

    mockVerifyIdToken.mockRejectedValue(new Error('bad token'));

    await firebaseAuth(req, res, next as unknown as NextFunction);

    expect(mockVerifyIdToken).toHaveBeenCalledWith('invalid');
    expect(status).toHaveBeenCalledWith(401);
    expect(json).toHaveBeenCalledWith({ message: 'Invalid Firebase ID token' });
    expect(next).not.toHaveBeenCalled();
  });

  it('accepts requests with valid tokens and attaches the user', async () => {
    const decoded = { uid: 'user-123', email: 'test@example.com' };
    mockVerifyIdToken.mockResolvedValue(decoded);

    const req = {
      headers: {
        authorization: 'Bearer good-token',
      },
    } as unknown as Request;
    const { res, status } = createResponse();
    const next = jest.fn();

    await firebaseAuth(req, res, next as unknown as NextFunction);

    expect(mockVerifyIdToken).toHaveBeenCalledWith('good-token');
    expect((req as Request).user).toEqual({ uid: decoded.uid, token: decoded });
    expect(status).not.toHaveBeenCalled();
    expect(next).toHaveBeenCalledTimes(1);
  });
});
