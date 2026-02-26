import express from 'express';

const app = express();
const port = process.env.PORT || 3000;
const APP_VERSION = process.env.APP_VERSION || 'v1';

app.get('/healthz', (_req, res) => {
  res.status(200).json({ ok: true });
});

app.get('/version', (_req, res) => {
  res.status(200).json({ service: 'demo-api', version: APP_VERSION });
});

app.get('/api/version', (_req, res) => {
  res.status(200).json({ service: 'demo-api', version: APP_VERSION });
});

app.get('/api/hello', (_req, res) => {
  res.status(200).json({ message: 'Hello from demo-api' });
});

app.listen(port, () => {
  console.log(`[demo-api] listening on port ${port}`);
});
