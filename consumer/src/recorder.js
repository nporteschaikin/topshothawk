const queue = require("./helpers/queue");
const util = require("./helpers/util");
const constants = require("./helpers/constants");

const eventTranslator = require("./translators/event");
const momentTranslator = require("./translators/moment");

const pg = require("knex")({
  client: "pg",
  connection: process.env.DATABASE_URL,
  acquireConnectionTimeout: 2000,
});

const upsertEvent = async function (event) {
  util.log.info(
    `Writing event with transaction ID ${event.transactionId} to Postgres...`
  );

  await pg(constants.EVENTS_TABLE)
    .insert(util.underscore(eventTranslator(event)))
    .onConflict(constants.EXTERNAL_TRANSACTION_ID_COLUMN)
    .ignore()
    .timeout(2000);
};

const upsertMoment = async function (moment) {
  util.log.info(`Writing moment with ID ${moment.id} to Postgres...`);

  await pg(constants.MOMENTS_TABLE)
    .insert(util.underscore(momentTranslator(moment)))
    .onConflict(constants.EXTERNAL_ID_COLUMN)
    .merge()
    .timeout(2000);
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
