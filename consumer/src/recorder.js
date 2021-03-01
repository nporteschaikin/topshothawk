const insert = require('./helpers/insert');
const redis = require('./helpers/redis');
const util = require('./helpers/util');

const sdk = require('@onflow/sdk');
const types = require('@onflow/types');
const interaction = require('@onflow/interaction');

const TOPSHOT_SALE_MOMENT_SCRIPT = `
import TopShot from 0x${process.env.TOPSHOT_ADDRESS}
import Market from 0x${process.env.TOPSHOT_MARKET_ADDRESS}

pub struct SaleMoment {
  pub var id: UInt64
  pub var playId: UInt32
  pub var play: {String: String}
  pub var setId: UInt32
  pub var setName: String
  pub var serialNumber: UInt32
  pub var price: UFix64

  init(moment: &TopShot.NFT, price: UFix64) {
    self.id = moment.id
    self.playId = moment.data.playID
    self.play = TopShot.getPlayMetaData(playID: self.playId)!
    self.setId = moment.data.setID
    self.setName = TopShot.getSetName(setID: self.setId)!
    self.serialNumber = moment.data.serialNumber
    self.price = price
  }
}

pub fun main(seller: Address, momentID: UInt64): SaleMoment? {
  let acct = getAccount(seller)
  let collection =
    acct.getCapability(/public/topshotSaleCollection)!.borrow<&{Market.SalePublic}>() ?? panic("Could not borrow capability from public collection")

  //return SaleMoment(
    //moment: collection.borrowMoment(id: momentID)!,
    //price:  collection.getPrice(tokenID: momentID)!
  //)
  if (collection.getIDs().length > 0){
    return SaleMoment(
      moment: collection.borrowMoment(id: collection.getIDs()[0])!,
      price:  collection.getPrice(tokenID: collection.getIDs()[0])!
    )
  } else {
    return nil
  }
}
`;

const fetchMomentAtParentBlock = async function(event, block) {
  const payload = event.payload;
  const value = payload.value;
  const moment = value.fields[0];
  const seller = value.fields[2];

  const interaction = await sdk.build([
    sdk.script(TOPSHOT_SALE_MOMENT_SCRIPT),
    //sdk.atBlockId(block.parentId),
    sdk.args([
      sdk.arg(seller.value.value.value, types.Address),
      sdk.arg(parseInt(moment.value.value), types.UInt64),
    ]),
  ]);

  const pipe = await sdk.pipe(interaction, [
    sdk.resolveArguments,
    sdk.resolveParams,
  ]);

  const response = await util.send(pipe);
  const data = response.encodedData;
  const body = data.value;

  return body === null ? null : body.value;
};

const fetchEventsAtBlock = async function(block) {
  const interaction = await sdk.build([
    sdk.getEvents(
      process.env.TOPSHOT_MOMENT_PURCHASED_EVENT_TYPE,
      block.height - 10,
      block.height,
    ),
  ]);

  const response = await util.send(interaction);
  return response.events;
};

const popBlock = function() {
  return new Promise(function(resolve) {
    redis.brpop(process.env.REDIS_QUEUE, 0, function(err, result) {
      resolve(result === null ? null : JSON.parse(result[1]));
    });
  });
};

const runOnce = async function() {
  const block = await popBlock();

  if (block !== null) {
    util.log.info(`Handling events for block ${block.id}...`);

    const events = await fetchEventsAtBlock(block);
    events.forEach(async function(event) {
      const moment = await fetchMomentAtParentBlock(event, block);

      if (moment !== null) {
        insert(moment);
      }
    });
  }
};

module.exports = async function() {
  let shutdown = false;

  process.on('SIGINT', function() {
    util.log.info('Shutting down...');
    shutdown = true;
  });

  util.log.info('👋 Howdy!');

  while (!shutdown) {
    await runOnce();

    util.log.info('Sleeping...');
    await util.sleep(5000);
  }

  util.log.info('👋 Bye!');
};
