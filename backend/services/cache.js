const { createClient } = require('redis');
const dotenv = require('dotenv');

dotenv.config();

let redisClient;

/**
 * Initializes the Redis client connection for caching
 */
const initRedis = async () => {
  const url = process.env.REDIS_URL || 'redis://localhost:6379';
  try {
    redisClient = createClient({ url });
    redisClient.on('error', (err) => {
      console.warn('[Redis Cache] Error:', err.message);
    });
    await Promise.race([
      redisClient.connect(),
      new Promise((_, reject) =>
        setTimeout(() => reject(new Error('Redis connection timed out')), 2500)
      ),
    ]);
    console.log('Redis Cache client connected successfully.');
    return true;
  } catch (error) {
    console.warn(`[Redis Cache] Connection failed. Running with cache bypass. (${error.message})`);
    if (redisClient) {
      redisClient.removeAllListeners('error');
      try {
        await redisClient.disconnect();
      } catch (_) {
        // Client may already be closed or still connecting.
      }
    }
    redisClient = null;
    return false;
  }
};

/**
 * Retrieves a parsed JSON value from cache
 * @param {string} key Cache key
 */
const getCache = async (key) => {
  if (!redisClient || !redisClient.isOpen) return null;
  try {
    const value = await redisClient.get(key);
    if (value) {
      console.log(`[Redis Cache] HIT -> Key: "${key}"`);
      return JSON.parse(value);
    }
  } catch (error) {
    console.error(`[Redis Cache] GET error for "${key}":`, error.message);
  }
  console.log(`[Redis Cache] MISS -> Key: "${key}"`);
  return null;
};

/**
 * Saves a serialized JSON value to cache with expiration TTL
 * @param {string} key Cache key
 * @param {any} value Value to cache
 * @param {number} ttl Expiration time in seconds (default: 60)
 */
const setCache = async (key, value, ttl = 60) => {
  if (!redisClient || !redisClient.isOpen) return;
  try {
    await redisClient.set(key, JSON.stringify(value), {
      EX: ttl
    });
    console.log(`[Redis Cache] SET -> Key: "${key}" (TTL: ${ttl}s)`);
  } catch (error) {
    console.error(`[Redis Cache] SET error for "${key}":`, error.message);
  }
};

module.exports = {
  initRedis,
  getCache,
  setCache,
  get client() { return redisClient; }
};
