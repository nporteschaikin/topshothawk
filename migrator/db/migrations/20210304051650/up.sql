DROP INDEX index_events_on_external_moment_id;
DROP INDEX index_events_on_external_owner_id;
CREATE INDEX index_events_on_external_moment_id ON events USING btree (external_moment_id);
CREATE INDEX index_events_on_external_owner_id ON events USING btree (external_owner_id);
