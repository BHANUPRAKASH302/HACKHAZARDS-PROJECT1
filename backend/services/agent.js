const { Queue, Worker } = require('bullmq');
const { Telegraf } = require('telegraf');
const nodemailer = require('nodemailer');
const axios = require('axios');
const url = require('url');
const dotenv = require('dotenv');

dotenv.config();

// Parse Redis Config for BullMQ
let redisConfig = { host: '127.0.0.1', port: 6379 };
if (process.env.REDIS_URL) {
  try {
    const parsed = url.parse(process.env.REDIS_URL);
    redisConfig.host = parsed.hostname || '127.0.0.1';
    redisConfig.port = parsed.port ? parseInt(parsed.port) : 6379;
    if (parsed.auth) {
      redisConfig.password = parsed.auth.split(':')[1];
    }
  } catch (e) {
    console.error('Failed to parse REDIS_URL, default to localhost:', e);
  }
}

// ----------------------------------------------------
// AI Agent Notifications: Web3Forms & Gmail SMTP
// ----------------------------------------------------

async function sendWeb3FormsEmail(to, subject, message) {
  const key = process.env.WEB3FORMS_ACCESS_KEY;
  if (!key || key.includes('YOUR_')) {
    console.warn('[Agent] Web3Forms Access Key not set.');
    return false;
  }
  try {
    const response = await axios.post('https://api.web3forms.com/submit', {
      access_key: key,
      name: 'Vynedam AI Agent',
      email: to,
      subject: subject,
      message: message
    });
    return response.data.success;
  } catch (error) {
    console.error('[Agent] Web3Forms submit failed:', error.message);
    return false;
  }
}

async function sendGmailEmail(to, subject, text) {
  const user = process.env.GMAIL_USER;
  const pass = process.env.GMAIL_PASS;
  if (!user || !pass || user.includes('your_')) {
    console.warn('[Agent] Gmail details not set.');
    return false;
  }
  try {
    const transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: { user, pass }
    });
    await transporter.sendMail({
      from: user,
      to,
      subject,
      text
    });
    console.log(`[Agent] Nodemailer sent email to ${to}`);
    return true;
  } catch (error) {
    console.error('[Agent] Gmail SMTP send failed:', error.message);
    return false;
  }
}

// ----------------------------------------------------
// Telegram Bot Client (RAG Integration)
// ----------------------------------------------------

let telegramBot;

function initTelegramBot() {
  const token = process.env.TELEGRAM_BOT_TOKEN;
  if (!token || token.includes('YOUR_')) {
    console.log('[Agent] Telegram Bot Token not set. Telegram service offline.');
    return;
  }
  try {
    telegramBot = new Telegraf(token);
    const { askRAGChatbot } = require('./rag');

    telegramBot.start((ctx) => ctx.reply('Welcome to Vynedam AI Agent! Ask me anything about the Hackathon.'));
    telegramBot.help((ctx) => ctx.reply('Send any text query to search our local database.'));

    telegramBot.on('text', async (ctx) => {
      ctx.sendChatAction('typing');
      try {
        const reply = await askRAGChatbot(ctx.message.text);
        await ctx.reply(reply.answer);
      } catch (err) {
        console.error('[Telegram] Error generating reply:', err);
        await ctx.reply('Error processing prompt.');
      }
    });

    telegramBot.launch()
      .then(() => console.log('Telegram Bot active and listening.'))
      .catch((err) => console.warn('Could not launch Telegram Bot:', err.message));

    process.once('SIGINT', () => telegramBot.stop('SIGINT'));
    process.once('SIGTERM', () => telegramBot.stop('SIGTERM'));
  } catch (error) {
    console.error('[Telegram] Failed to initialize bot:', error.message);
  }
}

// ----------------------------------------------------
// BullMQ Queues and Workers
// ----------------------------------------------------

let taskQueue;
let queueWorker;

function initBullMQ() {
  try {
    taskQueue = new Queue('vynedam_tasks', { connection: redisConfig });

    queueWorker = new Worker('vynedam_tasks', async (job) => {
      console.log(`[BullMQ] Executing Job: ${job.name} (ID: ${job.id})`);
      const { to, subject, message, chat_id, telegram_text, text_to_summarize } = job.data;

      switch (job.name) {
        case 'send_email':
          let emailSent = await sendWeb3FormsEmail(to, subject, message);
          if (!emailSent) {
            emailSent = await sendGmailEmail(to, subject, message);
          }
          return { success: emailSent };

        case 'telegram_notify':
          if (telegramBot && chat_id) {
            await telegramBot.telegram.sendMessage(chat_id, telegram_text);
            return { success: true };
          }
          return { success: false, error: 'Telegram Bot offline or chat ID missing' };

        case 'ai_summarize':
          const { askRAGChatbot } = require('./rag');
          const summary = await askRAGChatbot(`Summarize this text in 2 sentences:\n${text_to_summarize}`);
          return { success: true, summary: summary.answer };

        default:
          return { success: false, error: 'Unknown job name' };
      }
    }, { connection: redisConfig });

    queueWorker.on('completed', (job) => {
      console.log(`[BullMQ] Job ${job.id} (${job.name}) completed.`);
    });

    queueWorker.on('failed', (job, err) => {
      console.error(`[BullMQ] Job ${job.id} (${job.name}) failed:`, err.message);
    });

    console.log('BullMQ setup complete on Redis.');
  } catch (error) {
    console.error('[BullMQ] Setup failed:', error.message);
  }
}

// Helper Enqueuing Functions
async function addEmailJob(to, subject, message) {
  if (taskQueue) {
    return await taskQueue.add('send_email', { to, subject, message });
  }
  const sent = await sendGmailEmail(to, subject, message);
  return { id: null, direct: true, sent };
}

async function addTelegramNotifyJob(chat_id, telegram_text) {
  if (taskQueue) {
    return await taskQueue.add('telegram_notify', { chat_id, telegram_text });
  }
  return null;
}

async function addAISummarizeJob(text_to_summarize) {
  if (taskQueue) {
    return await taskQueue.add('ai_summarize', { text_to_summarize });
  }
  return null;
}

module.exports = {
  initTelegramBot,
  initBullMQ,
  addEmailJob,
  addTelegramNotifyJob,
  addAISummarizeJob
};
