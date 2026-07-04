const mongoose = require('mongoose');
const axios = require('axios');
const dotenv = require('dotenv');

dotenv.config();

let DocumentModel;

// Initialize Mongo database connection with local fallback
const initMongo = async () => {
  const uri = process.env.MONGO_URI_ATLAS || process.env.MONGO_URI_LOCAL || 'mongodb://localhost:27017/User_Data';
  try {
    // Prevent re-connecting if already connected
    if (mongoose.connection.readyState === 0) {
      await mongoose.connect(uri, { serverSelectionTimeoutMS: 5000 });
      console.log(`MongoDB connected: ${uri.includes('mongodb+srv') ? 'Atlas Cloud' : 'Local Host'}`);
    }
  } catch (error) {
    console.warn('MongoDB connection failed. In-memory storage will be used for documents.');
  }

  const documentSchema = new mongoose.Schema({
    title: { type: String, required: true },
    content: { type: String, required: true },
    createdAt: { type: Date, default: Date.now }
  });

  // Enable text index for search
  documentSchema.index({ title: 'text', content: 'text' });

  DocumentModel = mongoose.models.Document || mongoose.model('Document', documentSchema);

  // Seed default dataset if MongoDB is online and empty
  try {
    if (mongoose.connection.readyState === 1) {
      const count = await DocumentModel.countDocuments();
      if (count === 0) {
        await DocumentModel.insertMany([
          { title: 'Hackathon Info', content: 'The Vynedam Hackathon starts on June 6th, 2026. The goal is to build premium, user-friendly mobile applications integrating modern AI/ML, databases, and caching technologies.' },
          { title: 'Ollama Integration', content: 'Ollama is used as an offline local LLM. It exposes HTTP APIs on http://localhost:11434. Default model configured is llama3.' },
          { title: 'Reinforcement Learning', content: 'Our app uses Epsilon-Greedy Multi-Armed Bandit for recommendation engines. Rewards are +1 for positive, -1 for negative, and +5 for completing a task.' }
        ]);
        console.log('Seeded initial RAG documents in MongoDB.');
      }
    }
  } catch (err) {
    console.error('Error seeding MongoDB documents:', err);
  }
};

const localMockDocs = [
  { title: 'Hackathon Info', content: 'The Vynedam Hackathon starts on June 6th, 2026. The goal is to build premium, user-friendly mobile applications integrating modern AI/ML, databases, and caching technologies.' },
  { title: 'Ollama Integration', content: 'Ollama is used as an offline local LLM. It exposes HTTP APIs on http://localhost:11434. Default model configured is llama3.' },
  { title: 'Reinforcement Learning', content: 'Our app uses Epsilon-Greedy Multi-Armed Bandit for recommendation engines. Rewards are +1 for positive, -1 for negative, and +5 for completing a task.' }
];

const getDocumentModel = async () => {
  if (!DocumentModel) {
    await initMongo();
  }
  return DocumentModel;
};

/**
 * Searches relevant documents in DB
 * @param {string} query Search terms
 * @param {number} limit Maximum results to return
 */
async function searchDocuments(query, limit = 3) {
  await getDocumentModel();

  if (mongoose.connection.readyState === 1) {
    try {
      // Try text score index
      let results = await DocumentModel.find(
        { $text: { $search: query } },
        { score: { $meta: 'textScore' } }
      ).sort({ score: { $meta: 'textScore' } }).limit(limit);

      if (results.length === 0) {
        // Regex search fallback
        results = await DocumentModel.find({
          $or: [
            { title: { $regex: query, $options: 'i' } },
            { content: { $regex: query, $options: 'i' } }
          ]
        }).limit(limit);
      }
      return results;
    } catch (error) {
      console.error('MongoDB query error, falling back to local:', error);
    }
  }

  // Offline mock local search
  return localMockDocs.filter(doc =>
    doc.title.toLowerCase().includes(query.toLowerCase()) ||
    doc.content.toLowerCase().includes(query.toLowerCase())
  ).slice(0, limit);
}

/**
 * Executes a full RAG cycle against local Ollama model
 * @param {string} userMessage User's chat input
 */
async function askRAGChatbot(userMessage) {
  const docs = await searchDocuments(userMessage, 2);
  const contextText = docs.map(d => `[Source: ${d.title}]\n${d.content}`).join('\n\n');

  const prompt = `You are a helpful, offline AI assistant running locally. Use the following context to answer the user query. If you do not know the answer, use your pre-trained knowledge but prioritize the context.

Context:
${contextText || 'No context matches found.'}

User Query: ${userMessage}
Answer:`;

  const ollamaUrl = `${process.env.OLLAMA_HOST || 'http://localhost:11434'}/api/generate`;
  const model = process.env.OLLAMA_MODEL || 'llama3';

  console.log(`[RAG] Contacting Ollama at ${ollamaUrl} (model: ${model})`);

  try {
    const response = await axios.post(ollamaUrl, {
      model: model,
      prompt: prompt,
      stream: false
    }, { timeout: 10000 });

    return {
      answer: response.data.response,
      sources: docs.map(d => d.title),
      offline: true
    };
  } catch (error) {
    console.warn('Ollama local LLM is offline or not running. Returning simulated response.');
    return {
      answer: `[SIMULATED - OLLAMA OFFLINE] I searched the local documents and found context about: ${docs.map(d => d.title).join(', ') || 'Nothing matching'}.\n\nHere is what I found:\n${docs.map(d => d.content).join('\n') || 'Please seed some documents.'}`,
      sources: docs.map(d => d.title),
      offline: false,
      error: error.message
    };
  }
}

async function askRAGChatbotStream(userMessage, res) {
  const docs = await searchDocuments(userMessage, 2);
  const contextText = docs.map(d => `[Source: ${d.title}]\n${d.content}`).join('\n\n');

  const prompt = `You are a helpful, offline AI assistant running locally. Use the following context to answer the user query. If you do not know the answer, use your pre-trained knowledge but prioritize the context.\n\nContext:\n${contextText || 'No context matches found.'}\n\nUser Query: ${userMessage}\nAnswer:`;

  const ollamaUrl = `${process.env.OLLAMA_HOST || 'http://localhost:11434'}/api/generate`;
  const model = process.env.OLLAMA_MODEL || 'llama3';

  console.log(`[RAG] Contacting Ollama at ${ollamaUrl} (model: ${model}) for streaming`);

  try {
    const response = await axios.post(ollamaUrl, {
      model: model,
      prompt: prompt,
      stream: true
    }, { responseType: 'stream', timeout: 10000 });

    response.data.on('data', (chunk) => {
      try {
        const parsed = JSON.parse(chunk.toString());
        if (parsed.response) {
          res.write(parsed.response);
        }
      } catch (e) {
        // Ignore JSON parse errors for incomplete chunks, though Ollama usually sends complete JSON lines
      }
    });

    response.data.on('end', () => {
      res.end();
    });

  } catch (error) {
    console.warn('Ollama local LLM is offline or not running. Returning simulated response.');
    res.write(`[SIMULATED - OLLAMA OFFLINE] I searched the local documents and found context about: ${docs.map(d => d.title).join(', ') || 'Nothing matching'}.\n\nHere is what I found:\n${docs.map(d => d.content).join('\n') || 'Please seed some documents.'}`);
    res.end();
  }
}

module.exports = {
  askRAGChatbot,
  askRAGChatbotStream,
  searchDocuments,
  initMongo
};
