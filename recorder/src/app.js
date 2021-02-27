const sdk = require('@onflow/sdk');
const types = require('@onflow/types');
const interaction = require('@onflow/interaction');

const TOPSHOT_NODE = 'https://access-mainnet-beta.onflow.org';
const TOPSHOT_ADDRESS = '0b2a3299cc857e29';
const TOPSHOT_MARKET_ADDRESS = 'c1e4f4f4c4257510';
const TOPSHOT_EVENT_TYPE = 'A.c1e4f4f4c4257510.Market.MomentPurchased';

const opts = {node: TOPSHOT_NODE};

const saleMomentForEvent = async function(event, height) {
  const payload = event.payload;
  const value = payload.value;
  const moment = value.fields[0];
  const seller = value.fields[2];

  const script = `
    import TopShot from 0x${TOPSHOT_ADDRESS}
    import Market from 0x${TOPSHOT_MARKET_ADDRESS}

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

    pub fun main(): SaleMoment {
      let acct = getAccount(${seller.value.value.value})
      let collection =
        acct.getCapability(/public/topshotSaleCollection)!.borrow<&{Market.SalePublic}>() ?? panic("Could not borrow capability from public collection")
      return SaleMoment(
        moment: collection.borrowMoment(id: ${moment.value.value})!,
        price:  collection.getPrice(tokenID: ${moment.value.value})!
      )
    }
  `;

  const response = await sdk.send(
    await sdk.pipe(
      await sdk.build([sdk.getBlockByHeight(height), sdk.script(script)]),
    ),
    opts,
  );

  console.log(response);
};

const run = async function() {
  const blockResponse = await sdk.send(
    await sdk.build([sdk.getLatestBlock()]),
    opts,
  );

  const eventsResponse = await sdk.send(
    await sdk.build([
      sdk.getEvents(
        TOPSHOT_EVENT_TYPE,
        blockResponse.block.height - 5000,
        blockResponse.block.height,
      ),
    ]),
    opts,
  );

  const events = [eventsResponse.events[0]];
  events.forEach(function(event) {
    const moment = saleMomentForEvent(event, blockResponse.block.height);
  });
};

run();
