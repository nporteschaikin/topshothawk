const pg = require('./pg');

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

pub fun main(seller: Address, momentID: UInt64): SaleMoment {
  let acct = getAccount(seller)
  let collection =
    acct.getCapability(/public/topshotSaleCollection)!.borrow<&{Market.SalePublic}>() ?? panic("Could not borrow capability from public collection")

  return SaleMoment(
    moment: collection.borrowMoment(id: momentID)!,
    price:  collection.getPrice(tokenID: momentID)!
  )
}
`;

const send = async function(req) {
  return await sdk.send(req, {node: process.env.TOPSHOT_NODE});
};

const fetchMomentAtParentBlock = async function(event, block) {
  const payload = event.payload;
  const value = payload.value;
  const moment = value.fields[0];
  const seller = value.fields[2];

  const interaction = await sdk.build([
    sdk.script(TOPSHOT_SALE_MOMENT_SCRIPT),
    sdk.atBlockId(block.parentId),
    sdk.args([
      sdk.arg(seller.value.value.value, types.Address),
      sdk.arg(parseInt(moment.value.value), types.UInt64),
    ]),
  ]);

  const pipe = await sdk.pipe(interaction, [
    sdk.resolveArguments,
    sdk.resolveParams,
  ]);

  const response = await send(pipe);

  console.log(response);
};

const fetchLatestBlock = async function() {
  const interaction = await sdk.build([sdk.getLatestBlock()]);

  const response = await send(interaction);
  return response.block;
};

const fetchEventsAtBlock = async function(block) {
  const interaction = await sdk.build([
    sdk.getEvents(
      process.env.TOPSHOT_MOMENT_PURCHASED_EVENT_TYPE,
      block.height - 5000,
      block.height,
    ),
  ]);

  const response = await send(interaction);
  return response.events;
};

const processMoment = function(event, block) {
  console.log('process moment!');
};

const run = async function() {
  const block = await fetchLatestBlock();
  const events = await fetchEventsAtBlock(block);

  events.forEach(async function(event) {
    const moment = await fetchMomentAtParentBlock(event, block);
    processMoment(moment, event);
  });
};

run();
