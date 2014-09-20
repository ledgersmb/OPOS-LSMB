-- From the Unicenta OPOS project.
-- Licensed under the GNU General Public License version 3
-- See the licenses/gpl3.txt included

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: applications; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE applications (
    id character varying NOT NULL,
    name character varying NOT NULL,
    version character varying NOT NULL
);


ALTER TABLE public.applications OWNER TO chris;

--
-- Name: attribute; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE attribute (
    id character varying NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.attribute OWNER TO chris;

--
-- Name: attributeinstance; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE attributeinstance (
    id character varying NOT NULL,
    attributesetinstance_id character varying NOT NULL,
    attribute_id character varying NOT NULL,
    value character varying
);


ALTER TABLE public.attributeinstance OWNER TO chris;

--
-- Name: attributeset; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE attributeset (
    id character varying NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.attributeset OWNER TO chris;

--
-- Name: attributesetinstance; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE attributesetinstance (
    id character varying NOT NULL,
    attributeset_id character varying NOT NULL,
    description character varying
);


ALTER TABLE public.attributesetinstance OWNER TO chris;

--
-- Name: attributeuse; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE attributeuse (
    id character varying NOT NULL,
    attributeset_id character varying NOT NULL,
    attribute_id character varying NOT NULL,
    lineno integer
);


ALTER TABLE public.attributeuse OWNER TO chris;

--
-- Name: attributevalue; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE attributevalue (
    id character varying NOT NULL,
    attribute_id character varying NOT NULL,
    value character varying
);


ALTER TABLE public.attributevalue OWNER TO chris;

--
-- Name: breaks; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE breaks (
    id character varying NOT NULL,
    name character varying NOT NULL,
    notes character varying,
    visible boolean NOT NULL
);


ALTER TABLE public.breaks OWNER TO chris;

--
-- Name: categories; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE categories (
    id character varying NOT NULL,
    name character varying NOT NULL,
    parentid character varying,
    image bytea,
    texttip character varying,
    catshowname boolean DEFAULT true NOT NULL
);


ALTER TABLE public.categories OWNER TO chris;

--
-- Name: closedcash; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE closedcash (
    money character varying NOT NULL,
    host character varying NOT NULL,
    hostsequence integer NOT NULL,
    datestart timestamp without time zone NOT NULL,
    dateend timestamp without time zone,
    nosales integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.closedcash OWNER TO chris;

--
-- Name: csvimport; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE csvimport (
    id character varying NOT NULL,
    rownumber character varying,
    csverror character varying,
    reference character varying,
    code character varying,
    name character varying,
    pricebuy double precision,
    pricesell double precision,
    previousbuy double precision,
    previoussell double precision,
    category character varying
);


ALTER TABLE public.csvimport OWNER TO chris;

--
-- Name: customers; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE customers (
    id character varying NOT NULL,
    searchkey character varying NOT NULL,
    taxid character varying,
    name character varying NOT NULL,
    taxcategory character varying,
    card character varying,
    maxdebt double precision DEFAULT 0 NOT NULL,
    address character varying,
    address2 character varying,
    postal character varying,
    city character varying,
    region character varying,
    country character varying,
    firstname character varying,
    lastname character varying,
    email character varying,
    phone character varying,
    phone2 character varying,
    fax character varying,
    notes character varying,
    visible boolean DEFAULT true NOT NULL,
    curdate timestamp without time zone,
    curdebt double precision DEFAULT 0,
    image bytea
);


ALTER TABLE public.customers OWNER TO chris;

--
-- Name: draweropened; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE draweropened (
    opendate timestamp without time zone DEFAULT now(),
    name character varying,
    ticketid character varying
);


ALTER TABLE public.draweropened OWNER TO chris;

--
-- Name: floors; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE floors (
    id character varying NOT NULL,
    name character varying NOT NULL,
    image bytea
);


ALTER TABLE public.floors OWNER TO chris;

--
-- Name: leaves; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE leaves (
    id character varying NOT NULL,
    pplid character varying NOT NULL,
    name character varying NOT NULL,
    startdate timestamp without time zone NOT NULL,
    enddate timestamp without time zone NOT NULL,
    notes character varying
);


ALTER TABLE public.leaves OWNER TO chris;

--
-- Name: lineremoved; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE lineremoved (
    removeddate timestamp without time zone DEFAULT now() NOT NULL,
    name character varying,
    ticketid character varying,
    productid character varying,
    productname character varying,
    units double precision NOT NULL
);


ALTER TABLE public.lineremoved OWNER TO chris;

--
-- Name: locations; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE locations (
    id character varying NOT NULL,
    name character varying NOT NULL,
    address character varying
);


ALTER TABLE public.locations OWNER TO chris;

--
-- Name: moorers; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE moorers (
    vesselname character varying,
    size integer,
    days integer,
    power boolean DEFAULT false NOT NULL
);


ALTER TABLE public.moorers OWNER TO chris;

--
-- Name: payments; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE payments (
    id character varying NOT NULL,
    receipt character varying NOT NULL,
    payment character varying NOT NULL,
    total double precision NOT NULL,
    transid character varying,
    notes character varying,
    returnmsg bytea,
    tendered double precision DEFAULT 0 NOT NULL,
    cardname character varying
);


ALTER TABLE public.payments OWNER TO chris;

--
-- Name: people; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE people (
    id character varying NOT NULL,
    name character varying NOT NULL,
    apppassword character varying,
    card character varying,
    role character varying NOT NULL,
    visible boolean NOT NULL,
    image bytea
);


ALTER TABLE public.people OWNER TO chris;

--
-- Name: pickup_number; Type: SEQUENCE; Schema: public; Owner: chris
--

CREATE SEQUENCE pickup_number
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pickup_number OWNER TO chris;

--
-- Name: places; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE places (
    id character varying NOT NULL,
    name character varying NOT NULL,
    x integer NOT NULL,
    y integer NOT NULL,
    floor character varying NOT NULL,
    customer character varying,
    waiter character varying,
    ticketid character varying,
    tablemoved boolean DEFAULT false NOT NULL
);


ALTER TABLE public.places OWNER TO chris;

--
-- Name: products; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE products (
    id character varying NOT NULL,
    reference character varying NOT NULL,
    code character varying NOT NULL,
    codetype character varying,
    name character varying NOT NULL,
    pricebuy double precision DEFAULT 0 NOT NULL,
    pricesell double precision DEFAULT 0 NOT NULL,
    category character varying NOT NULL,
    taxcat character varying NOT NULL,
    attributeset_id character varying,
    stockcost double precision,
    stockvolume double precision,
    image bytea,
    iscom boolean DEFAULT false NOT NULL,
    isscale boolean DEFAULT false NOT NULL,
    iskitchen boolean DEFAULT false NOT NULL,
    printkb boolean DEFAULT false NOT NULL,
    sendstatus boolean DEFAULT false NOT NULL,
    isservice boolean DEFAULT false NOT NULL,
    display character varying,
    attributes bytea,
    isvprice boolean DEFAULT false NOT NULL,
    isverpatrib boolean DEFAULT false NOT NULL,
    texttip character varying DEFAULT ''::character varying,
    warranty boolean DEFAULT false NOT NULL
);


ALTER TABLE public.products OWNER TO chris;

--
-- Name: products_cat; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE products_cat (
    product character varying NOT NULL,
    catorder integer
);


ALTER TABLE public.products_cat OWNER TO chris;

--
-- Name: products_com; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE products_com (
    id character varying NOT NULL,
    product character varying NOT NULL,
    product2 character varying NOT NULL
);


ALTER TABLE public.products_com OWNER TO chris;

--
-- Name: receipts; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE receipts (
    id character varying NOT NULL,
    money character varying NOT NULL,
    datenew timestamp without time zone NOT NULL,
    attributes bytea,
    person character varying
);


ALTER TABLE public.receipts OWNER TO chris;

--
-- Name: reservation_customers; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE reservation_customers (
    id character varying NOT NULL,
    customer character varying NOT NULL
);


ALTER TABLE public.reservation_customers OWNER TO chris;

--
-- Name: reservations; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE reservations (
    id character varying NOT NULL,
    created timestamp without time zone NOT NULL,
    datenew timestamp without time zone DEFAULT '2013-01-01 00:00:00'::timestamp without time zone NOT NULL,
    title character varying NOT NULL,
    chairs integer NOT NULL,
    isdone boolean NOT NULL,
    description character varying
);


ALTER TABLE public.reservations OWNER TO chris;

--
-- Name: resources; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE resources (
    id character varying NOT NULL,
    name character varying NOT NULL,
    restype integer NOT NULL,
    content bytea
);


ALTER TABLE public.resources OWNER TO chris;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE roles (
    id character varying NOT NULL,
    name character varying NOT NULL,
    permissions bytea
);


ALTER TABLE public.roles OWNER TO chris;

--
-- Name: sharedtickets; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE sharedtickets (
    id character varying NOT NULL,
    name character varying NOT NULL,
    content bytea,
    pickupid integer DEFAULT 0 NOT NULL,
    appuser character varying
);


ALTER TABLE public.sharedtickets OWNER TO chris;

--
-- Name: shift_breaks; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE shift_breaks (
    id character varying NOT NULL,
    shiftid character varying NOT NULL,
    breakid character varying NOT NULL,
    starttime timestamp without time zone NOT NULL,
    endtime timestamp without time zone
);


ALTER TABLE public.shift_breaks OWNER TO chris;

--
-- Name: shifts; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE shifts (
    id character varying NOT NULL,
    startshift timestamp without time zone NOT NULL,
    endshift timestamp without time zone,
    pplid character varying NOT NULL
);


ALTER TABLE public.shifts OWNER TO chris;

--
-- Name: stockcurrent; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE stockcurrent (
    location character varying NOT NULL,
    product character varying NOT NULL,
    attributesetinstance_id character varying,
    units double precision DEFAULT 0 NOT NULL
);


ALTER TABLE public.stockcurrent OWNER TO chris;

--
-- Name: stockdiary; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE stockdiary (
    id character varying NOT NULL,
    datenew timestamp without time zone NOT NULL,
    reason integer NOT NULL,
    location character varying NOT NULL,
    product character varying NOT NULL,
    attributesetinstance_id character varying,
    units double precision NOT NULL,
    price double precision NOT NULL,
    appuser character varying
);


ALTER TABLE public.stockdiary OWNER TO chris;

--
-- Name: stocklevel; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE stocklevel (
    id character varying NOT NULL,
    location character varying NOT NULL,
    product character varying NOT NULL,
    stocksecurity double precision DEFAULT 0 NOT NULL,
    stockmaximum double precision DEFAULT 0 NOT NULL
);


ALTER TABLE public.stocklevel OWNER TO chris;

--
-- Name: taxcategories; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE taxcategories (
    id character varying NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.taxcategories OWNER TO chris;

--
-- Name: taxcustcategories; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE taxcustcategories (
    id character varying NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.taxcustcategories OWNER TO chris;

--
-- Name: taxes; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE taxes (
    id character varying NOT NULL,
    name character varying NOT NULL,
    category character varying NOT NULL,
    custcategory character varying,
    parentid character varying,
    rate double precision DEFAULT 0 NOT NULL,
    ratecascade boolean DEFAULT false NOT NULL,
    rateorder integer
);


ALTER TABLE public.taxes OWNER TO chris;

--
-- Name: taxlines; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE taxlines (
    id character varying NOT NULL,
    receipt character varying NOT NULL,
    taxid character varying NOT NULL,
    base double precision DEFAULT 0 NOT NULL,
    amount double precision DEFAULT 0 NOT NULL
);


ALTER TABLE public.taxlines OWNER TO chris;

--
-- Name: thirdparties; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE thirdparties (
    id character varying NOT NULL,
    cif character varying NOT NULL,
    name character varying NOT NULL,
    address character varying,
    contactcomm character varying,
    contactfact character varying,
    payrule character varying,
    faxnumber character varying,
    phonenumber character varying,
    mobilenumber character varying,
    email character varying,
    webpage character varying,
    notes character varying
);


ALTER TABLE public.thirdparties OWNER TO chris;

--
-- Name: ticketlines; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE ticketlines (
    ticket character varying NOT NULL,
    line integer NOT NULL,
    product character varying,
    attributesetinstance_id character varying,
    units double precision NOT NULL,
    price double precision NOT NULL,
    taxid character varying NOT NULL,
    attributes bytea
);


ALTER TABLE public.ticketlines OWNER TO chris;

--
-- Name: tickets; Type: TABLE; Schema: public; Owner: chris; Tablespace: 
--

CREATE TABLE tickets (
    id character varying NOT NULL,
    tickettype integer DEFAULT 0 NOT NULL,
    ticketid integer NOT NULL,
    person character varying NOT NULL,
    customer character varying,
    status integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.tickets OWNER TO chris;

--
-- Name: ticketsnum; Type: SEQUENCE; Schema: public; Owner: chris
--

CREATE SEQUENCE ticketsnum
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ticketsnum OWNER TO chris;

--
-- Name: ticketsnum_payment; Type: SEQUENCE; Schema: public; Owner: chris
--

CREATE SEQUENCE ticketsnum_payment
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ticketsnum_payment OWNER TO chris;

--
-- Name: ticketsnum_refund; Type: SEQUENCE; Schema: public; Owner: chris
--

CREATE SEQUENCE ticketsnum_refund
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ticketsnum_refund OWNER TO chris;

--
-- Name: applications_pkey; Type: CONSTRAINT; Schema: public; Owner: chris; Tablespace: 
--

ALTER TABLE ONLY applications
    ADD CONSTRAINT applications_pkey PRIMARY KEY (id);


--
-- Name: attribute_pkey; Type: CONSTRAINT; Schema: public; Owner: chris; Tablespace: 
--

ALTER TABLE ONLY attribute
    ADD CONSTRAINT attribute_pkey PRIMARY KEY (id);


--
-- Name: attributeinstance_pkey; Type: CONSTRAINT; Schema: public; Owner: chris; Tablespace: 
--

ALTER TABLE ONLY attributeinstance
    ADD CONSTRAINT attributeinstance_pkey PRIMARY KEY (id);


--
-- Name: attributeset_pkey; Type: CONSTRAINT; Schema: public; Owner: chris; Tablespace: 
--

ALTER TABLE ONLY attributeset
    ADD CONSTRAINT attributeset_pkey PRIMARY KEY (id);


--
-- Name: attributesetinstance_pkey; Type: CONSTRAINT; Schema: public; Owner: chris; Tablespace: 
--

ALTER TABLE ONLY attributesetinstance
    ADD CONSTRAINT attributesetinstance_pkey PRIMARY KEY (id);


--
-- Name: attributeuse_pkey; Type: CONSTRAINT; Schema: public; Owner: chris; Tablespace: 
--

ALTER TABLE ONLY attributeuse
    ADD CONSTRAINT attributeuse_pkey PRIMARY KEY (id);


--
-- Name: attributevalue_pkey; Type: CONSTRAINT; Schema: public; Owner: chris; Tablespace: 
--

ALTER TABLE ONLY attributevalue
    ADD CONSTRAINT attributevalue_pkey PRIMARY KEY (id);


--
-- Name: breaks_pkey; Type: CONSTRAINT; Schema: public; Owner: chris; Tablespace: 
--

ALTER TABLE ONLY breaks
    ADD CONSTRAINT breaks_pkey PRIMARY KEY (id);


--
-- Name: categories_pkey; Type: CONSTRAINT; Schema: public; Owner: chris; Tablespace: 
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: closedcash_pkey; Type: CONSTRAINT; Schema: public; Owner: chris; Tablespace: 
--

ALTER TABLE ONLY closedcash
    ADD CONSTRAINT closedcash_pkey PRIMARY KEY (money);


--
-- Name: csvimport_pkey; Type: CONSTRAINT; Schema: public; Owner: chris; Tablespace: 
--

ALTER TABLE ONLY csvimport
    ADD CONSTRAINT csvimport_pkey PRIMARY KEY (id);


--
-- Name: customers_pkey; Type: CONSTRAINT; Schema: public; Owner: chris; Tablespace: 
--

ALTER TABLE ONLY customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: floors_pkey; Type: CONSTRAINT; Schema: public; Owner: chris; Tablespace: 
--

ALTER TABLE ONLY floors
    ADD CONSTRAINT floors_pkey PRIMARY KEY (id);


--
-- Name: leaves_pkey; Type: CONSTRAINT; Schema: public; Owner: chris; Tablespace: 
--

ALTER TABLE ONLY leaves
    ADD CONSTRAINT leaves_pkey PRIMARY KEY (id);


--
-- Name: locations_pkey; Type: CONSTRAINT; Schema: public; Owner: chris; Tablespace: 
--

ALTER TABLE ONLY locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);


--
-- Name: payments_pkey; Type: CONSTRAINT; Schema: public; Owner: chris; Tablespace: 
--

ALTER TABLE ONLY payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: people_pkey; Type: CONSTRAINT; Schema: public; Owner: chris; Tablespace: 
--

ALTER TABLE ONLY people
    ADD CONSTRAINT people_pkey PRIMARY KEY (id);


--
-- Name: places_pkey; Type: CONSTRAINT; Schema: public; Owner: chris; Tablespace: 
--

ALTER TABLE ONLY places
    ADD CONSTRAINT places_pkey PRIMARY KEY (id);


--
-- Name: products_cat_pkey; Type: CONSTRAINT; Schema: public; Owner: chris; Tablespace: 
--

ALTER TABLE ONLY products_cat
    ADD CONSTRAINT products_cat_pkey PRIMARY KEY (product);


--
-- Name: products_com_pkey; Type: CONSTRAINT; Schema: public; Owner: chris; Tablespace: 
--

ALTER TABLE ONLY products_com
    ADD CONSTRAINT products_com_pkey PRIMARY KEY (id);


--
-- Name: products_pkey; Type: CONSTRAINT; Schema: public; Owner: chris; Tablespace: 
--

ALTER TABLE ONLY products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: receipts_pkey; Type: CONSTRAINT; Schema: public; Owner: chris; Tablespace: 
--

ALTER TABLE ONLY receipts
    ADD CONSTRAINT receipts_pkey PRIMARY KEY (id);


--
-- Name: reservation_customers_pkey; Type: CONSTRAINT; Schema: public; Owner: chris; Tablespace: 
--

ALTER TABLE ONLY reservation_customers
    ADD CONSTRAINT reservation_customers_pkey PRIMARY KEY (id);


--
-- Name: reservations_pkey; Type: CONSTRAINT; Schema: public; Owner: chris; Tablespace: 
--

ALTER TABLE ONLY reservations
    ADD CONSTRAINT reservations_pkey PRIMARY KEY (id);


--
-- Name: resources_pkey; Type: CONSTRAINT; Schema: public; Owner: chris; Tablespace: 
--

ALTER TABLE ONLY resources
    ADD CONSTRAINT resources_pkey PRIMARY KEY (id);


--
-- Name: roles_pkey; Type: CONSTRAINT; Schema: public; Owner: chris; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: sharedtickets_pkey; Type: CONSTRAINT; Schema: public; Owner: chris; Tablespace: 
--

ALTER TABLE ONLY sharedtickets
    ADD CONSTRAINT sharedtickets_pkey PRIMARY KEY (id);


--
-- Name: shift_breaks_pkey; Type: CONSTRAINT; Schema: public; Owner: chris; Tablespace: 
--

ALTER TABLE ONLY shift_breaks
    ADD CONSTRAINT shift_breaks_pkey PRIMARY KEY (id);


--
-- Name: shifts_pkey; Type: CONSTRAINT; Schema: public; Owner: chris; Tablespace: 
--

ALTER TABLE ONLY shifts
    ADD CONSTRAINT shifts_pkey PRIMARY KEY (id);


--
-- Name: stockdiary_pkey; Type: CONSTRAINT; Schema: public; Owner: chris; Tablespace: 
--

ALTER TABLE ONLY stockdiary
    ADD CONSTRAINT stockdiary_pkey PRIMARY KEY (id);


--
-- Name: stocklevel_pkey; Type: CONSTRAINT; Schema: public; Owner: chris; Tablespace: 
--

ALTER TABLE ONLY stocklevel
    ADD CONSTRAINT stocklevel_pkey PRIMARY KEY (id);


--
-- Name: taxcategories_pkey; Type: CONSTRAINT; Schema: public; Owner: chris; Tablespace: 
--

ALTER TABLE ONLY taxcategories
    ADD CONSTRAINT taxcategories_pkey PRIMARY KEY (id);


--
-- Name: taxcustcategories_pkey; Type: CONSTRAINT; Schema: public; Owner: chris; Tablespace: 
--

ALTER TABLE ONLY taxcustcategories
    ADD CONSTRAINT taxcustcategories_pkey PRIMARY KEY (id);


--
-- Name: taxes_pkey; Type: CONSTRAINT; Schema: public; Owner: chris; Tablespace: 
--

ALTER TABLE ONLY taxes
    ADD CONSTRAINT taxes_pkey PRIMARY KEY (id);


--
-- Name: taxlines_pkey; Type: CONSTRAINT; Schema: public; Owner: chris; Tablespace: 
--

ALTER TABLE ONLY taxlines
    ADD CONSTRAINT taxlines_pkey PRIMARY KEY (id);


--
-- Name: thirdparties_pkey; Type: CONSTRAINT; Schema: public; Owner: chris; Tablespace: 
--

ALTER TABLE ONLY thirdparties
    ADD CONSTRAINT thirdparties_pkey PRIMARY KEY (id);


--
-- Name: ticketlines_pkey; Type: CONSTRAINT; Schema: public; Owner: chris; Tablespace: 
--

ALTER TABLE ONLY ticketlines
    ADD CONSTRAINT ticketlines_pkey PRIMARY KEY (ticket, line);


--
-- Name: tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: chris; Tablespace: 
--

ALTER TABLE ONLY tickets
    ADD CONSTRAINT tickets_pkey PRIMARY KEY (id);


--
-- Name: attuse_line; Type: INDEX; Schema: public; Owner: chris; Tablespace: 
--

CREATE UNIQUE INDEX attuse_line ON attributeuse USING btree (attributeset_id, lineno);


--
-- Name: categories_name_inx; Type: INDEX; Schema: public; Owner: chris; Tablespace: 
--

CREATE UNIQUE INDEX categories_name_inx ON categories USING btree (name);


--
-- Name: closedcash_inx_1; Type: INDEX; Schema: public; Owner: chris; Tablespace: 
--

CREATE INDEX closedcash_inx_1 ON closedcash USING btree (datestart);


--
-- Name: closedcash_inx_seq; Type: INDEX; Schema: public; Owner: chris; Tablespace: 
--

CREATE UNIQUE INDEX closedcash_inx_seq ON closedcash USING btree (host, hostsequence);


--
-- Name: customers_card_inx; Type: INDEX; Schema: public; Owner: chris; Tablespace: 
--

CREATE INDEX customers_card_inx ON customers USING btree (card);


--
-- Name: customers_name_inx; Type: INDEX; Schema: public; Owner: chris; Tablespace: 
--

CREATE INDEX customers_name_inx ON customers USING btree (name);


--
-- Name: customers_skey_inx; Type: INDEX; Schema: public; Owner: chris; Tablespace: 
--

CREATE UNIQUE INDEX customers_skey_inx ON customers USING btree (searchkey);


--
-- Name: customers_taxid_inx; Type: INDEX; Schema: public; Owner: chris; Tablespace: 
--

CREATE INDEX customers_taxid_inx ON customers USING btree (taxid);


--
-- Name: floors_name_inx; Type: INDEX; Schema: public; Owner: chris; Tablespace: 
--

CREATE UNIQUE INDEX floors_name_inx ON floors USING btree (name);


--
-- Name: locations_name_inx; Type: INDEX; Schema: public; Owner: chris; Tablespace: 
--

CREATE UNIQUE INDEX locations_name_inx ON locations USING btree (name);


--
-- Name: payments_inx_1; Type: INDEX; Schema: public; Owner: chris; Tablespace: 
--

CREATE INDEX payments_inx_1 ON payments USING btree (payment);


--
-- Name: pcom_inx_prod; Type: INDEX; Schema: public; Owner: chris; Tablespace: 
--

CREATE UNIQUE INDEX pcom_inx_prod ON products_com USING btree (product, product2);


--
-- Name: people_card_inx; Type: INDEX; Schema: public; Owner: chris; Tablespace: 
--

CREATE INDEX people_card_inx ON people USING btree (card);


--
-- Name: people_name_inx; Type: INDEX; Schema: public; Owner: chris; Tablespace: 
--

CREATE UNIQUE INDEX people_name_inx ON people USING btree (name);


--
-- Name: places_name_inx; Type: INDEX; Schema: public; Owner: chris; Tablespace: 
--

CREATE UNIQUE INDEX places_name_inx ON places USING btree (name);


--
-- Name: products_cat_inx_1; Type: INDEX; Schema: public; Owner: chris; Tablespace: 
--

CREATE INDEX products_cat_inx_1 ON products_cat USING btree (catorder);


--
-- Name: products_inx_0; Type: INDEX; Schema: public; Owner: chris; Tablespace: 
--

CREATE UNIQUE INDEX products_inx_0 ON products USING btree (reference);


--
-- Name: products_inx_1; Type: INDEX; Schema: public; Owner: chris; Tablespace: 
--

CREATE UNIQUE INDEX products_inx_1 ON products USING btree (code);


--
-- Name: products_name_inx; Type: INDEX; Schema: public; Owner: chris; Tablespace: 
--

CREATE UNIQUE INDEX products_name_inx ON products USING btree (name);


--
-- Name: receipts_inx_1; Type: INDEX; Schema: public; Owner: chris; Tablespace: 
--

CREATE INDEX receipts_inx_1 ON receipts USING btree (datenew);


--
-- Name: reservations_inx_1; Type: INDEX; Schema: public; Owner: chris; Tablespace: 
--

CREATE INDEX reservations_inx_1 ON reservations USING btree (datenew);


--
-- Name: resources_name_inx; Type: INDEX; Schema: public; Owner: chris; Tablespace: 
--

CREATE UNIQUE INDEX resources_name_inx ON resources USING btree (name);


--
-- Name: roles_name_inx; Type: INDEX; Schema: public; Owner: chris; Tablespace: 
--

CREATE UNIQUE INDEX roles_name_inx ON roles USING btree (name);


--
-- Name: stockcurrent_inx; Type: INDEX; Schema: public; Owner: chris; Tablespace: 
--

CREATE UNIQUE INDEX stockcurrent_inx ON stockcurrent USING btree (location, product, attributesetinstance_id);


--
-- Name: stockdiary_inx_1; Type: INDEX; Schema: public; Owner: chris; Tablespace: 
--

CREATE INDEX stockdiary_inx_1 ON stockdiary USING btree (datenew);


--
-- Name: taxcat_name_inx; Type: INDEX; Schema: public; Owner: chris; Tablespace: 
--

CREATE UNIQUE INDEX taxcat_name_inx ON taxcategories USING btree (name);


--
-- Name: taxcustcat_name_inx; Type: INDEX; Schema: public; Owner: chris; Tablespace: 
--

CREATE UNIQUE INDEX taxcustcat_name_inx ON taxcustcategories USING btree (name);


--
-- Name: taxes_name_inx; Type: INDEX; Schema: public; Owner: chris; Tablespace: 
--

CREATE UNIQUE INDEX taxes_name_inx ON taxes USING btree (name);


--
-- Name: thirdparties_cif_inx; Type: INDEX; Schema: public; Owner: chris; Tablespace: 
--

CREATE UNIQUE INDEX thirdparties_cif_inx ON thirdparties USING btree (cif);


--
-- Name: thirdparties_name_inx; Type: INDEX; Schema: public; Owner: chris; Tablespace: 
--

CREATE UNIQUE INDEX thirdparties_name_inx ON thirdparties USING btree (name);


--
-- Name: tickets_ticketid; Type: INDEX; Schema: public; Owner: chris; Tablespace: 
--

CREATE INDEX tickets_ticketid ON tickets USING btree (tickettype, ticketid);


--
-- Name: attinst_att; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY attributeinstance
    ADD CONSTRAINT attinst_att FOREIGN KEY (attribute_id) REFERENCES attribute(id);


--
-- Name: attinst_set; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY attributeinstance
    ADD CONSTRAINT attinst_set FOREIGN KEY (attributesetinstance_id) REFERENCES attributesetinstance(id) ON DELETE CASCADE;


--
-- Name: attsetinst_set; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY attributesetinstance
    ADD CONSTRAINT attsetinst_set FOREIGN KEY (attributeset_id) REFERENCES attributeset(id) ON DELETE CASCADE;


--
-- Name: attuse_att; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY attributeuse
    ADD CONSTRAINT attuse_att FOREIGN KEY (attribute_id) REFERENCES attribute(id);


--
-- Name: attuse_set; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY attributeuse
    ADD CONSTRAINT attuse_set FOREIGN KEY (attributeset_id) REFERENCES attributeset(id) ON DELETE CASCADE;


--
-- Name: attval_att; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY attributevalue
    ADD CONSTRAINT attval_att FOREIGN KEY (attribute_id) REFERENCES attribute(id) ON DELETE CASCADE;


--
-- Name: categories_fk_1; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_fk_1 FOREIGN KEY (parentid) REFERENCES categories(id);


--
-- Name: customers_taxcat; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY customers
    ADD CONSTRAINT customers_taxcat FOREIGN KEY (taxcategory) REFERENCES taxcustcategories(id);


--
-- Name: leaves_pplid; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY leaves
    ADD CONSTRAINT leaves_pplid FOREIGN KEY (pplid) REFERENCES people(id);


--
-- Name: payments_fk_receipt; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY payments
    ADD CONSTRAINT payments_fk_receipt FOREIGN KEY (receipt) REFERENCES receipts(id);


--
-- Name: people_fk_1; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY people
    ADD CONSTRAINT people_fk_1 FOREIGN KEY (role) REFERENCES roles(id);


--
-- Name: places_fk_1; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY places
    ADD CONSTRAINT places_fk_1 FOREIGN KEY (floor) REFERENCES floors(id);


--
-- Name: products_attrset_fk; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY products
    ADD CONSTRAINT products_attrset_fk FOREIGN KEY (attributeset_id) REFERENCES attributeset(id);


--
-- Name: products_cat_fk_1; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY products_cat
    ADD CONSTRAINT products_cat_fk_1 FOREIGN KEY (product) REFERENCES products(id);


--
-- Name: products_com_fk_1; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY products_com
    ADD CONSTRAINT products_com_fk_1 FOREIGN KEY (product) REFERENCES products(id);


--
-- Name: products_com_fk_2; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY products_com
    ADD CONSTRAINT products_com_fk_2 FOREIGN KEY (product2) REFERENCES products(id);


--
-- Name: products_fk_1; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY products
    ADD CONSTRAINT products_fk_1 FOREIGN KEY (category) REFERENCES categories(id);


--
-- Name: products_taxcat_fk; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY products
    ADD CONSTRAINT products_taxcat_fk FOREIGN KEY (taxcat) REFERENCES taxcategories(id);


--
-- Name: receipts_fk_money; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY receipts
    ADD CONSTRAINT receipts_fk_money FOREIGN KEY (money) REFERENCES closedcash(money);


--
-- Name: res_cust_fk_1; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY reservation_customers
    ADD CONSTRAINT res_cust_fk_1 FOREIGN KEY (id) REFERENCES reservations(id);


--
-- Name: res_cust_fk_2; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY reservation_customers
    ADD CONSTRAINT res_cust_fk_2 FOREIGN KEY (customer) REFERENCES customers(id);


--
-- Name: shift_breaks_breakid; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY shift_breaks
    ADD CONSTRAINT shift_breaks_breakid FOREIGN KEY (breakid) REFERENCES breaks(id);


--
-- Name: shift_breaks_shiftid; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY shift_breaks
    ADD CONSTRAINT shift_breaks_shiftid FOREIGN KEY (shiftid) REFERENCES shifts(id);


--
-- Name: stockcurrent_attsetinst; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY stockcurrent
    ADD CONSTRAINT stockcurrent_attsetinst FOREIGN KEY (attributesetinstance_id) REFERENCES attributesetinstance(id);


--
-- Name: stockcurrent_fk_1; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY stockcurrent
    ADD CONSTRAINT stockcurrent_fk_1 FOREIGN KEY (product) REFERENCES products(id);


--
-- Name: stockcurrent_fk_2; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY stockcurrent
    ADD CONSTRAINT stockcurrent_fk_2 FOREIGN KEY (location) REFERENCES locations(id);


--
-- Name: stockdiary_attsetinst; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY stockdiary
    ADD CONSTRAINT stockdiary_attsetinst FOREIGN KEY (attributesetinstance_id) REFERENCES attributesetinstance(id);


--
-- Name: stockdiary_fk_1; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY stockdiary
    ADD CONSTRAINT stockdiary_fk_1 FOREIGN KEY (product) REFERENCES products(id);


--
-- Name: stockdiary_fk_2; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY stockdiary
    ADD CONSTRAINT stockdiary_fk_2 FOREIGN KEY (location) REFERENCES locations(id);


--
-- Name: stocklevel_location; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY stocklevel
    ADD CONSTRAINT stocklevel_location FOREIGN KEY (location) REFERENCES locations(id);


--
-- Name: stocklevel_product; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY stocklevel
    ADD CONSTRAINT stocklevel_product FOREIGN KEY (product) REFERENCES products(id);


--
-- Name: taxes_cat_fk; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY taxes
    ADD CONSTRAINT taxes_cat_fk FOREIGN KEY (category) REFERENCES taxcategories(id);


--
-- Name: taxes_custcat_fk; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY taxes
    ADD CONSTRAINT taxes_custcat_fk FOREIGN KEY (custcategory) REFERENCES taxcustcategories(id);


--
-- Name: taxes_taxes_fk; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY taxes
    ADD CONSTRAINT taxes_taxes_fk FOREIGN KEY (parentid) REFERENCES taxes(id);


--
-- Name: taxlines_receipt; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY taxlines
    ADD CONSTRAINT taxlines_receipt FOREIGN KEY (receipt) REFERENCES receipts(id);


--
-- Name: taxlines_tax; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY taxlines
    ADD CONSTRAINT taxlines_tax FOREIGN KEY (taxid) REFERENCES taxes(id);


--
-- Name: ticketlines_attsetinst; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY ticketlines
    ADD CONSTRAINT ticketlines_attsetinst FOREIGN KEY (attributesetinstance_id) REFERENCES attributesetinstance(id);


--
-- Name: ticketlines_fk_2; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY ticketlines
    ADD CONSTRAINT ticketlines_fk_2 FOREIGN KEY (product) REFERENCES products(id);


--
-- Name: ticketlines_fk_3; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY ticketlines
    ADD CONSTRAINT ticketlines_fk_3 FOREIGN KEY (taxid) REFERENCES taxes(id);


--
-- Name: ticketlines_fk_ticket; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY ticketlines
    ADD CONSTRAINT ticketlines_fk_ticket FOREIGN KEY (ticket) REFERENCES tickets(id);


--
-- Name: tickets_customers_fk; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY tickets
    ADD CONSTRAINT tickets_customers_fk FOREIGN KEY (customer) REFERENCES customers(id);


--
-- Name: tickets_fk_2; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY tickets
    ADD CONSTRAINT tickets_fk_2 FOREIGN KEY (person) REFERENCES people(id);


--
-- Name: tickets_fk_id; Type: FK CONSTRAINT; Schema: public; Owner: chris
--

ALTER TABLE ONLY tickets
    ADD CONSTRAINT tickets_fk_id FOREIGN KEY (id) REFERENCES receipts(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

