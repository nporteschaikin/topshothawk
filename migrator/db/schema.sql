--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.8
-- Dumped by pg_dump version 11.10 (Debian 11.10-0+deb10u1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: moments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.moments (
    id bigint NOT NULL,
    external_id character varying,
    serial_number character varying,
    price double precision,
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


ALTER TABLE public.moments OWNER TO postgres;

--
-- Name: moments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.moments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.moments_id_seq OWNER TO postgres;

--
-- Name: moments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.moments_id_seq OWNED BY public.moments.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


ALTER TABLE public.schema_migrations OWNER TO postgres;

--
-- Name: moments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.moments ALTER COLUMN id SET DEFAULT nextval('public.moments_id_seq'::regclass);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: index_moments_on_external_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_moments_on_external_id ON public.moments USING btree (external_id);


--
-- PostgreSQL database dump complete
--

