const { onDocumentCreated, onDocumentUpdated } = require('firebase-functions/v2/firestore');
const admin = require('firebase-admin');

/**
 * Helper to fetch a patient user's active FCM device token.
 */
async function getPatientFcmToken(patientId) {
  if (!patientId) return null;
  try {
    const userDoc = await admin.firestore().collection('users').doc(patientId).get();
    if (!userDoc.exists) return null;
    return userDoc.get('fcmToken') || null;
  } catch (err) {
    console.error(`Error looking up FCM token for patient ${patientId}:`, err);
    return null;
  }
}

/**
 * Helper to prune dead or expired FCM registration tokens.
 */
async function handleDeadToken(patientId, error) {
  if (
    error &&
    (error.code === 'messaging/registration-token-not-registered' ||
      error.code === 'messaging/invalid-registration-token')
  ) {
    console.log(`Pruning invalid FCM token for user ${patientId}`);
    try {
      await admin
        .firestore()
        .collection('users')
        .doc(patientId)
        .update({ fcmToken: admin.firestore.FieldValue.delete() });
    } catch (_) {}
  }
}

/**
 * 1. Live Queue Token Called Trigger
 * Dispatches an instant high-priority push notification when clinic admin calls next token.
 */
exports.onQueueTokenCalled = onDocumentUpdated('tickets/{ticketId}', async (event) => {
  const before = event.data?.before?.data();
  const after = event.data?.after?.data();
  if (!before || !after) return;

  // Trigger when status transitions to 'called'
  if (before.status !== 'called' && after.status === 'called') {
    const patientId = after.patientId || after.customerId || after.userId;
    const fcmToken = (await getPatientFcmToken(patientId)) || after.fcmToken;

    if (!fcmToken) {
      console.log(`No FCM token found for ticket ${event.params.ticketId} (patient: ${patientId})`);
      return;
    }

    const tokenNum = after.tokenNumber || after.token || '';
    const doctor = after.doctorName || after.doctor || 'Doctor';
    const clinic = after.clinicName || 'the clinic';

    const message = {
      token: fcmToken,
      notification: {
        title: `🔔 Token #${tokenNum} Called!`,
        body: `Please proceed to consultation room at ${clinic}. Dr. ${doctor} is ready to see you.`,
      },
      data: {
        route: `/live_queue?ticketId=${event.params.ticketId}`,
        type: 'queue_called',
        ticketId: String(event.params.ticketId),
      },
      android: {
        priority: 'high',
        notification: {
          sound: 'default',
          channelId: 'queueflow_high_importance_channel',
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
          },
        },
      },
    };

    try {
      const response = await admin.messaging().send(message);
      console.log(`Successfully sent queue token notification: ${response}`);
    } catch (err) {
      console.error(`Error sending queue notification to ${patientId}:`, err);
      await handleDeadToken(patientId, err);
    }
  }
});

/**
 * 2. Support Concern / Ticket Chat Reply Trigger
 * Sends a push notification to the patient when Clinic or Platform staff sends a reply.
 */
exports.onSupportTicketReply = onDocumentUpdated('support_tickets/{ticketId}', async (event) => {
  const before = event.data?.before?.data();
  const after = event.data?.after?.data();
  if (!before || !after) return;

  const oldMsgs = before.messages || [];
  const newMsgs = after.messages || [];

  if (newMsgs.length > oldMsgs.length) {
    const latestMsg = newMsgs[newMsgs.length - 1];
    const role = String(latestMsg.senderRole || latestMsg.senderType || '').toLowerCase();
    const isStaff = role === 'clinic' || role === 'platform_admin' || role === 'admin' || latestMsg.isAdmin === true;

    if (isStaff) {
      const patientId = after.patientId || after.userId || after.customerId;
      const fcmToken = await getPatientFcmToken(patientId);

      if (!fcmToken) {
        console.log(`No FCM token for patient ${patientId} on concern ticket ${event.params.ticketId}`);
        return;
      }

      const ticketNum = after.ticketNumber || event.params.ticketId;
      const senderName = latestMsg.sender || 'Care Desk';
      const text = latestMsg.text || latestMsg.message || 'Sent an update';

      const message = {
        token: fcmToken,
        notification: {
          title: `💬 New Reply: Ticket #${ticketNum}`,
          body: `${senderName}: ${text}`,
        },
        data: {
          route: `/support_chat?ticketId=${event.params.ticketId}`,
          type: 'support_reply',
          ticketId: String(event.params.ticketId),
        },
        android: {
          priority: 'high',
          notification: {
            sound: 'default',
            channelId: 'queueflow_high_importance_channel',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
      };

      try {
        const response = await admin.messaging().send(message);
        console.log(`Successfully sent support ticket notification: ${response}`);
      } catch (err) {
        console.error(`Error sending support notification to ${patientId}:`, err);
        await handleDeadToken(patientId, err);
      }
    }
  }
});

/**
 * 3. Appointment Status Changed Trigger (Confirmed / Cancelled)
 */
exports.onAppointmentStatusChanged = onDocumentUpdated('appointments/{appointmentId}', async (event) => {
  const before = event.data?.before?.data();
  const after = event.data?.after?.data();
  if (!before || !after) return;

  if (before.status !== after.status) {
    const patientId = after.patientId || after.userId || after.customerId;
    const fcmToken = await getPatientFcmToken(patientId);
    if (!fcmToken) return;

    let title = '';
    let body = '';
    const doctor = after.doctor || after.doctorName || 'Doctor';
    const date = after.date || after.appointmentDate || 'scheduled date';
    const time = after.time || after.appointmentTime || '';

    if (after.status === 'confirmed') {
      title = '✅ Appointment Confirmed!';
      body = `Your appointment with Dr. ${doctor} on ${date} ${time ? 'at ' + time : ''} is confirmed.`;
    } else if (after.status === 'cancelled') {
      title = '⚠️ Appointment Cancelled';
      body = `Your appointment with Dr. ${doctor} on ${date} was cancelled.`;
    } else {
      return;
    }

    const message = {
      token: fcmToken,
      notification: { title, body },
      data: {
        route: `/my_bookings?appointmentId=${event.params.appointmentId}`,
        type: 'appointment_update',
        appointmentId: String(event.params.appointmentId),
      },
      android: {
        priority: 'high',
        notification: {
          sound: 'default',
          channelId: 'queueflow_high_importance_channel',
        },
      },
      apns: {
        payload: {
          aps: { sound: 'default', badge: 1 },
        },
      },
    };

    try {
      await admin.messaging().send(message);
    } catch (err) {
      await handleDeadToken(patientId, err);
    }
  }
});

/**
 * 4. Platform Broadcast Announcement Trigger
 * Uses FCM topic messaging to reach all subscribed patient devices instantly.
 */
exports.onPlatformBroadcastCreated = onDocumentCreated('notifications/{notificationId}', async (event) => {
  const data = event.data?.data();
  if (!data) return;

  const title = data.title || 'QueueFlow Announcement';
  const body = data.message || data.body || '';
  if (!body) return;

  const message = {
    topic: 'broadcast_announcements',
    notification: {
      title: `📢 ${title}`,
      body,
    },
    data: {
      route: data.route || '/home',
      type: 'broadcast',
      notificationId: String(event.params.notificationId),
    },
    android: {
      notification: {
        sound: 'default',
        channelId: 'queueflow_high_importance_channel',
      },
    },
    apns: {
      payload: {
        aps: { sound: 'default' },
      },
    },
  };

  try {
    const response = await admin.messaging().send(message);
    console.log(`Broadcast announcement sent: ${response}`);
  } catch (err) {
    console.error('Error sending broadcast announcement:', err);
  }
});
