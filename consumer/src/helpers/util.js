const sdk = require('@onflow/sdk');

const sleep = async function(ms) {
  return new Promise(resolve => {
    setTimeout(resolve, ms);
  });
};
module.exports.sleep = sleep;

const send = async function(req) {
  return await sdk.send(req, {node: process.env.TOPSHOT_NODE});
};
module.exports.send = send;

const log = {
  info: function(str) {
    console.info(str);
  },
};
module.exports.log = log;
