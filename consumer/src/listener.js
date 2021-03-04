const util = require('./helpers/util');
const queue = require('./helpers/queue');
const constants = require('./helpers/constants');

const sdk = require('@onflow/sdk');

const fetchLatestBlock = async function() {
  const interaction = await sdk.build([sdk.getLatestBlock()]);

  const response = await util.send(interaction);
  return response.block;
};

module.exports = function() {
  return async function() {
    const block = await fetchLatestBlock();

    await queue.push(constants.BLOCK_FETCHED_QUEUE, {
      id: block.id,
      height: block.height,
    });
  };
};
