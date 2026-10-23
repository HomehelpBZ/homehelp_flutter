// Checks firestore.rules against the writes the app makes for housekeeper
// verification (approve, reject, fix and re-submit), using the Firestore
// emulator. Each write mirrors the app's code (AdminService / UserService),
// so update both together.
//
// Run (needs Java and the Firebase CLI):
//   cd test/rules && npm install && npm test
import fs from 'node:fs';
import {
  initializeTestEnvironment, assertSucceeds, assertFails,
} from '@firebase/rules-unit-testing';
import {
  doc, getDoc, getDocs, setDoc, writeBatch, collection, query, where,
  serverTimestamp, deleteField,
} from 'firebase/firestore';

const RULES = new URL('../../firestore.rules', import.meta.url);
const HK = 'hkUid1', ADMIN = 'adminUid1', OTHER = 'otherUid1';

const env = await initializeTestEnvironment({
  projectId: 'demo-homehelp',
  firestore: { rules: fs.readFileSync(RULES, 'utf8'), host: '127.0.0.1', port: 8085 },
});

let pass = 0, fail = 0;
async function check(name, fn) {
  try { await fn(); pass++; console.log('PASS  ' + name); }
  catch (e) { fail++; console.log('FAIL  ' + name + '\n      ' + (e.message || e).split('\n')[0]); }
}

// State right after a housekeeper submitted their guarantor ID.
async function seed({ guarantor = true } = {}) {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (c) => {
    const db = c.firestore();
    await setDoc(doc(db, 'admins', ADMIN), { role: 'admin' });
    await setDoc(doc(db, 'users', HK), { uid: HK, roles: ['housekeeper'], verified: false, adminLevel: null });
    await setDoc(doc(db, 'housekeeperProfiles', HK), {
      userId: HK, fullName: 'Test HK', ratingAverage: 0, ratingCount: 0,
      isVerified: false, verificationStatus: 'pending_review', guarantorIdSubmitted: true,
    });
    if (guarantor) {
      await setDoc(doc(db, 'users', HK, 'guarantors', 'guarantor1'), {
        fullName: 'G', phone: '0911', relationship: 'Sister',
        verificationStatus: 'pending', verifiedBy: null, verifiedAt: null, idType: 'fayda',
      });
    }
    await setDoc(doc(db, 'verificationQueue', HK), {
      queueId: HK, housekeeperId: HK, status: 'pending', reviewedAt: null, reviewedBy: null,
    });
  });
}

const as = (uid) => env.authenticatedContext(uid).firestore();

// AdminService.rejectHk (profile exists)
function rejectBatch(db) {
  const b = writeBatch(db);
  b.update(doc(db, 'verificationQueue', HK), {
    status: 'rejected', reviewedAt: serverTimestamp(), reviewedBy: ADMIN,
    rejectionReason: 'Incomplete profile information', rejectionNote: 'Please add your work history',
  });
  b.update(doc(db, 'housekeeperProfiles', HK), {
    verificationStatus: 'rejected', isVerified: false, rejectedAt: serverTimestamp(),
    rejectedBy: ADMIN, rejectionReason: 'Incomplete profile information',
  });
  b.set(doc(collection(db, 'adminActions')), {
    adminId: ADMIN, targetUserId: HK, actionType: 'reject_housekeeper',
    reason: 'Incomplete profile information', note: 'Please add your work history', createdAt: serverTimestamp(),
  });
  return b.commit();
}

// AdminService.approveHk (with or without a guarantor doc)
function approveBatch(db, { guarantor = true } = {}) {
  const b = writeBatch(db);
  b.update(doc(db, 'verificationQueue', HK), { status: 'approved', reviewedAt: serverTimestamp(), reviewedBy: ADMIN });
  b.update(doc(db, 'housekeeperProfiles', HK), {
    verificationStatus: 'approved', isVerified: true, approvedAt: serverTimestamp(), approvedBy: ADMIN,
  });
  b.update(doc(db, 'users', HK), { verified: true, updatedAt: serverTimestamp() });
  if (guarantor) {
    b.update(doc(db, 'users', HK, 'guarantors', 'guarantor1'), {
      verificationStatus: 'verified', verifiedBy: ADMIN, verifiedAt: serverTimestamp(),
    });
  }
  b.set(doc(collection(db, 'adminActions')), {
    adminId: ADMIN, targetUserId: HK, actionType: 'approve_housekeeper', reason: null, createdAt: serverTimestamp(),
  });
  return b.commit();
}

const clearedReview = () => ({
  reviewedBy: null, reviewedAt: null, rejectionReason: deleteField(), rejectionNote: deleteField(),
});

// UserService.resubmitForReview
function resubmitBatch(db, queueFields = clearedReview()) {
  const b = writeBatch(db);
  b.update(doc(db, 'housekeeperProfiles', HK), {
    verificationStatus: 'pending_review', resubmittedAt: serverTimestamp(), updatedAt: serverTimestamp(),
  });
  b.set(doc(db, 'verificationQueue', HK), { status: 'pending', submittedAt: serverTimestamp(), ...queueFields }, { merge: true });
  return b.commit();
}

// UserService.saveGuarantorId
function guarantorIdBatch(db) {
  const b = writeBatch(db);
  b.update(doc(db, 'users', HK, 'guarantors', 'guarantor1'), {
    idType: 'fayda', faydaId: '1234', idSubmittedAt: serverTimestamp(),
  });
  b.update(doc(db, 'housekeeperProfiles', HK), {
    verificationStatus: 'pending_review', guarantorIdSubmitted: true, updatedAt: serverTimestamp(),
  });
  b.update(doc(db, 'verificationQueue', HK), {
    status: 'pending', guarantorIdSubmittedAt: serverTimestamp(), ...clearedReview(),
  });
  return b.commit();
}

// withSecurityRulesDisabled doesn't pass the callback's result back.
async function read(path) {
  let data;
  await env.withSecurityRulesDisabled(async (c) => {
    data = (await getDoc(doc(c.firestore(), ...path))).data();
  });
  return data;
}

console.log('\n── Full flow: reject → fix → resubmit → approve');
await seed();
await check('admin rejects', () => assertSucceeds(rejectBatch(as(ADMIN))));
await check('housekeeper reads the rejection note on their queue entry', async () => {
  const d = (await assertSucceeds(getDoc(doc(as(HK), 'verificationQueue', HK)))).data();
  if (d.rejectionNote !== 'Please add your work history') throw new Error('note missing: ' + JSON.stringify(d));
});
await check('housekeeper edits profile while rejected', () =>
  assertSucceeds(setDoc(doc(as(HK), 'housekeeperProfiles', HK), { bio: 'Fixed', updatedAt: serverTimestamp() }, { merge: true })));
await check('housekeeper resubmits', () => assertSucceeds(resubmitBatch(as(HK))));
await check('after resubmit: queue is pending, review + reason/note cleared', async () => {
  const q = await read(['verificationQueue', HK]);
  if (q.status !== 'pending' || q.reviewedBy !== null || q.reviewedAt !== null || 'rejectionReason' in q || 'rejectionNote' in q)
    throw new Error(JSON.stringify(q));
  const p = await read(['housekeeperProfiles', HK]);
  if (p.verificationStatus !== 'pending_review') throw new Error('profile ' + p.verificationStatus);
});
await check("resubmitted housekeeper shows in the admin's pending queue", async () => {
  const snap = await assertSucceeds(getDocs(query(collection(as(ADMIN), 'verificationQueue'), where('status', '==', 'pending'))));
  if (!snap.docs.some((d) => d.id === HK)) throw new Error('not in queue');
});
await check('admin approves (incl. guarantor)', () => assertSucceeds(approveBatch(as(ADMIN))));
await check('after approve: guarantor verified, profile approved', async () => {
  const g = await read(['users', HK, 'guarantors', 'guarantor1']);
  if (g.verificationStatus !== 'verified' || g.verifiedBy !== ADMIN || !g.verifiedAt) throw new Error(JSON.stringify(g));
  const p = await read(['housekeeperProfiles', HK]);
  if (p.verificationStatus !== 'approved' || p.isVerified !== true) throw new Error(JSON.stringify(p));
});
await check('housekeeper can read their verified guarantor', () =>
  assertSucceeds(getDoc(doc(as(HK), 'users', HK, 'guarantors', 'guarantor1'))));

console.log('\n── Other paths');
await seed({ guarantor: false });
await check('admin approves a housekeeper with no guarantor doc', () => assertSucceeds(approveBatch(as(ADMIN), { guarantor: false })));

await seed();
await rejectBatch(as(ADMIN));
await check('guarantor ID re-submitted after a rejection', () => assertSucceeds(guarantorIdBatch(as(HK))));

console.log('\n── Things that must be refused');
await seed();
await rejectBatch(as(ADMIN));
await check('resubmit WITHOUT clearing the old review is refused (why the fix was needed)', () =>
  assertFails(resubmitBatch(as(HK), {})));
await check('housekeeper cannot approve themselves', () =>
  assertFails(setDoc(doc(as(HK), 'housekeeperProfiles', HK), { verificationStatus: 'approved' }, { merge: true })));
await check('housekeeper cannot mark their own guarantor verified', () =>
  assertFails(setDoc(doc(as(HK), 'users', HK, 'guarantors', 'guarantor1'),
    { verificationStatus: 'verified', verifiedBy: HK, verifiedAt: serverTimestamp() }, { merge: true })));
await check("housekeeper cannot clear the admin's rejection fields on the profile", () =>
  assertFails(setDoc(doc(as(HK), 'housekeeperProfiles', HK), { rejectionReason: deleteField() }, { merge: true })));
await check("another user cannot read the housekeeper's rejection note", () =>
  assertFails(getDoc(doc(as(OTHER), 'verificationQueue', HK))));
await check('a non-admin cannot approve', () => assertFails(approveBatch(as(OTHER))));

console.log(`\n${pass} passed, ${fail} failed`);
await env.cleanup();
process.exit(fail ? 1 : 0);
