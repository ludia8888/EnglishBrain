import type { UserRecord } from 'firebase-admin/auth';

import { ensureUserProfile } from '../services/userService';

export async function handleAuthUserCreate(user: UserRecord) {
  const localeClaim = typeof user.customClaims?.locale === 'string' ? user.customClaims.locale : undefined;
  const timezoneClaim = typeof user.customClaims?.timezone === 'string' ? user.customClaims.timezone : undefined;
  const provisionalLevelClaim = typeof user.customClaims?.provisionalLevel === 'number' ? user.customClaims.provisionalLevel : null;

  await ensureUserProfile({
    uid: user.uid,
    email: user.email,
    displayName: user.displayName,
    locale: localeClaim ?? undefined,
    timezone: timezoneClaim ?? undefined,
    provisionalLevel: provisionalLevelClaim,
    createdAt: user.metadata?.creationTime ?? null,
  });
}
