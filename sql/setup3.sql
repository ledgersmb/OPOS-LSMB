-- Copyright Efficito, Ltd.
-- Licensed under the GNU General Public License version 2 or at your option
-- any later version.  Please see the included licenses/gpl2.txt for more 
-- information.

BEGIN;

CREATE SCHEMA opos_integration;

CREATE TABLE opos_integration.parts_opos (
   parts_id int UNIQUE,
   product_id text UNIQUE,
   being_written bool not null default true
);

CREATE OR REPLACE FUNCTION opos_integration.opos_sync_parts() RETURNS TRIGGER
LANGUAGE PLPGSQL AS
$$
DECLARE
  join_rec opos_integration.parts_opos;
BEGIN
  SELECT * INTO join_rec FROM opos_integration.parts_opos 
   WHERE product_id = new.id;

  IF NOT FOUND THEN
     INSERT INTO opos_integration.parts_opos
     VALUES (nextval('parts_id_seq'), new.id, true);

     INSERT INTO parts 
            (id, partnumber, description, 
            inventory_accno_id, expense_accno_id, income_accno_id,
            sellprice, lastcost, onhand)
     VALUES (currval('parts_id_seq'), new.code, new.name,
             (setting_get('inventory_accno_id')).value::int,
             (setting_get('expense_accno_id')).value::int,
             (setting_get('income_accno_id')).value::int,
             new.pricesell, new.pricebuy, new.stockvolume);

     UPDATE opos_integration.parts_opos SET being_written = false WHERE product_id = new.id;
  ELSE
     IF join_rec.being_written IS TRUE THEN
         return new;
     END IF;

     UPDATE opos_integration.parts_opos SET being_written = true WHERE product_id = new.id;
     UPDATE parts 
        SET partnumber = new.code,
            description = new.name,
            sellprice = new.pricesell,
            onhand = new.stocklevel
      WHERE id = join_rec.parts_id;

     UPDATE opos_integration.parts_opos SET being_written = false WHERE product_id = new.id;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER sync_lsmb AFTER INSERT OR UPDATE ON products
FOR EACH ROW EXECUTE PROCEDURE opos_integration.opos_sync_parts();

CREATE OR REPLACE FUNCTION opos_integration.lsmb_sync_parts() RETURNS TRIGGER
LANGUAGE PLPGSQL AS
$$
DECLARE
  join_rec opos_integration.parts_opos;
BEGIN
  SELECT * INTO join_rec FROM opos_integration.parts_opos 
   WHERE parts_id = new.id;

  IF FOUND THEN
     IF join_rec.being_written IS TRUE THEN
         return new;
     END IF;
     UPDATE opos_integration.parts_opos SET being_written = true
      WHERE parts_id = new.id;

     UPDATE products
        SET name = new.description,
            pricesell = new.sellprice,
            stocklevel = new.onhand
      WHERE id = join_rec.products_id;

     UPDATE opos_integration.parts_opos SET being_written = false
      WHERE parts_id = new.id;
  ELSE
     INSERT INTO opos_integration.parts_opos
     VALUES (new.id, new.id::text || new.partnumber, true);

     INSERT INTO product
            (id, 
            code, reference, name, 
            pricesell, pricebuy, onhand)
     VALUES (new.id, new.id::text || new.partnumber,
             new.partnumber, new.partnumber, new.description, 
             new.sellprice, new.lastcost, new.onhand);
     
     UPDATE opos_integration.parts_opos SET being_written = false
      WHERE parts_id = new.id;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER sync_opos AFTER INSERT OR UPDATE ON parts
FOR EACH ROW EXECUTE PROCEDURE opos_integration.lsmb_sync_parts();

COMMIT;
