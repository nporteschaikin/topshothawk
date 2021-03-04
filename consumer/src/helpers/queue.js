const redis = require("redis").createClient(process.env.REDIS_URL);
const util = require("./util");
const constants = require("./constants");

const formatJSON = function (json) {
  return json.slice(0, 100);
};

module.exports.push = async function (queue, payload) {
  return new Promise(function (resolve) {
    const json = JSON.stringify(payload);

    redis.lpush(queue, json, function () {
      if (process.env.LOG_QUEUE) {
        util.log.info(
          `Pushed message ${formatJSON(json)}... to queue ${queue}.`
        );
      }

      resolve();
    });
  });
};

module.exports.pop = async function (queue) {
  if (process.env.LOG_QUEUE) {
    util.log.info(`Popping from ${queue} queue...`);
  }

  return new Promise(function (resolve) {
    redis.brpop(queue, 0, function (err, result) {
      if (result === null) return resolve(null);

      const json = result[1];

      if (process.env.LOG_QUEUE) {
        util.log.info(`Popped message ${formatJSON(json)}...`);
      }

      return resolve(JSON.parse(json));
    });
  });
};

module.exports.buildBlockFetchedQueueName = function (eventType) {
  return [constants.BLOCK_FETCHED_QUEUE_PREFIX, eventType].join(".");
};
