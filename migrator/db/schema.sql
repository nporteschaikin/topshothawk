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
    externalid character varying,
    serialnumber character varying,
    price double precision,
    playerfullname character varying,
    playerfirstname character varying,
    playerlastname character varying,
    playerbirthdate date,
    playerbirthplace character varying,
    playerjerseynumber character varying,
    playerdraftteam character varying,
    playerdraftyear bigint,
    playerdraftselection integer,
    playerdraftround integer,
    playerteamatmomentnbaid bigint,
    playerteamatmomentname character varying,
    playerprimaryposition character varying,
    playerposition character varying,
    playerheightinches integer,
    playerweightpounds integer,
    playeryearsexperience integer,
    playnbaseason character varying,
    playgametime timestamp without time zone,
    playcategory character varying,
    playtype character varying,
    playhometeamname character varying,
    playawayteamname character varying,
    playhometeamscore bigint,
    playawayteamscore bigint,
    setid bigint,
    setname character varying,
    createdat timestamp without time zone
);


ALTER TABLE public.moments OWNER TO postgres;

--
-- Name: momentsidseq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.momentsidseq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.momentsidseq OWNER TO postgres;

--
-- Name: momentsidseq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.momentsidseq OWNED BY public.moments.id;


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

ALTER TABLE ONLY public.moments ALTER COLUMN id SET DEFAULT nextval('public.momentsidseq'::regclass);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: indexmomentsonexternalid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX indexmomentsonexternalid ON public.moments USING btree (externalid);


--
-- PostgreSQL database dump complete
--

