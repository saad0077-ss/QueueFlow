const { onCall, HttpsError } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');

admin.initializeApp();

/**
 * Deletes a clinic admin's Firebase Authentication account.
 * Auth users can only be deleted with the Admin SDK, so the platform owner app
 * calls this when it permanently deletes a clinic.
 *
 * Only a signed-in platform owner (users/{uid}.role == 'platform_owner') may call it.
 */
exports.deleteClinicAdminAccount = onCall(async (request) => {
  const uid = request.auth && request.auth.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'Sign in first.');

  const caller = await admin.firestore().collection('users').doc(uid).get();
  if (!caller.exists || caller.get('role') !== 'platform_owner') {
    throw new HttpsError('permission-denied', 'Only the platform owner can delete clinic accounts.');
  }

  const email = String((request.data && request.data.email) || '').trim().toLowerCase();
  if (!email) throw new HttpsError('invalid-argument', 'email is required.');

  try {
    const user = await admin.auth().getUserByEmail(email);
    // Never let this remove a platform owner account.
    const profile = await admin.firestore().collection('users').doc(user.uid).get();
    if (profile.exists && profile.get('role') === 'platform_owner') {
      throw new HttpsError('failed-precondition', 'Refusing to delete a platform owner account.');
    }
    await admin.auth().deleteUser(user.uid);
    return { deleted: true };
  } catch (e) {
    if (e instanceof HttpsError) throw e;
    if (e.code === 'auth/user-not-found') return { deleted: false, reason: 'no-auth-user' };
    throw new HttpsError('internal', e.message || 'Failed to delete the auth user.');
  }
});

exports.activateSubscription = require('./subscriptions').activateSubscription;
