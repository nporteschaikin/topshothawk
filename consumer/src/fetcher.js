const constants = require("./helpers/constants");
const queue = require("./helpers/queue");
const util = require("./helpers/util");

const sdk = require("@onflow/sdk");
const types = require("@onflow/types");
const interaction = require("@onflow/interaction");

const MOMENT_CADENCE_SCRIPT = require("./cadence/moment.cdc");

const fetchMomentForEventAtBlock = async function (block, event) {
  const payload = event.payload;
  const value = payload.value;
  const moment = value.fields[0];
  const owner = value.fields[util.ownerFieldsIndexInEventPayload(event)];

  const interaction = await sdk.build([
    sdk.script(MOMENT_CADENCE_SCRIPT),
    sdk.atBlockId(block.parentId),
    sdk.args([
      sdk.arg(owner.value.value.value, types.Address),
      sdk.arg(parseInt(moment.value.value), types.UInt64),
    ]),
  ]);

  const pipe = await sdk.pipe(interaction, [
    sdk.resolveArguments,
    sdk.resolveParams,
  ]);

  return await util.retry(async function () {
    const response = await util.send(pipe);
    const data = response.encodedData;
    const body = data.value;

    return body === null ? null : body.value;
  });
};

const fetchEventsAtBlock = async function (block, eventType, attempt = 1) {
  const interaction = await sdk.build([
    sdk.getEvents(
      `${process.env.TOPSHOT_EVENT_TYPE_PREFIX}.${eventType}`,
      block.height - 500,
      block.height
    ),
  ]);

  return await util.retry(async function () {
    const response = await util.send(interaction);
    return response.events;
  });
};

module.exports = function (eventType) {
  return async function () {
    const block = await queue.pop(constants.BLOCK_FETCHED_QUEUE);

    if (block !== null) {
      const events = await fetchEventsAtBlock(block, eventType);

      util.log.info(`Pulled ${events.length} events.`);

      events.forEach(async function (event) {
        const moment = await fetchMomentForEventAtBlock(block, event);
        queue.push(constants.EVENT_FETCHED_QUEUE, {
          block: { id: block.id },
          event: {
            eventIndex: event.eventIndex,
            payload: event.payload,
            transactionId: event.transactionId,
            transactionIndex: event.transactionIndex,
            type: event.type,
          },
          moment,
        });
      });
    }
  };
};
