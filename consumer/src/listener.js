const util = require("./helpers/util");
const queue = require("./helpers/queue");
const constants = require("./helpers/constants");

const sdk = require("@onflow/sdk");

const fetchLatestBlock = async function () {
  const interaction = await sdk.build([sdk.getLatestBlock()]);

  return await util.retry(async function () {
    const response = await util.send(interaction);
    return response.block;
  });
};

module.exports = function () {
  return async function () {
    const block = await fetchLatestBlock();

    await util.forEach(
      Object.values(constants.EVENT_TYPES),
      async function (eventType) {
        await queue.uniquePush(queue.buildBlockFetchedQueueName(eventType), {
          id: block.id,
          height: block.height,
        });
      }
    );
  };
};
