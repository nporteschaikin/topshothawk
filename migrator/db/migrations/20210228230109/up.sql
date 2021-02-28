CREATE TABLE moments (
  id bigint NOT NULL
);

CREATE SEQUENCE moments_id_seq
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;

ALTER SEQUENCE moments_id_seq OWNED BY moments.id;
