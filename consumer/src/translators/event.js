const util = require("./../helpers/util");
const constants = require("./../helpers/constants");

const ownerForNode = function (node) {
  const field =
    node.payload.value.fields[util.ownerFieldsIndexInEventPayload(node)];
};

module.exports = function (node) {
  const price = parseFloat(node.payload.value.fields[1].value.value);

  return {
    type: node.type,
    externalTransactionId: node.transactionId,
    externalBlockId: node.blockId,
    externalMomentId: node.payload.value.fields[0].value.value,
    externalOwnerId:
      node.payload.value.fields[util.ownerFieldsIndexInEventPayload(node)].value
        .value.value,
    externalTransactionIndex: node.transactionIndex,
    externalEventIndex: node.eventIndex,
    price: isNaN(price) ? null : price,
    createdAt: new Date(),
  };
};
