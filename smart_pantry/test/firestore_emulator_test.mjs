import assert from 'node:assert/strict';

const project = 'demo-smart-pantry';
const auth = 'http://127.0.0.1:19099/identitytoolkit.googleapis.com/v1';
const firestore = 'http://127.0.0.1:18080/v1/projects/' + project +
  '/databases/(default)/documents';
const password = 'Phase04LocalOnly!123';
const nonce = Date.now().toString(36);

async function authRequest(action, payload, expected = 200) {
  const response = await fetch(auth + '/accounts:' + action + '?key=demo-api-key', {
    method: 'POST',
    redirect: 'error',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ ...payload, returnSecureToken: true }),
  });
  const data = await response.json();
  assert.equal(response.status, expected, action + ': ' + (data.error?.message ?? ''));
  return data;
}

const email = 'owner-' + nonce + '@example.test';
const owner = await authRequest('signUp', { email, password });
const outsider = await authRequest('signUp', {
  email: 'outsider-' + nonce + '@example.test',
  password,
});
const signIn = await authRequest('signInWithPassword', { email, password });
assert.equal(signIn.localId, owner.localId);
await authRequest('signInWithPassword', { email, password: 'Wrong password' }, 400);
await authRequest('signUp', { email, password }, 400);
console.log('Auth emulator: two distinct registrations, sign-in, wrong password and duplicate signup passed.');

const fields = { phase04: { booleanValue: true } };
let checks = 0;
async function expectStatus(op, path, session, expected, exists) {
  const url = new URL(firestore + '/' + path);
  if (exists !== undefined) url.searchParams.set('currentDocument.exists', exists);
  const headers = session ? { Authorization: 'Bearer ' + session.idToken } : {};
  const options = { method: op, headers, redirect: 'error' };
  if (op === 'PATCH') {
    headers['Content-Type'] = 'application/json';
    options.body = JSON.stringify({ fields });
  }
  const response = await fetch(url, options);
  assert.equal(response.status, expected,
    [op, path, session?.localId ?? 'anonymous', await response.text()].join(' '));
  checks++;
}

const base = 'users/' + owner.localId;
const paths = [base, base + '/settings/notifications'];
const collections = ['pantryItems', 'shoppingItems', 'mealPlans'];
for (const collection of collections) paths.push(base + '/' + collection + '/item');
for (const path of paths) {
  for (const denied of [outsider, null]) {
    await expectStatus('PATCH', path, denied, 403, false);
  }
  await expectStatus('PATCH', path, signIn, 200, false);
  for (const denied of [outsider, null]) {
    await expectStatus('GET', path, denied, 403);
    await expectStatus('PATCH', path, denied, 403, true);
    await expectStatus('DELETE', path, denied, 403);
  }
  await expectStatus('GET', path, signIn, 200);
  await expectStatus('PATCH', path, signIn, 200, true);
  await expectStatus('DELETE', path, signIn, 200);
}

for (const collection of collections) {
  const path = base + '/' + collection;
  await expectStatus('GET', path, signIn, 200);
  await expectStatus('GET', path, outsider, 403);
  await expectStatus('GET', path, null, 403);
}
for (const path of ['users', base + '/settings', 'unknown/item',
  base + '/settings/other', base + '/pantryItems/item/nested/item']) {
  await expectStatus('GET', path, signIn, 403);
}
for (const path of ['unknown/item', base + '/settings/other',
  base + '/pantryItems/item/nested/item']) {
  await expectStatus('PATCH', path, signIn, 403, false);
}
console.log(checks + ' Firestore security-rule assertions passed.');