DROP TABLE moments;

CREATE TABLE moments (
  id bigint NOT NULL,
  externalId character varying,
  serialNumber character varying,
  price float,
  playerFullName character varying,
  playerFirstName character varying,
  playerLastName character varying,
  playerBirthdate date,
  playerBirthplace character varying,
  playerJerseyNumber character varying,
  playerDraftTeam character varying,
  playerDraftYear bigint,
  playerDraftSelection integer,
  playerDraftRound integer,
  playerTeamAtMomentNBAID bigint,
  playerTeamAtMomentName character varying,
  playerPrimaryPosition character varying,
  playerPosition character varying,
  playerHeightInches integer,
  playerWeightPounds integer,
  playerYearsExperience integer,
  playNbaSeason character varying,
  playGameTime timestamp without time zone,
  playCategory character varying,
  playType character varying,
  playHomeTeamName character varying,
  playAwayTeamName character varying,
  playHomeTeamScore bigint,
  playAwayTeamScore bigint,
  setId bigint,
  setName character varying,
  createdAt timestamp without time zone
);

CREATE SEQUENCE momentsIdSeq
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;

ALTER SEQUENCE momentsIdSeq OWNED BY moments.id;
ALTER TABLE ONLY moments ALTER COLUMN id SET DEFAULT nextval('momentsIdSeq'::regclass);

CREATE UNIQUE INDEX indexMomentsOnExternalId ON moments USING btree (externalId);
