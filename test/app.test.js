const { test } = require('node:test');
const assert = require('node:assert/strict');
const { spawn } = require('node:child_process');

const HOST = '127.0.0.1';
let server;
let baseUrl;

async function waitForServer(url, timeoutMs = 10000) {
  const deadline = Date.now() + timeoutMs;

  while (Date.now() < deadline) {
    if (server.exitCode !== null) {
      throw new Error('Application process exited unexpectedly');
    }

    try {
      const response = await fetch(`${url}/ready`);
      if (response.ok) return;
    } catch {
      // Application may still be starting.
    }

    await new Promise(resolve => setTimeout(resolve, 100));
  }

  throw new Error('Application did not become ready');
}

test('Application HTTP endpoints', async (t) => {
  const http = require('node:http');

  // Ask the OS for a free local TCP port.
  const temporaryServer = http.createServer();
  await new Promise(resolve => temporaryServer.listen(0, HOST, resolve));
  const port = temporaryServer.address().port;
  await new Promise(resolve => temporaryServer.close(resolve));

  baseUrl = `http://${HOST}:${port}`;

  server = spawn(process.execPath, ['app.js'], {
    env: { ...process.env, PORT: String(port) },
    stdio: 'ignore'
  });

  try {
    await waitForServer(baseUrl);

    await t.test('Readiness endpoint', async () => {
      const response = await fetch(`${baseUrl}/ready`);
      assert.equal(response.status, 200);
      assert.equal(await response.text(), 'Ready');
    });

    await t.test('Liveness endpoint', async () => {
      const response = await fetch(`${baseUrl}/live`);
      assert.equal(response.status, 200);
      assert.equal(await response.text(), 'Alive');
    });

    await t.test('Application endpoint', async () => {
      const response = await fetch(`${baseUrl}/my-app`);
      assert.equal(response.status, 200);
      assert.match(await response.text(), /Hello, World!/);
    });
  } finally {
    server.kill();

    await new Promise(resolve => {
      if (server.exitCode !== null) return resolve();
      server.once('exit', resolve);
    });
  }
});
