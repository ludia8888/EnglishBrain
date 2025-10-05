import { getFirestore } from '../firebaseAdmin';
import { generateId } from '../utils/id';

export type AnalyticsEventPayload = Record<string, unknown>;

const ANALYTICS_EVENTS_COLLECTION = 'analytics_events';

export interface AnalyticsEventRecord {
  eventId: string;
  uid: string;
  eventType: string;
  createdAt: string;
  payload: AnalyticsEventPayload;
}

export async function recordAnalyticsEvent(
  uid: string,
  eventType: string,
  payload: AnalyticsEventPayload = {}
): Promise<void> {
  const firestore = getFirestore();
  const eventId = generateId('evt');
  const createdAt = new Date().toISOString();

  const record: AnalyticsEventRecord = {
    eventId,
    uid,
    eventType,
    createdAt,
    payload,
  };

  await firestore.collection(ANALYTICS_EVENTS_COLLECTION).doc(eventId).set(record);
}
