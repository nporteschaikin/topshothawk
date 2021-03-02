const util = require("./util");
const pg = require("pg");

const pool = new pg.Pool({
  connectionString: process.env.DATABASE_URL,
});

const statement = `
  INSERT INTO moments (
    external_id,
    serial_number,
    price,
    player_full_name,
    player_first_name,
    player_lastname,
    player_birthdate,
    player_birthplace,
    player_jersey_number,
    player_draft_team,
    player_draft_year,
    player_draft_selection,
    player_draft_round,
    player_team_at_moment_nbaid,
    player_team_at_moment_name,
    player_primary_position,
    player_position,
    player_height_inches,
    player_weight_pounds,
    player_years_experience,
    play_nba_season,
    play_game_time,
    play_category,
    play_type,
    play_home_team_name,
    play_away_team_name,
    play_home_team_score,
    play_away_team_score,
    set_id,
    set_name,
    created_at
  )
  values (
    $1,
    $2,
    $3,
    $4,
    $5,
    $6,
    $7,
    $8,
    $9,
    $10,
    $11,
    $12,
    $13,
    $14,
    $15,
    $16,
    $17,
    $18,
    $19,
    $20,
    $21,
    $22,
    $23,
    $24,
    $25,
    $26,
    $27,
    $28,
    $29,
    $30,
    now()
  )
  ON CONFLICT (externalId)
  DO NOTHING
`;

const momentFieldValue = function (moment, key) {
  const body = moment.fields.find(function (f) {
    return f.name == key;
  });

  return body.value.value;
};

const momentPlayFieldValue = function (moment, key) {
  const fields = moment.fields[2].value.value;
  const body = fields.find(function (f) {
    return f.key.value == key;
  });

  const value = body.value.value;
  if (value !== "N/A") {
    return body.value.value;
  }
};

const insert = async function (moment) {
  const params = [
    momentFieldValue(moment, "id"), // externalId
    momentFieldValue(moment, "serialNumber"), // serialNumber
    momentFieldValue(moment, "price"), // price
    momentPlayFieldValue(moment, "FullName"), // playerFullName
    momentPlayFieldValue(moment, "FirstName"), // playerFirstName
    momentPlayFieldValue(moment, "LastName"), // playerLastName
    momentPlayFieldValue(moment, "Birthdate"), // playerBirthdate
    momentPlayFieldValue(moment, "Birthplace"), // playerBirthplace
    momentPlayFieldValue(moment, "JerseyNumber"), // playerJerseyNumber
    momentPlayFieldValue(moment, "DraftTeam"), // playerDraftTeam
    momentPlayFieldValue(moment, "DraftYear"), // playerDraftYear
    momentPlayFieldValue(moment, "DraftSelection"), // playerDraftSelection
    momentPlayFieldValue(moment, "DraftRound"), // playerDraftRound
    momentPlayFieldValue(moment, "TeamAtMomentNBAID"), // playerTeamAtMomentNBAID
    momentPlayFieldValue(moment, "TeamAtMoment"), // playerTeamAtMomentName
    momentPlayFieldValue(moment, "PrimaryPosition"), // playerPrimaryPosition
    momentPlayFieldValue(moment, "PlayerPosition"), // playerPosition
    momentPlayFieldValue(moment, "Height"), // playerHeightInches
    momentPlayFieldValue(moment, "Weight"), // playerWeightPounds
    momentPlayFieldValue(moment, "TotalYearsExperience"), // playerYearsExperience
    momentPlayFieldValue(moment, "NbaSeason"), // playNbaSeason
    new Date(momentPlayFieldValue(moment, "DateOfMoment")), // playDate
    momentPlayFieldValue(moment, "PlayCategory"), // playCategory
    momentPlayFieldValue(moment, "PlayType"), // playType
    momentPlayFieldValue(moment, "HomeTeamName"), // playHomeTeamName
    momentPlayFieldValue(moment, "AwayTeamName"), // playAwayTeamName
    momentPlayFieldValue(moment, "HomeTeamScore"), // playHomeTeamScore
    momentPlayFieldValue(moment, "AwayTeamScore"), // playAwayTeamScore
    momentFieldValue(moment, "setId"), // setId
    momentFieldValue(moment, "setName"), // setName
  ];

  await pool.query(statement, params);

  util.log.info(`✍️  Wrote moment ${momentFieldValue(moment, "id")}.`);
};

module.exports = insert;
