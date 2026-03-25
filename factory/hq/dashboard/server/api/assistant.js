const express = require('express');
const router = express.Router();
const http = require('http');

const ASSISTANT_URL = 'http://127.0.0.1:3002';

// POST /api/assistant — proxy to Python assistant server
router.post('/', (req, res) => {
  const { message, session_id } = req.body;

  if (!message) {
    return res.status(400).json({ error: 'message required' });
  }

  const postData = JSON.stringify({ message, session_id: session_id || 'default' });

  const options = {
    hostname: '127.0.0.1',
    port: 3002,
    path: '/chat',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(postData),
    },
    timeout: 60000,
  };

  const proxyReq = http.request(options, (proxyRes) => {
    let data = '';
    proxyRes.on('data', (chunk) => data += chunk);
    proxyRes.on('end', () => {
      try {
        const parsed = JSON.parse(data);
        res.json(parsed);
      } catch (e) {
        res.json({ response: data, session_id: session_id || 'default' });
      }
    });
  });

  proxyReq.on('error', (err) => {
    res.status(503).json({
      error: 'Assistant offline',
      hint: 'Starte mit: python -m factory.hq.assistant.server',
    });
  });

  proxyReq.on('timeout', () => {
    proxyReq.destroy();
    res.status(504).json({ error: 'Assistant timeout' });
  });

  proxyReq.write(postData);
  proxyReq.end();
});

// POST /api/assistant/speak — proxy to ElevenLabs TTS via Python server
router.post('/speak', (req, res) => {
  const { text, voice_id } = req.body;

  if (!text) {
    return res.status(400).json({ error: 'text required' });
  }

  const postData = JSON.stringify({ text, voice_id });

  const options = {
    hostname: '127.0.0.1',
    port: 3002,
    path: '/speak',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(postData),
    },
    timeout: 20000,
  };

  const proxyReq = http.request(options, (proxyRes) => {
    let data = '';
    proxyRes.on('data', (chunk) => data += chunk);
    proxyRes.on('end', () => {
      try {
        res.json(JSON.parse(data));
      } catch (e) {
        res.status(500).json({ error: 'Invalid response from speak endpoint' });
      }
    });
  });

  proxyReq.on('error', () => {
    res.status(503).json({ error: 'Assistant offline' });
  });

  proxyReq.on('timeout', () => {
    proxyReq.destroy();
    res.status(504).json({ error: 'Speak timeout' });
  });

  proxyReq.write(postData);
  proxyReq.end();
});

// GET /api/assistant/health — check if assistant server is running
router.get('/health', (req, res) => {
  const options = { hostname: '127.0.0.1', port: 3002, path: '/health', timeout: 3000 };

  const check = http.get(options, (proxyRes) => {
    let data = '';
    proxyRes.on('data', (chunk) => data += chunk);
    proxyRes.on('end', () => {
      try {
        res.json({ online: true, ...JSON.parse(data) });
      } catch (e) {
        res.json({ online: true });
      }
    });
  });

  check.on('error', () => res.json({ online: false }));
  check.on('timeout', () => { check.destroy(); res.json({ online: false }); });
});

module.exports = router;
