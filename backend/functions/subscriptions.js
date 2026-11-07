// Clinic subscription activation.
//
// A subscription is activated ONLY here, after the Razorpay payment has been
// verified server-side. Firestore rules stop clients from writing subscription
// fields directly, so the lock below cannot be bypassed from the app or the API.

const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { defineSecret } = require('firebase-functions/params');
const admin = require('firebase-admin');

const RAZORPAY_KEY_ID = defineSecret('RAZORPAY_KEY_ID');
const RAZORPAY_KEY_SECRET = defineSecret('RAZORPAY_KEY_SECRET');

const DAY_MS = 24 * 60 * 60 * 1000;
const PERIOD_DAYS = { monthly: 30, annual: 365 };

// Fallback catalogue; plan_tiers/{id} (edited by the platform owner) overrides prices.
const DEFAULT_PLANS = {
  solo: { name: 'Solo Doctor Plan', monthlyPrice: 999, annualPrice: 799 },
  multi: { name: 'Multi-Doctor Clinic Plan', monthlyPrice: 2999, annualPrice: 2399 },
  unlimited: { name: 'Unlimited Doctors Plan', monthlyPrice: 6999, annualPrice: 5599 },
};

async function loadPlan(planId) {
  const base = DEFAULT_PLANS[planId];
  if (!base) throw new HttpsError('invalid-argument', 'Unknown plan.');
  const snap = await admin.firestore().collection('plan_tiers').doc(planId).get();
  const d = snap.exists ? snap.data() : {};
  return {
    id: planId,
    name: d.name || base.name,
    monthlyPrice: Number(d.monthlyPrice) || base.monthlyPrice,
    annualPrice: Number(d.annualPrice) || base.annualPrice,
  };
}

async function razorpay(method, path, body) {
  const token = Buffer.from(RAZORPAY_KEY_ID.value() + ':' + RAZORPAY_KEY_SECRET.value()).toString('base64');
  const res = await fetch('https://api.razorpay.com/v1' + path, {
    method,
    headers: { Authorization: 'Basic ' + token, 'Content-Type': 'application/json' },
    body: body ? JSON.stringify(body) : undefined,
  });
  const json = await res.json().catch(() => ({}));
  if (!res.ok) {
    const msg = (json.error && json.error.description) || 'Razorpay error ' + res.status;
    throw new HttpsError('failed-precondition', msg);
  }
  return json;
}

async function refundQuietly(paymentId, amountPaise) {
  try {
    await razorpay('POST', '/payments/' + paymentId + '/refund', { amount: amountPaise });
  } catch (e) {
    console.error('Refund failed for', paymentId, e.message);
  }
}

const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
function fmtDate(d) {
  return d.getUTCDate() + ' ' + MONTHS[d.getUTCMonth()] + ' ' + d.getUTCFullYear();
}

/**
 * Verifies a Razorpay payment and activates the clinic's subscription.
 * data: { planId, billingCadence, paymentId }
 */
exports.activateSubscription = onCall(
  { secrets: [RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET] },
  async (request) => {
    const email = request.auth && request.auth.token && request.auth.token.email;
    if (!email) throw new HttpsError('unauthenticated', 'Sign in first.');

    const data = request.data || {};
    const planId = String(data.planId || '');
    const cadence = data.billingCadence === 'annual' ? 'annual' : 'monthly';
    const paymentId = String(data.paymentId || '').trim();
    if (!paymentId.startsWith('pay_')) {
      throw new HttpsError('invalid-argument', 'A valid paymentId is required.');
    }

    const db = admin.firestore();

    // The caller's own clinic (same lookup the app uses).
    const clinicSnap = await db.collection('clinics')
      .where('adminEmail', '==', String(email).trim().toLowerCase()).limit(1).get();
    if (clinicSnap.empty) throw new HttpsError('permission-denied', 'No clinic is linked to this account.');
    const clinicRef = clinicSnap.docs[0].ref;
    const clinicId = clinicRef.id;
    const cur = clinicSnap.docs[0].data();

    const plan = await loadPlan(planId);
    const price = cadence === 'annual' ? plan.annualPrice * 12 : plan.monthlyPrice;
    const amountPaise = price * 100;

    const txRef = db.collection('subscription_payments').doc(paymentId);

    // Idempotency: this payment was already processed.
    const existing = await txRef.get();
    if (existing.exists) {
      if (existing.get('clinicId') !== clinicId) {
        throw new HttpsError('permission-denied', 'This payment belongs to another clinic.');
      }
      return { activated: true, duplicate: true, receiptNo: existing.get('receiptNo') };
    }

    // 1. Verify the payment with Razorpay (never trust the client).
    let payment = await razorpay('GET', '/payments/' + paymentId);
    if (payment.amount !== amountPaise || payment.currency !== 'INR') {
      throw new HttpsError('failed-precondition', 'Payment amount does not match the plan price.');
    }
    if (payment.notes && payment.notes.clinicId && payment.notes.clinicId !== clinicId) {
      throw new HttpsError('permission-denied', 'This payment belongs to another clinic.');
    }
    if (payment.status !== 'captured' && payment.status !== 'authorized') {
      throw new HttpsError('failed-precondition', 'Payment is ' + payment.status + '; subscription not activated.');
    }

    // 2. Plan-change lock on the SERVER clock, checked before any money is captured.
    const now = new Date();
    const curEnd = cur.periodEndAt && cur.periodEndAt.toDate ? cur.periodEndAt.toDate() : null;
    if (curEnd && now < curEnd) {
      if (payment.status === 'captured') await refundQuietly(paymentId, amountPaise);
      throw new HttpsError(
        'failed-precondition',
        'Your current plan is active until ' + fmtDate(curEnd) +
          '. Plans can be changed after that date. Any payment made has been refunded.',
      );
    }

    // 3. Capture if the payment is only authorized.
    if (payment.status === 'authorized') {
      payment = await razorpay('POST', '/payments/' + paymentId + '/capture', { amount: amountPaise, currency: 'INR' });
      if (payment.status !== 'captured') {
        throw new HttpsError('failed-precondition', 'Payment could not be captured.');
      }
    }

    // 4. Activate atomically; the transaction doc id makes this idempotent.
    const start = now;
    const end = new Date(start.getTime() + PERIOD_DAYS[cadence] * DAY_MS);
    const ym = now.getUTCFullYear() + String(now.getUTCMonth() + 1).padStart(2, '0');
    const receiptNo = 'QF-RCPT-' + ym + '-' + paymentId.slice(-8).toUpperCase();
    const methodLabel = payment.method ? String(payment.method).toUpperCase() : 'RAZORPAY';
    const clinicName = cur.name || '';
    const customerName = (cur.billingContact && cur.billingContact.legalName) || clinicName;
    const TS = admin.firestore.Timestamp;
    const SERVER = admin.firestore.FieldValue.serverTimestamp();

    await db.runTransaction(async (t) => {
      const again = await t.get(txRef);
      if (again.exists) return; // concurrent duplicate

      t.set(txRef, {
        paymentId, clinicId, planId, planName: plan.name, billingCycle: cadence,
        amountPaise, status: 'paid', razorpayStatus: payment.status, method: methodLabel,
        receiptNo, createdAt: SERVER,
      });
      t.set(clinicRef, {
        planId, planName: plan.name, billingCadence: cadence, amount: '₹' + price,
        status: 'ACTIVE',
        currentPeriodStart: TS.fromDate(start),
        periodEndAt: TS.fromDate(end),
        currentPeriodEnd: fmtDate(end),
        lastPaymentId: paymentId,
        updatedAt: SERVER,
      }, { merge: true });
      t.set(clinicRef.collection('subscription_history').doc(paymentId), {
        paymentId, planId, planName: plan.name, billingCycle: cadence, amount: price,
        startAt: TS.fromDate(start), endAt: TS.fromDate(end),
        previousPlanId: cur.planId || '',
        createdAt: SERVER,
      });
      t.set(db.collection('invoices').doc(paymentId), {
        number: receiptNo, clinicId, clinic: clinicName,
        customerName, customerEmail: String(email),
        plan: plan.name, amount: '₹' + price, subtotal: price, tax: 0,
        due: fmtDate(now), date: fmtDate(now),
        status: 'completed', method: methodLabel, paymentId, billingCycle: cadence,
        paidAt: TS.fromDate(now), startAt: TS.fromDate(start), endAt: TS.fromDate(end),
        createdAt: SERVER,
      });
    });

    return { activated: true, duplicate: false, receiptNo, expiresAt: end.toISOString() };
  },
);
