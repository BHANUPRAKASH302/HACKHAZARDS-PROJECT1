const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config();

// Import services and routers
const { router: authRouter, authenticateToken, seedDemoUser } = require('./routes/auth');
const uploadRouter = require('./routes/upload');
const translateRouter = require('./routes/translate');
const { getRecommendation, recordInteraction, getAllOptions } = require('./services/mab');
const { askRAGChatbot, initMongo } = require('./services/rag');
const { initTelegramBot, initBullMQ, addEmailJob } = require('./services/agent');
const { initRedis, getCache, setCache } = require('./services/cache');

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

// Middleware
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Health Check
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    uptime: process.uptime(),
    timestamp: new Date()
  });
});

const profileRouter = require('./routes/profile');
const reviewsRouter = require('./routes/reviews');
const { router: prescriptoRouter, seedDoctors } = require('./routes/prescripto');
const lawgenRouter = require('./routes/lawgen');
const agrogenRouter = require('./routes/agrogen');
const safeguardRouter = require('./routes/safeguard');

// Bind Route Handlers
app.use('/api/auth', authRouter);
app.use('/api/upload', uploadRouter);
app.use('/api/translate', translateRouter);
app.use('/api/profile', profileRouter);
app.use('/api/reviews', reviewsRouter);
app.use('/api/prescripto', prescriptoRouter);
app.use('/api/lawgen', lawgenRouter);
app.use('/api/agrogen', agrogenRouter);
app.use('/api/safeguard', safeguardRouter);

// ----------------------------------------------------
// MAB (Multi-Armed Bandit) Routes
// ----------------------------------------------------
app.get('/api/mab/recommendation', async (req, res) => {
  try {
    const epsilon = req.query.epsilon ? parseFloat(req.query.epsilon) : 0.2;
    const recommendation = await getRecommendation(epsilon);
    
    // Emit real-time stats update via Socket.IO
    const allStats = await getAllOptions();
    io.emit('mab_stats_update', allStats);

    res.status(200).json(recommendation);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/mab/interaction', async (req, res) => {
  try {
    const { optionId, interactionType } = req.body;
    if (!optionId || !interactionType) {
      return res.status(400).json({ error: 'optionId and interactionType are required' });
    }

    const updatedOption = await recordInteraction(optionId, interactionType);
    
    // Broadcast updated stats to all connected Flutter clients
    const allStats = await getAllOptions();
    io.emit('mab_stats_update', allStats);

    res.status(200).json(updatedOption);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/mab/options', async (req, res) => {
  try {
    const options = await getAllOptions();
    res.status(200).json(options);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ----------------------------------------------------
// Redis Cache-Aside Database Workflow Route
// ----------------------------------------------------
app.get('/api/items', async (req, res) => {
  const cacheKey = 'items_list';
  try {
    // 1. Try reading from Redis Cache
    const cachedData = await getCache(cacheKey);
    if (cachedData) {
      res.setHeader('X-Cache', 'HIT');
      return res.status(200).json({ source: 'Redis Cache', data: cachedData });
    }

    // 2. Cache MISS -> Query Database (MongoDB)
    const { searchDocuments } = require('./services/rag');
    const dbData = await searchDocuments('', 10); // retrieves seeded documents from MongoDB

    // 3. Save to Redis Cache (expires in 30 seconds)
    await setCache(cacheKey, dbData, 30);

    res.setHeader('X-Cache', 'MISS');
    res.status(200).json({ source: 'Database (MongoDB)', data: dbData });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ----------------------------------------------------
// AI RAG Chatbot Route (Ollama Integration)
// ----------------------------------------------------
app.post('/api/ai/chat', async (req, res) => {
  try {
    const { message, stream, model } = req.body;
    if (!message) return res.status(400).json({ error: 'message is required' });

    // Interlink mobile app text with terminal
    console.log(`\n[Mobile App User]: ${message}`);

    const ollamaModel = model || 'llama3'; // Default to llama3 or whichever is available
    const ollamaPayload = {
      model: ollamaModel,
      prompt: message,
      stream: stream === true
    };

    if (stream) {
      res.setHeader('Content-Type', 'text/plain; charset=utf-8');
      res.setHeader('Transfer-Encoding', 'chunked');
      
      const fetch = (await import('node-fetch')).default;
      const ollamaRes = await fetch('http://127.0.0.1:11434/api/generate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(ollamaPayload)
      });

      if (!ollamaRes.ok) throw new Error('Ollama backend failed');
      
      ollamaRes.body.on('data', (chunk) => {
        const lines = chunk.toString().split('\n');
        for (const line of lines) {
          if (line.trim() === '') continue;
          try {
            const json = JSON.parse(line);
            if (json.response) {
              process.stdout.write(json.response); // Interlink with terminal
              res.write(json.response);
            }
          } catch (e) {
            // Ignore parsing errors for partial lines
          }
        }
      });
      
      ollamaRes.body.on('end', () => {
        console.log('\n'); // Add newline after response finishes
        res.end();
      });
    } else {
      const fetch = (await import('node-fetch')).default;
      const ollamaRes = await fetch('http://127.0.0.1:11434/api/generate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(ollamaPayload)
      });
      const data = await ollamaRes.json();
      console.log(`[Ollama AI]: ${data.response}\n`);
      res.status(200).json({ answer: data.response });
    }
  } catch (error) {
    console.error('[Ollama Error]:', error.message);
    if (!res.headersSent) {
      res.status(500).json({ error: error.message });
    }
  }
});

// ----------------------------------------------------
// JARVIS AI Route (Voice Assistant Integration)
// ----------------------------------------------------
app.post('/api/jarvis/chat', async (req, res) => {
  try {
    const { message, session_id, language } = req.body;
    if (!message) return res.status(400).json({ error: 'message is required' });

    console.log(`\n[Mobile App User (JARVIS)] [${session_id || 'default'}]: ${message} (Language: ${language || 'English'})`);

    const fetch = (await import('node-fetch')).default;
    const { AbortController } = await import('node-abort-controller').catch(() => ({ AbortController: global.AbortController }));

    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 60000); // 60s timeout for tool calls

    const jarvisRes = await fetch('http://127.0.0.1:5002/api/jarvis/chat', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ message, session_id: session_id || 'default', language: language || 'English' }),
      signal: controller.signal,
    }).finally(() => clearTimeout(timeout));

    const data = await jarvisRes.json();
    console.log(`[JARVIS AI]: ${data.answer}\n`);
    res.status(200).json(data);
  } catch (error) {
    if (error.name === 'AbortError') {
      console.error('[JARVIS Error]: Request timed out after 60s');
      return res.status(504).json({ error: 'JARVIS took too long to respond. Please try again.' });
    }
    console.error('[JARVIS Error]:', error.message);
    res.status(500).json({ error: error.message });
  }
});


// ----------------------------------------------------
// BullMQ Task Queue Enqueue Route
// ----------------------------------------------------
app.post('/api/tasks/email', authenticateToken, async (req, res) => {
  try {
    const { to, subject, message } = req.body;
    if (!to || !subject || !message) {
      return res.status(400).json({ error: 'to, subject, and message are required' });
    }

    const job = await addEmailJob(to, subject, message);
    res.status(202).json({ message: 'Email task added to BullMQ successfully', jobId: job.id });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ----------------------------------------------------
// Socket.IO Bidirectional Connection
// ----------------------------------------------------
io.on('connection', (socket) => {
  console.log(`[Socket.IO] New client connected: ${socket.id}`);

  // Emit current MAB options to user on connection
  getAllOptions()
    .then(opts => socket.emit('mab_stats_update', opts))
    .catch(err => console.error('[Socket.IO] MAB options fetch error:', err));

  // Chat message channel
  socket.on('send_message', async (data) => {
    console.log(`[Socket.IO] Message received:`, data);
    
    // Echo back the user's message
    socket.emit('receive_message', {
      sender: 'User',
      text: data.text,
      timestamp: new Date()
    });

    // Run the RAG Chatbot reply
    try {
      const response = await askRAGChatbot(data.text);
      socket.emit('receive_message', {
        sender: 'AI Chatbot',
        text: response.answer,
        sources: response.sources,
        timestamp: new Date()
      });
    } catch (err) {
      socket.emit('receive_message', {
        sender: 'System',
        text: 'Error generating response: ' + err.message,
        timestamp: new Date()
      });
    }
  });

  socket.on('disconnect', () => {
    console.log(`[Socket.IO] Client disconnected: ${socket.id}`);
  });
});

// ----------------------------------------------------
// Bootstrap Server Services
// ----------------------------------------------------
const PORT = parseInt(process.env.PORT || '3001', 10);

async function bootstrap(port) {
  // Initialize Redis Cache client
  const redisReady = await initRedis();

  // Connect MongoDB Atlas / Local
  await initMongo();

  // Seed Doctors database
  await seedDoctors();

  // Seed Demo User
  await seedDemoUser();

  // Initialize BullMQ Workers
  if (redisReady) {
    initBullMQ();
  } else {
    console.warn('[BullMQ] Redis unavailable. Task queue disabled for this run.');
  }

  // Initialize Telegram Bot Agent listener
  initTelegramBot();

  return new Promise((resolve, reject) => {
    server.listen(port, () => {
      console.log(`===============================================`);
      console.log(` Vynedam Server running on port ${port}`);
      console.log(` Socket.IO enabled on ws://localhost:${port}`);
      console.log(` OpenTelemetry tracing exporting to http://localhost:4317`);
      console.log(`===============================================`);
      resolve();
    });

    server.on('error', (err) => {
      if (err.code === 'EADDRINUSE') {
        const fallback = port + 1;
        console.warn(`[Server] ⚠️  Port ${port} is already in use.`);
        console.warn(`[Server] 🔄  Trying fallback port ${fallback}...`);
        server.close();
        // Retry on the next port
        server.listen(fallback, () => {
          console.log(`===============================================`);
          console.log(` Vynedam Server running on FALLBACK port ${fallback}`);
          console.log(` Socket.IO enabled on ws://localhost:${fallback}`);
          console.log(`===============================================`);
          resolve();
        });
        server.once('error', (err2) => {
          console.error(`[Server] ❌  Fallback port ${fallback} also failed: ${err2.message}`);
          reject(err2);
        });
      } else {
        reject(err);
      }
    });
  });
}

bootstrap(PORT).catch(err => {
  console.error('Fatal bootstrap error:', err);
  process.exit(1);
});
