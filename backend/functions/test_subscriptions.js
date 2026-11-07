// Run: node test_subscriptions.js   (mocks Firebase + Razorpay; no network needed)
const Module = require('module');
const assert = require('assert');

// ---- in-memory Firestore mock ----
const store = {}; // path -> data
const mkTs = (d) => ({ toDate: () => d, _d: d });
const Timestamp = { fromDate: mkTs };
const SERVER = { __server: true };

function docRef(path) {
  return {
    path,
    id: path.split('/').pop(),
    get: async () => ({ exists: path in store, data: () => store[path], get: (k) => (store[path] || {})[k] }),
    collection: (name) => collection(path + '/' + name),
  };
}
function collection(path) {
  return {
    doc: (id) => docRef(path + '/' + id),
    where: (field, _op, val) => ({
      limit: () => ({
        get: async () => {
          const docs = Object.keys(store)
            .filter((k) => k.startsWith(path + '/') && k.split('/').length === path.split('/').length + 1 && store[k][field] === val)
            .map((k) => ({ ref: docRef(k), id: k.split('/').pop(), data: () => store[k] }));
          return { empty: docs.length === 0, docs };
        },
      }),
    }),
  };
}
const firestoreFn = () => ({
  collection,
  runTransaction: async (fn) => {
    const t = {
      get: async (ref) => ref.get(),
      set: (ref, data, opts) => {
        store[ref.path] = opts && opts.merge ? { ...(store[ref.path] || {}), ...data } : data;
      },
    };
    return fn(t);
  },
});
firestoreFn.Timestamp = Timestamp;
firestoreFn.FieldValue = { serverTimestamp: () => SERVER };

class HttpsError extends Error {
  constructor(code, message) { super(message); this.code = code; }
}
const mocks = {
  'firebase-functions/v2/https': { onCall: (_opts, fn) => fn, HttpsError },
  'firebase-functions/params': { defineSecret: () => ({ value: () => 'x' }) },
  'firebase-admin': { firestore: firestoreFn },
};
const orig = Module._load;
Module._load = function (request, ...rest) {
  return mocks[request] || orig.call(this, request, ...rest);
};

// ---- Razorpay mock via global fetch ----
let payments = {};
let calls = [];
global.fetch = async (url, opts) => {
  const path = url.replace('https://api.razorpay.com/v1', '');
  calls.push((opts.method || 'GET') + ' ' + path);
  const m = path.match(/^\/payments\/(pay_\w+)(\/capture|\/refund)?$/);
  const p = m && payments[m[1]];
  if (!p) return { ok: false, status: 400, json: async () => ({ error: { description: 'not found' } }) };
  if (m[2] === '/capture') p.status = 'captured';
  if (m[2] === '/refund') p.status = 'refunded';
  return { ok: true, status: 200, json: async () => p };
};

const { activateSubscription } = require('./subscriptions');
const req = (data, email = 'admin@clinic.com') => ({ auth: { token: { email } }, data });
const reset = (clinic) => {
  for (const k of Object.keys(store)) delete store[k];
  calls = [];
  store['clinics/c1'] = { name: 'Green Heaven', adminEmail: 'admin@clinic.com', ...clinic };
  store['clinics/c2'] = { name: 'Other', adminEmail: 'other@clinic.com' };
};
const rejects = async (p, code) => {
  try { await p; } catch (e) { assert.strictEqual(e.code, code, e.message); return e; }
  assert.fail('expected rejection ' + code);
};

(async () => {
  // 1. Successful monthly purchase activates for 30 days
  reset({});
  payments = { pay_OK000001: { amount: 299900, currency: 'INR', status: 'authorized', method: 'upi', notes: { clinicId: 'c1' } } };
  let r = await activateSubscription(req({ planId: 'multi', billingCadence: 'monthly', paymentId: 'pay_OK000001' }));
  assert.ok(r.activated && !r.duplicate);
  assert.ok(calls.includes('POST /payments/pay_OK000001/capture'), 'captures authorized payment');
  const c = store['clinics/c1'];
  assert.strictEqual(c.planId, 'multi');
  const days = Math.round((c.periodEndAt.toDate() - c.currentPeriodStart.toDate()) / 86400000);
  assert.strictEqual(days, 30);
  assert.ok(store['invoices/pay_OK000001'] && store['invoices/pay_OK000001'].status === 'completed');
  assert.ok(store['subscription_payments/pay_OK000001']);
  assert.ok(store['clinics/c1/subscription_history/pay_OK000001']);
  console.log('ok  activation + 30-day period + invoice/history/transaction');

  // 2. Same payment again is idempotent (no second activation / invoice)
  const before = JSON.stringify(store);
  r = await activateSubscription(req({ planId: 'multi', billingCadence: 'monthly', paymentId: 'pay_OK000001' }));
  assert.ok(r.duplicate);
  assert.strictEqual(JSON.stringify(store), before);
  console.log('ok  duplicate payment id does not re-activate');

  // 3. While locked, a new payment is rejected and refunded
  payments.pay_NEW00002 = { amount: 699900, currency: 'INR', status: 'captured', method: 'card', notes: { clinicId: 'c1' } };
  await rejects(activateSubscription(req({ planId: 'unlimited', billingCadence: 'monthly', paymentId: 'pay_NEW00002' })), 'failed-precondition');
  assert.strictEqual(store['clinics/c1'].planId, 'multi', 'plan unchanged');
  assert.ok(calls.includes('POST /payments/pay_NEW00002/refund'), 'refunded');
  assert.ok(!store['invoices/pay_NEW00002']);
  console.log('ok  locked plan rejects change + refunds');

  // 4. After expiry an upgrade works
  store['clinics/c1'].periodEndAt = mkTs(new Date(Date.now() - 1000));
  payments.pay_UPG00003 = { amount: 699900, currency: 'INR', status: 'captured', method: 'upi', notes: { clinicId: 'c1' } };
  await activateSubscription(req({ planId: 'unlimited', billingCadence: 'monthly', paymentId: 'pay_UPG00003' }));
  assert.strictEqual(store['clinics/c1'].planId, 'unlimited');
  assert.ok(store['clinics/c1'].periodEndAt.toDate() > new Date());
  console.log('ok  upgrade allowed after expiry, new period starts at payment');

  // 5. Failed / created payments never activate
  reset({});
  payments = { pay_FAIL0004: { amount: 99900, currency: 'INR', status: 'failed', notes: { clinicId: 'c1' } } };
  await rejects(activateSubscription(req({ planId: 'solo', billingCadence: 'monthly', paymentId: 'pay_FAIL0004' })), 'failed-precondition');
  assert.ok(!store['clinics/c1'].planId);
  console.log('ok  failed payment does not activate');

  // 6. Amount tampering (paid for solo, claims unlimited)
  payments = { pay_CHEAP005: { amount: 99900, currency: 'INR', status: 'captured', notes: { clinicId: 'c1' } } };
  await rejects(activateSubscription(req({ planId: 'unlimited', billingCadence: 'monthly', paymentId: 'pay_CHEAP005' })), 'failed-precondition');
  assert.ok(!store['clinics/c1'].planId);
  console.log('ok  amount mismatch rejected');

  // 7. Payment made for another clinic can't be claimed
  payments = { pay_OTHER006: { amount: 99900, currency: 'INR', status: 'captured', notes: { clinicId: 'c2' } } };
  await rejects(activateSubscription(req({ planId: 'solo', billingCadence: 'monthly', paymentId: 'pay_OTHER006' })), 'permission-denied');
  console.log('ok  other clinic payment rejected');

  // 8. Unauthenticated / bad input
  await rejects(activateSubscription({ auth: null, data: {} }), 'unauthenticated');
  await rejects(activateSubscription(req({ planId: 'solo', paymentId: 'nope' })), 'invalid-argument');
  await rejects(activateSubscription(req({ planId: 'gold', paymentId: 'pay_X0000007' })), 'invalid-argument');
  console.log('ok  auth + input validation');

  // 9. Annual = 12 x annual price, 365 days
  reset({});
  payments = { pay_ANN00008: { amount: 2399 * 12 * 100, currency: 'INR', status: 'captured', method: 'card', notes: { clinicId: 'c1' } } };
  await activateSubscription(req({ planId: 'multi', billingCadence: 'annual', paymentId: 'pay_ANN00008' }));
  const a = store['clinics/c1'];
  assert.strictEqual(Math.round((a.periodEndAt.toDate() - a.currentPeriodStart.toDate()) / 86400000), 365);
  console.log('ok  annual plan');

  console.log('\nALL BACKEND TESTS PASSED');
})().catch((e) => { console.error('FAIL', e); process.exit(1); });
