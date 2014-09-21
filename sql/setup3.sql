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

CREATE TABLE opos_integration.customer_opos (
   credit_id int unique,
   customers_id text unique,
   being_written bool not null default true
); 

-- PRODUCTS

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

-- CUSTOMERS

CREATE OR REPLACE FUNCTION opos_integration.opos_sync_customers()
RETURNS TRIGGER LANGUAGE PLPGSQL AS
$$
DECLARE 
    join_rec opos_integration.customer_opos;
    eca entity_credit_account;
    c company;
    cc country;
    default_curr text;
    eca_id int;
BEGIN
   SELECT * INTO join_rec FROM opos_integration.customer_opos 
    where customer_id = new.id;

   IF NOT FOUND THEN
      INSERT INTO opos_integration.customer_opos 
             (customers_id, being_written)
      values (new.id, true);
   END IF;

   IF join_rec.being_written then
       return new;
   END IF;

   SELECT c INTO default_curr FROM unnest(setting__get_currencies()) c LIMIT 1;
   SELECT * INTO eca WHERE id = join_rec.credit_id;
   SELECT * INTO c WHERE entity = eca.entity_id;
   SELECT * INTO cc WHERE name = new.country OR short_name = new.country;

   UPDATE opos_integration.customer_opos SET being_written=true
    WHERE customer_id = new.id;

   SELECT * INTO eca_id
     FROM  entity__save_credit(eca.id, 2, 
                              coalesce (eca.entity_id,
                              (SELECT company__save(c.id, new.id, 2, new.name,
                                                    new.taxid, eca.entity_id, 
                                                    c.sic, cc.id, null, null))),
                              new.name, eca.discount, eca.taxincluded, 
                              new.maxdebt, eca.discount_terms, eca.terms, 
                              new.searchkey, eca.business_id, eca.language_code,
                              eca.pricegroup_id, 
                              COALESCE(eca.curr, default_curr), 
                              COALESCE(eca.start_date, now()::date), null, 
                              eca.threshold, 
                              coalesce(eca.ar_ap_accno_id, 
                                       (select account_id from account_link
                                         where description = 'AR'
                                      ORDER BY account_id asc limit 1)),
                              eca.cash_account_id, new.name, 
                              eca.tax_form_id, eca.discount_account_id
   );

   UPDATE opos_integration.customer_opos 
      SET being_written=false,
          credit_id = eca_id
    WHERE customer_id = new.id;
   RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION opos_integration.lsmb_sync_customers()
RETURNS TRIGGER LANGUAGE PLPGSQL AS
$$
DECLARE join_rec opos_integration.customer_opos;
BEGIN
   SELECT * INTO join_rec FROM opos_integration.customer_opos 
    WHERE credit_id = new.id;

   IF FOUND THEN
      IF join_rec.being_written IS TRUE THEN
           RETURN new;
      END IF;
 
      UPDATE customers
         SET name = e.name,
             search_key = eca.meta_number,
             taxid = c.tax_id,
             maxdebt = eca.creditlimit
       WHERE id = join_rec.customers_id;
   ELSE 
      INSERT INTO customers
             (name, search_key, taxid, maxdebt)
      SELECT e.name, eca.meta_number, c.tax_id, eca.creditimit
        FROM entity_credit_account eca
        JOIN entity e ON e.id = eca.credit_id
   LEFT JOIN company c ON c.entity_id = eca.entity_id;
   END IF;

   UPDATE opos_integration.customer_opos
      SET being_written = false
    WHERE credit_id = new.id;
   RETURN new;
END;
$$;

CREATE TRIGGER sync_opos AFTER INSERT OR UPDATE ON customers
FOR EACH ROW EXECUTE PROCEDURE opos_integration.opos_sync_customers();

CREATE TRIGGER sync_opos AFTER INSERT OR UPDATE ON entity_credit_account
FOR EACH ROW 
WHEN (new.entity_class = 2)
EXECUTE PROCEDURE opos_integration.lsmb_sync_customers();

-- INVOICES

-- PAYMENTS

COMMIT;
