const sdk = require('@onflow/sdk');
const types = require('@onflow/types');

const TOPSHOT_NODE = 'https://access-mainnet-beta.onflow.org';
const TOPSHOT_ADDRESS = '0b2a3299cc857e29';
const TOPSHOT_MARKET_ADDRESS = '0b2a3299cc857e29';
const TOPSHOT_EVENT_TYPE = 'A.c1e4f4f4c4257510.Market.MomentPurchased';

const TOPSHOT_SALE_MOMENT_SCRIPT = `
  import TopShot from 0x0b2a3299cc857e29
  import Market from 0xc1e4f4f4c4257510

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

  pub fun main(owner:Address, momentID:UInt64): SaleMoment {
    let acct = getAccount(owner)
    let collectionRef =
      acct.getCapability(/public/topshotSaleCollection)!.borrow<&{Market.SalePublic}>() ?? panic("Could not borrow capability from public collection")

    return SaleMoment(
      moment: collectionRef.borrowMoment(id: momentID)!,
      price:  collectionRef.getPrice(tokenID: momentID)!
    )
  }
`;

const opts = {node: TOPSHOT_NODE};

const saleMomentForEvent = async function(event) {
  const payload = event.payload;
  const value = payload.value;
  const moment = value.fields[0];
  const seller = value.fields[2];

  console.log(moment);
  const response = await sdk.send(
    await sdk.pipe(
      await sdk.build([
        sdk.args([
          sdk.arg(seller.value.value.value, types.Address),
          sdk.arg(1349317, types.UInt64),
        ]),
        sdk.script(TOPSHOT_SALE_MOMENT_SCRIPT),
      ]),
      [sdk.resolve([sdk.resolveArguments, sdk.resolveParams])],
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
        blockResponse.block.height - 2000,
        blockResponse.block.height,
      ),
    ]),
    opts,
  );

  const events = [eventsResponse.events[0]];
  events.forEach(function(event) {
    const moment = saleMomentForEvent(event);
  });
};

run();
