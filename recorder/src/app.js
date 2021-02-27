const sdk = require('@onflow/sdk');

console.log('hello world!');

const run = async function() {
  const response = await sdk
    .send(await sdk.build([sdk.ping(), sdk.getLatestBlock()]), {
      node: 'access-001.mainnet.nodes.onflow.org:9000',
    })
    .catch(function(error) {
      console.log(error);
    });
  console.log(response);
};

run();
