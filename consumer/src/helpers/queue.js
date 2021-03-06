const redis = require("redis").createClient(process.env.REDIS_URL);
const util = require("./util");
const constants = require("./constants");

const formatJSON = function (json) {
  return json.slice(0, 100);
};

const buildPushHandler = function (queue, json, resolve) {
  return function () {
    if (process.env.LOG_QUEUE_PUSH) {
      util.log.info(`Pushed message ${formatJSON(json)}... to queue ${queue}.`);
    }

    resolve();
  };
};

const buildPopHandler = function (resultIndex, resolve, reject) {
  return function (err, result) {
    if (err !== null) {
      reject(err);
      return;
    }

    if (typeof result === "undefined") {
      resolve(null);
      return;
    }

    const json = result[resultIndex];

    if (typeof json === "undefined") {
      resolve(null);
      return;
    }

    if (process.env.LOG_QUEUE_POP) {
      util.log.info(`Popped message ${formatJSON(json)}...`);
    }

    resolve(JSON.parse(json));
  };
};

module.exports.push = async function (queue, payload) {
  return new Promise(function (resolve) {
    const json = JSON.stringify(payload);

    redis.lpush(queue, json, buildPushHandler(queue, json, resolve));
  });
};

module.exports.pop = async function (queue) {
  return new Promise(function (resolve, reject) {
    redis.brpop(queue, 0, buildPopHandler(1, resolve, reject));
  });
};

module.exports.uniquePush = async function (queue, payload) {
  return new Promise(function (resolve) {
    const json = JSON.stringify(payload);

    redis.zadd(
      queue,
      "NX",
      new Date().getTime().toString(),
      json,
      buildPushHandler(queue, json, resolve)
    );
  });
};

module.exports.uniquePop = async function (queue, payload) {
  return new Promise(function (resolve, reject) {
    redis.zpopmin(queue, buildPopHandler(0, resolve, reject));
  });
};

module.exports.buildBlockFetchedQueueName = function (eventType) {
  return [constants.BLOCK_FETCHED_QUEUE_PREFIX, eventType].join(".");
};
