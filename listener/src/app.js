const util = require('./util');
const redis = require('./redis');

const sdk = require('@onflow/sdk');

const fetchLatestBlock = async function() {
  const interaction = await sdk.build([sdk.getLatestBlock()]);

  const response = await util.send(interaction);
  return response.block;
};

const runOnce = async function() {
  util.log.info(`Fetching latest block...`);

  const block = await fetchLatestBlock();
  await redis.lpush(process.env.REDIS_QUEUE, JSON.stringify(block));

  util.log.info(`Pushed block ${block.id} to Redis queue.`);
};

const run = async function() {
  let shutdown = false;

  process.on('SIGINT', function() {
    util.log.info('Shutting down...');
    shutdown = true;
  });

  util.log.info('👋 Howdy!');

  while (!shutdown) {
    await runOnce();

    util.log.info('Sleeping...');
    await util.sleep(500);
  }

  util.log.info('👋 Bye!');
};

run();
