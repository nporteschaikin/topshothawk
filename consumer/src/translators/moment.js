const fieldValue = function (moment, key) {
  const body = moment.fields.find(function (f) {
    return f.name == key;
  });

  return body.value.value;
};

const playFieldValue = function (moment, key) {
  const fields = moment.fields[2].value.value;
  const body = fields.find(function (f) {
    return f.key.value == key;
  });

  const value = body.value.value;
  if (value !== "N/A") {
    return body.value.value;
  }
};

module.exports = function (node) {
  return {
    externalId: fieldValue(node, "id"),
    serialNumber: fieldValue(node, "serialNumber"),
    price: fieldValue(node, "price"),
    setId: fieldValue(node, "setId"),

    setName: fieldValue(node, "setName"),
    playerFullName: playFieldValue(node, "FullName"),
    playerFirstName: playFieldValue(node, "FirstName"),
    playerLastName: playFieldValue(node, "LastName"),
    playerBirthdate: playFieldValue(node, "Birthdate"),
    playerBirthplace: playFieldValue(node, "Birthplace"),
    playerJerseyNumber: playFieldValue(node, "JerseyNumber"),
    playerDraftTeam: playFieldValue(node, "DraftTeam"),
    playerDraftYear: playFieldValue(node, "DraftYear"),
    playerDraftSelection: playFieldValue(node, "DraftSelection"),
    playerDraftRound: playFieldValue(node, "DraftRound"),
    playerTeamAtMomentNbaid: playFieldValue(node, "TeamAtMomentNBAID"),
    playerTeamAtMomentName: playFieldValue(node, "TeamAtMoment"),
    playerPrimaryPosition: playFieldValue(node, "PrimaryPosition"),
    playerPosition: playFieldValue(node, "PlayerPosition"),
    playerHeightInches: playFieldValue(node, "Height"),
    playerWeightPounds: playFieldValue(node, "Weight"),
    playerYearsExperience: playFieldValue(node, "TotalYearsExperience"),
    playNbaSeason: playFieldValue(node, "NbaSeason"),
    playGameTime: new Date(playFieldValue(node, "DateOfMoment")),
    playCategory: playFieldValue(node, "PlayCategory"),
    playType: playFieldValue(node, "PlayType"),
    playHomeTeamName: playFieldValue(node, "HomeTeamName"),
    playAwayTeamName: playFieldValue(node, "AwayTeamName"),
    playHomeTeamScore: playFieldValue(node, "HomeTeamScore"),
    playAwayTeamScore: playFieldValue(node, "AwayTeamScore"),
    createdAt: new Date(),
  };
};
