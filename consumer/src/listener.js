const util = require("./helpers/util");
const redis = require("./helpers/redis");

const sdk = require("@onflow/sdk");

const fetchLatestBlock = async function () {
  const interaction = await sdk.build([sdk.getLatestBlock()]);

  const response = await util.send(interaction);
  return response.block;
};

const lpush = async function (block) {
  return new Promise(function (resolve) {
    redis.lpush(process.env.REDIS_QUEUE, JSON.stringify(block), resolve);
  });
};

module.exports = async function () {
  util.log.info(`Fetching latest block...`);

  const block = await fetchLatestBlock();
  await lpush({ id: block.id, height: block.height, parentId: block.parentId });

  util.log.info(`✍️  Pushed block ${block.id} to Redis queue.`);
};
