const queue = require("./helpers/queue");
const util = require("./helpers/util");
const constants = require("./helpers/constants");

const eventTranslator = require("./translators/event");
const momentTranslator = require("./translators/moment");

const pg = require("knex")({
  client: "pg",
  connection: process.env.DATABASE_URL,
});

const upsertEvent = async function (event) {
  const result = await pg(constants.EVENTS_TABLE)
    .insert(util.underscore(eventTranslator(event)))
    .onConflict(constants.EXTERNAL_TRANSACTION_ID_COLUMN)
    .ignore();
};

const upsertMoment = async function (moment) {
  await pg(constants.MOMENTS_TABLE)
    .insert(util.underscore(momentTranslator(moment)))
    .onConflict(constants.EXTERNAL_ID_COLUMN)
    .merge();
};

const handle = async function (payload) {
  await upsertEvent({
    ...payload.event,
    blockId: payload.block.id,
  });

  if (payload.moment !== null) {
    await upsertMoment(payload.moment);
  }
};

module.exports = function () {
  return async function () {
    const payload = await queue.pop(constants.EVENT_FETCHED_QUEUE);

    if (payload !== null) {
      await handle(payload);
    }
  };
};
