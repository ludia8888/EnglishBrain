import * as admin from 'firebase-admin';

export function getAdminApp(): admin.app.App {
  if (!admin.apps.length) {
    return admin.initializeApp();
  }
  return admin.app();
}

export function getFirestore(): admin.firestore.Firestore {
  return getAdminApp().firestore();
}

export function getAuth(): admin.auth.Auth {
  return getAdminApp().auth();
}
