CREATE TABLE events (
  id bigint not null,
  type character varying not null,
  external_block_id character varying not null,
  external_transaction_id character varying not null,
  external_moment_id character varying not null,
  external_owner_id character varying not null,
  created_at timestamp without time zone not null
);

CREATE SEQUENCE events_id_seq
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;

ALTER SEQUENCE events_id_seq OWNED BY events.id;
ALTER TABLE ONLY events ALTER COLUMN id SET DEFAULT nextval('events_id_seq'::regclass);

CREATE UNIQUE INDEX index_events_on_external_transaction_id ON events USING btree (external_transaction_id);
CREATE UNIQUE INDEX index_events_on_external_moment_id ON events USING btree (external_moment_id);
CREATE UNIQUE INDEX index_events_on_external_owner_id ON events USING btree (external_owner_id);

ALTER TABLE moments ADD COLUMN last_external_transaction_id character varying;
CREATE UNIQUE INDEX index_moments_on_last_external_transaction_id ON moments USING btree (last_external_transaction_id);
