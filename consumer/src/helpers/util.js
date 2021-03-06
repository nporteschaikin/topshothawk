const constants = require("./constants");

const sdk = require("@onflow/sdk");
const humps = require("humps");

const sleep = async function (ms) {
  return new Promise((resolve) => {
    setTimeout(resolve, ms);
  });
};
module.exports.sleep = sleep;

const send = async function (req) {
  return await sdk.send(req, { node: process.env.TOPSHOT_NODE });
};
module.exports.send = send;

const log = {
  info: function (str) {
    console.info(str);
  },
};
module.exports.log = log;

const stripEventType = function (type) {
  return type.substr(
    process.env.TOPSHOT_EVENT_TYPE_PREFIX.length + 1,
    type.length
  );
};
module.exports.stripEventType = stripEventType;

const ownerFieldsIndexInEventPayload = function (event) {
  switch (stripEventType(event.type)) {
    case constants.EVENT_TYPES.MOMENT_WITHDRAWN: {
      return 1;
    }
    default: {
      return 2;
    }
  }
};
module.exports.ownerFieldsIndexInEventPayload = ownerFieldsIndexInEventPayload;

module.exports.underscore = humps.decamelizeKeys;

const retry = async function (fn, attempt = 1) {
  try {
    return await fn();
  } catch (e) {
    // retry up to five times.
    // TODO: be discerning with error handling.
    if (attempt === 5) {
      throw e;
    }

    log.info(
      `Retrying after five-second rest due to error: ${e.message} (attempt #${attempt})...`
    );

    await sleep(5000);
    await retry(fn, attempt + 1);
  }
};
module.exports.retry = retry;

// async for-each
const forEach = async function (arr, cb) {
  for (let index = 0; index < arr.length; index++) {
    await cb(arr[index], index, arr);
  }
};
module.exports.forEach = forEach;
