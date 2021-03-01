const redis = require('redis');

module.exports = redis.createClient(process.env.REDIS_URL);
