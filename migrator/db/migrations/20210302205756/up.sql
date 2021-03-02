DROP TABLE moments;

CREATE TABLE moments (
  id bigint not null,
  external_id character varying,
  serial_number character varying,
  price float,
  player_full_name character varying,
  player_first_name character varying,
  player_last_name character varying,
  player_birthdate date,
  player_birthplace character varying,
  player_jersey_number character varying,
  player_draft_team character varying,
  player_draft_year bigint,
  player_draft_selection integer,
  player_draft_round integer,
  player_team_at_moment_nbaid bigint,
  player_team_at_moment_name character varying,
  player_primary_position character varying,
  player_position character varying,
  player_height_inches integer,
  player_weight_pounds integer,
  player_years_experience integer,
  play_nba_season character varying,
  play_game_time timestamp without time zone,
  play_category character varying,
  play_type character varying,
  play_home_team_name character varying,
  play_away_team_name character varying,
  play_home_team_score bigint,
  play_away_team_score bigint,
  set_id bigint,
  set_name character varying,
  created_at timestamp without time zone
);

CREATE SEQUENCE moments_id_seq
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;

ALTER SEQUENCE moments_id_seq OWNED BY moments.id;
ALTER TABLE ONLY moments ALTER COLUMN id SET DEFAULT nextval('moments_id_seq'::regclass);

CREATE UNIQUE INDEX index_moments_on_external_id ON moments USING btree (external_id);
