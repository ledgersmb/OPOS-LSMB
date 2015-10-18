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
            stockvolume = new.onhand
      WHERE id = join_rec.product_id;

     UPDATE opos_integration.parts_opos SET being_written = false
      WHERE parts_id = new.id;
  ELSE
     INSERT INTO opos_integration.parts_opos
     VALUES (new.id, new.id::text || new.partnumber, true);

     INSERT INTO products
            (id, 
            code, reference, name, 
            pricesell, pricebuy,stockvolume, category, taxcat)
     VALUES (new.id::text || new.partnumber,
             new.partnumber, new.partnumber, new.description, 
             new.sellprice, new.lastcost, new.onhand, '000', '001');
     
     UPDATE opos_integration.parts_opos SET being_written = false
      WHERE parts_id = new.id;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER sync_opos AFTER INSERT OR UPDATE ON parts
FOR EACH ROW WHEN (new.description IS NOT NULL)
EXECUTE PROCEDURE opos_integration.lsmb_sync_parts();

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
    where customers_id = new.id;

   IF NOT FOUND THEN
      INSERT INTO opos_integration.customer_opos 
             (customers_id, credit_id, being_written)
      values (new.id, true);
   END IF;

   IF join_rec.being_written then
       return new;
   END IF;

   SELECT curr INTO default_curr 
     FROM unnest(setting__get_currencies()) curr LIMIT 1;
   SELECT * INTO eca FROM entity_credit_account WHERE id = join_rec.credit_id;
   SELECT * INTO c FROM company WHERE entity_id = eca.entity_id;
   SELECT * INTO cc FROM country
    WHERE name = new.country OR short_name = new.country;

   UPDATE opos_integration.customer_opos SET being_written=true
    WHERE customers_id = new.id;

   SELECT * INTO eca_id
     FROM  eca__save(eca.id, 2, 
                              coalesce (eca.entity_id,
                              (SELECT (company__save(c.id, new.id, 2, new.name,
                                                    new.taxid, eca.entity_id, 
                                                    c.sic_code, cc.id, null, null)).entity_id )),
                              new.name::text, eca.discount, eca.taxincluded, 
                              new.maxdebt::numeric, eca.discount_terms, eca.terms, 
                              new.searchkey::text, eca.business_id, eca.language_code,
                              eca.pricegroup_id, 
                              COALESCE(eca.curr, default_curr), 
                              COALESCE(eca.startdate, now()::date), null, 
                              eca.threshold, 
                              coalesce(eca.ar_ap_account_id, 
                                       (select account_id from account_link
                                         where description = 'AR'
                                      ORDER BY account_id asc limit 1)),
                              eca.cash_account_id, new.name, 
                              eca.taxform_id, eca.discount_account_id
   );

   UPDATE opos_integration.customer_opos 
      SET being_written=false,
          credit_id = eca_id
    WHERE customers_id = new.id;
   RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION opos_integration.lsmb_sync_customers()
RETURNS TRIGGER LANGUAGE PLPGSQL AS
$$
DECLARE join_rec opos_integration.customer_opos;
BEGIN
   SELECT * INTO join_rec 
     FROM opos_integration.customer_opos 
     JOIN entity e ON customers_id = e.control_code
     JOIN entity_credit_account eca ON e.id = eca.entity_id AND eca.id = new.id;

   IF FOUND THEN
      IF join_rec.being_written IS TRUE THEN
           RETURN new;
      END IF;
 
      UPDATE customers
         SET name = e.name,
             searchkey = eca.meta_number,
             taxid = c.tax_id,
             maxdebt = eca.creditlimit
       WHERE id = join_rec.customers_id;
   ELSE 
      INSERT INTO opos_integration.customer_opos
             (customers_id, credit_id, being_written)
      SELECT e.control_code || new.meta_number, new.id, true
        FROM entity e where e.id = new.entity_id;

      INSERT INTO customers
             (id, name, searchkey, taxid, maxdebt)
      SELECT e.control_code || eca.meta_number, e.name, eca.meta_number, 
             c.tax_id, coalesce(eca.creditlimit, 0)
        FROM entity_credit_account eca
        JOIN entity e ON e.id = eca.entity_id AND eca.id = new.id
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

CREATE TABLE opos_integration.invoice_opos (
   id int unique,
   tickets_id text unique,
   being_written bool not null default true
); 

CREATE TABLE opos_integration.batch (
  id int unique
);

CREATE OR REPLACE FUNCTION opos_integration.lsmb_rotate_invoice_batch()
RETURNS trigger LANGUAGE PLPGSQL AS
$$
BEGIN
PERFORM * FROM opos_integration.batch
  WHERE id = new.id;
IF NOT FOUND THEN
    RETURN NEW;
END IF;


DELETE FROM opos_integration.batch WHERE id = new.id;
RETURN new;
END;
$$;

CREATE TRIGGER rotate_opos_batch BEFORE UPDATE ON batch
FOR EACH ROW 
EXECUTE PROCEDURE opos_integration.lsmb_rotate_invoice_batch();

CREATE OR REPLACE FUNCTION opos_integration.opos_sync_invoices()
RETURNS TRIGGER LANGUAGE PLPGSQL AS 
$$
DECLARE join_rec opos_integration.invoice_opos;
        batch_id int;
        default_eca entity_credit_account;
BEGIN
   SELECT * INTO join_rec FROM opos_integration.invoice_opos 
    WHERE tickets_id = new.id;

   IF NOT FOUND THEN
      SELECT max(id) INTO batch_id from opos_integration.batch;
      PERFORM id FROM batch WHERE id = batch_id 
          AND approved_by IS NULL AND locked_by IS NULL;
      IF NOT FOUND THEN
          DELETE FROM opos_integration.batch;
          INSERT INTO opos_integration.batch (id)
          VALUES (batch_create(new.id, 'opos invoice batch', 'ar', now()::date));
          SELECT max(id) INTO batch_id from opos_integration.batch;
      END IF;

      SELECT eca.* INTO default_eca
        FROM entity_credit_account eca
        JOIN opos_integration.customer_opos co ON (co.credit_id = eca.id)
       WHERE co.customers_id = new.customer;
      
      IF NOT FOUND THEN
          SELECT * INTO default_eca
            FROM entity_credit_account 
           WHERE entity_class = 2 AND meta_number = 'opos';
      END IF;
      IF default_eca.id IS NULL THEN
          RAISE EXCEPTION 'CUSTOMER NOT FOUND';
      END IF;

      INSERT INTO opos_integration.invoice_opos
             (id, tickets_id, being_written)
      VALUES (nextval('id')::int, new.id, true);
      INSERT INTO ar (id, entity_credit_account, invnumber, transdate, amount, 
             curr, approved)
      SELECT currval('id')::int, default_eca.id,
             new.ticketid, now(), 0, 
             defaults_get_defaultcurrency(), False;

      INSERT INTO voucher (trans_id, batch_id, batch_class)
      SELECT currval('id')::int, id, 2
        FROM opos_integration.batch;

   END IF;

   RETURN NEW;
END;
$$;

CREATE TRIGGER lsmb_save_ar AFTER INSERT ON tickets 
FOR EACH ROW EXECUTE PROCEDURE opos_integration.opos_sync_invoices();

CREATE OR REPLACE FUNCTION opos_integration.opos_sync_invoice_line()
RETURNS TRIGGER LANGUAGE PLPGSQL AS 
$$
DECLARE join_rec opos_integration.invoice_opos;
BEGIN
   SELECT * INTO join_rec FROM opos_integration.invoice_opos
    WHERE tickets_id = new.ticket;
   IF NOT FOUND THEN
      RAISE EXCEPTION 'Invoice not found';
   END IF;
   PERFORM invoice__add_item_ar(
       join_rec.id, po.parts_id, new.units::numeric, 0::numeric, ''::text, 
       new.price::numeric
   )
    FROM opos_integration.parts_opos po
   WHERE new.product = po.product_id;

   PERFORM invoice__finalize_ar(join_rec.id); -- update totals
   RETURN NEW;
END;
$$;

CREATE TRIGGER opos_sync_ticketlines BEFORE INSERT ON ticketlines
FOR EACH ROW EXECUTE PROCEDURE opos_integration.opos_sync_invoice_line();

-- PAYMENTS

CREATE TABLE opos_integration.payment_batch (
   id int,
   created timestamp
);

CREATE OR REPLACE FUNCTION opos_integration.lsmb_rotate_payment_batch()
RETURNS trigger LANGUAGE PLPGSQL AS
$$
BEGIN
DELETE FROM opos_integration.payment_batch WHERE id = new.id;
RETURN new;
END;
$$;

CREATE TRIGGER rotate_opos_payments BEFORE UPDATE ON batch
FOR EACH ROW 
EXECUTE PROCEDURE opos_integration.lsmb_rotate_payment_batch();

CREATE OR REPLACE FUNCTION opos_integration.opos_payment_to_voucher()
RETURNS TRIGGER LANGUAGE PLPGSQL AS
$$
DECLARE batch_row opos_integration.payment_batch;
        join_rec  opos_integration.invoice_opos;
BEGIN
  SELECT * INTO batch_row FROM opos_integration.payment_batch;
  IF NOT FOUND THEN
     INSERT INTO opos_integration.payment_batch(id, created)
     VALUES (batch_create('opos-' || now()::timestamp::text, 'OPOS invoice batch', 'ar', now()::date), now());
     SELECT * INTO batch_row FROM opos_integration.payment_batch;
  END IF;

  SELECT * FROM invoice_opos where tickets_id  = new.receipt;

  INSERT INTO voucher (batch_id, batch_class, trans_id)
  values (batch_row.id, 3, join_rec.id);

  INSERT INTO acc_trans 
         (approved, trans_id, chart_id, amount, transdate, voucher_id)
  VALUES ('f', join_rec.id, (setting_get('opos_ar')).value, 
         new.total, now()::date, currval('voucher_id_seq')::int),
         ('f',  join_rec.id, (setting_get('opos_cash')).value
         -1 * new.total,  now()::date, currval('voucher_id_seq')::int);
END;
$$;

CREATE TRIGGER opos_sync_payments AFTER INSERT ON payments
FOR EACH ROW EXECUTE PROCEDURE opos_integration.opos_payment_to_voucher();

COMMIT;
