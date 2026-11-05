const request = require('supertest');
const app = require('./app');

describe('health probes', () => {
    test('GET /live returns 200', async () => {
        const res = await request(app).get('/live');
        expect(res.status).toBe(200);
    });

    test('GET /ready returns 200', async () => {
        const res = await request(app).get('/ready');
        expect(res.status).toBe(200);
    });
});

describe('app endpoints', () => {
    test('GET /my-app returns hello world', async () => {
        const res = await request(app).get('/my-app');
        expect(res.status).toBe(200);
        expect(res.text).toBe('Hello, World!');
    });

    test('GET /metrics exposes the custom counter', async () => {
        const res = await request(app).get('/metrics');
        expect(res.status).toBe(200);
        expect(res.text).toContain('root_access_total');
    });
});
