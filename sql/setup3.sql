BEGIN;

CREATE SCHEMA opos_integration;

CREATE TABLE opos_integration.parts_opos (
   parts_id int UNIQUE,
   product_id text UNIQUE,
   being_written bool not null default true
);

CREATE OR REPLACE FUNCTION opos_integration.opos_sync_parts() RETURNS TRIGGER
LANUAGE PLPGSQL AS
$$
DECLARE
  join_rec parts_opos;
BEGIN
  SELECT * INTO join_rec FROM parts_opos WHERE product_id = new.id;
  IF NOT FOUND THEN
     INSERT INTO parts ....
     (...);

     UPDATE parts_opos SET being_written = false WHERE product_id = new.id;
  ELSE
     IF join_rec.being_written IS TRUE THEN
         return new;
     END IF;
     UPDATE parts_opos SET being_written = true WHERE product_id = new.id;
     UPDATE parts ....;

     UPDATE parts_opos SET being_written = false WHERE product_id = new.id;
$$;

CREATE TRIGGER sync_lsmb AFTER INSERT TO products
FOR EACH ROW EXECUTE PROCEDURE opos_integration.opos_sync_parts();


COMMIT;
