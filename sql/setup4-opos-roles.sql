BEGIN;

-- have to create similar functions to those in Roles.sql because it may not be
-- loaded yet.

DROP FUNCTION IF EXISTS lsmb_pos__create_role(text);
CREATE OR REPLACE FUNCTION lsmb_pos__create_role(in_role text) RETURNS bool
LANGUAGE PLPGSQL AS
$$
BEGIN
  PERFORM * FROM pg_roles WHERE rolname = lsmb__role(in_role);
  IF FOUND THEN
     RETURN TRUE;
  END IF;

  EXECUTE 'CREATE ROLE ' || quote_ident(lsmb__role(in_role))
  || ' WITH INHERIT NOLOGIN';

  RETURN TRUE;
END;
$$ SECURITY INVOKER; -- intended only to be used for setup scripts

DROP FUNCTION IF EXISTS lsmb_pos__grant_role(text, text);
CREATE OR REPLACE FUNCTION lsmb__grant_role(in_child text, in_parent text)
RETURNS BOOL LANGUAGE PLPGSQL SECURITY INVOKER AS
$$
BEGIN
   EXECUTE 'GRANT ' || quote_ident(lsmb__role(in_parent)) || ' TO '
   || quote_ident(lsmb__role(in_child));
   RETURN TRUE;
END;
$$;

CREATE OR REPLACE FUNCTION lsmb_pos__grant_exec(in_role text, in_func text)
RETURNS BOOL LANGUAGE PLPGSQL SECURITY INVOKER AS
$$
BEGIN
   EXECUTE 'GRANT EXECUTE ON FUNCTION ' || in_func || ' TO '
   || quote_ident(lsmb__role(in_role));
   RETURN TRUE;
END;
$$;

CREATE OR REPLACE FUNCTION lsmb_opos__grant_perms
(in_role text, in_table text, in_perms text) RETURNS BOOL
SECURITY INVOKER
LANGUAGE PLPGSQL AS
$$
BEGIN
   IF upper(in_perms) NOT IN ('ALL', 'INSERT', 'UPDATE', 'SELECT', 'DELETE') THEN
      RAISE EXCEPTION 'Invalid permission';
   END IF;
   EXECUTE 'GRANT ' || in_perms || ' ON ' || quote_ident(in_table)
   || ' TO ' ||  quote_ident(lsmb__role(in_role));

   RETURN TRUE;
END;
$$;

CREATE OR REPLACE FUNCTION quote_ident_array(text[]) returns text[]
language sql as $$
   SELECT array_agg(quote_ident(e))
     FROM unnest($1) e;
$$;


CREATE OR REPLACE FUNCTION lsmb_pos__grant_perms
(in_role text, in_table text, in_perms text, in_cols text[]) RETURNS BOOL
SECURITY INVOKER
LANGUAGE PLPGSQL AS
$$
BEGIN
   IF upper(in_perms) NOT IN ('ALL', 'INSERT', 'UPDATE', 'SELECT', 'DELETE') THEN
      RAISE EXCEPTION 'Invalid permission';
   END IF;
   EXECUTE 'GRANT ' || in_perms
   || '(' || array_to_string(quote_ident_array(in_cols), ', ')
   || ') ON ' || quote_ident(in_table)|| ' TO '
   ||  quote_ident(lsmb__role(in_role));
   RETURN TRUE;
END;
$$;

select lsmb_pos__create_role('pos_user');
SELECT lsmb_pos__grant_perms('pos_user', 'applications', 'ALL');
SELECT lsmb_pos__grant_perms('pos_user', 'attribute', 'ALL');
SELECT lsmb_pos__grant_perms('pos_user', 'attributeinstance', 'ALL');
SELECT lsmb_pos__grant_perms('pos_user', 'attributeuse', 'ALL');
SELECT lsmb_pos__grant_perms('pos_user', 'attributevalue', 'ALL');
SELECT lsmb_pos__grant_perms('pos_user', 'categories', 'ALL');
SELECT lsmb_pos__grant_perms('pos_user', 'closedcash', 'ALL');
SELECT lsmb_pos__grant_perms('pos_user', 'csvimport', 'ALL');
SELECT lsmb_pos__grant_perms('pos_user', 'customers', 'ALL');
SELECT lsmb_pos__grant_perms('pos_user', 'floors', 'ALL');
SELECT lsmb_pos__grant_perms('pos_user', 'leaves', 'ALL');
SELECT lsmb_pos__grant_perms('pos_user', 'lineremoved', 'ALL');
SELECT lsmb_pos__grant_perms('pos_user', 'locations', 'ALL');
SELECT lsmb_pos__grant_perms('pos_user', 'moorers', 'ALL');
SELECT lsmb_pos__grant_perms('pos_user', 'payments', 'ALL');
SELECT lsmb_pos__grant_perms('pos_user', 'people', 'ALL');
SELECT lsmb_pos__grant_perms('pos_user', 'pickup_number', 'ALL');
SELECT lsmb_pos__grant_perms('pos_user', 'places', 'ALL');
SELECT lsmb_pos__grant_perms('pos_user', 'products', 'ALL');
SELECT lsmb_pos__grant_perms('pos_user', 'products_cat', 'ALL');
SELECT lsmb_pos__grant_perms('pos_user', 'products_com', 'ALL');
SELECT lsmb_pos__grant_perms('pos_user', 'receipts', 'ALL');
SELECT lsmb_pos__grant_perms('pos_user', 'reservation_customers', 'ALL');
SELECT lsmb_pos__grant_perms('pos_user', 'reservations', 'ALL');
SELECT lsmb_pos__grant_perms('pos_user', 'resources', 'ALL');
SELECT lsmb_pos__grant_perms('pos_user', 'roles', 'ALL');
SELECT lsmb_pos__grant_perms('pos_user', 'shared_tickets', 'ALL');
SELECT lsmb_pos__grant_perms('pos_user', 'shift_breaks', 'ALL');
SELECT lsmb_pos__grant_perms('pos_user', 'shifts', 'ALL');
SELECT lsmb_pos__grant_perms('pos_user', 'stockcurrent', 'ALL');
SELECT lsmb_pos__grant_perms('pos_user', 'stockdiary', 'ALL');
SELECT lsmb_pos__grant_perms('pos_user', 'stocklevel', 'ALL');
SELECT lsmb_pos__grant_perms('pos_user', 'taxcategories', 'ALL');
SELECT lsmb_pos__grant_perms('pos_user', 'taxcustcategories', 'ALL');
SELECT lsmb_pos__grant_perms('pos_user', 'taxes', 'ALL');
SELECT lsmb_pos__grant_perms('pos_user', 'taxlines', 'ALL');
SELECT lsmb_pos__grant_perms('pos_user', 'thirdparties', 'ALL');
SELECT lsmb_pos__grant_perms('pos_user', 'ticketlines', 'ALL');
SELECT lsmb_pos__grant_perms('pos_user', 'tickets', 'ALL');
SELECT lsmb_pos__grant_perms('pos_user', 'ticketsnum', 'ALL');
SELECT lsmb_pos__grant_perms('pos_user', 'ticketsnum_payment', 'ALL');
SELECT lsmb_pos__grant_perms('pos_user', 'ticketsnum_refund', 'ALL');

COMMIT;
