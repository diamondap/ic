/* Create schema for Bureau of Labor Statistics Occupational Employment */

create table if not exists bls_oe_autofill
(
		word varchar(255) not null, 
		type smallint not null, 
		matches_start boolean not null, 
		code varchar(40) not null, 
		value varchar(255) not null
);

create table if not exists bls_oe_types
(
		code smallint primary key,
		name varchar(30) not null
);

insert into bls_oe_types (code, name) values (1, 'Area');
insert into bls_oe_types (code, name) values (2, 'Industry');
insert into bls_oe_types (code, name) values (3, 'Sector');
insert into bls_oe_types (code, name) values (4, 'Occupation Group');
insert into bls_oe_types (code, name) values (5, 'Occupation');
insert into bls_oe_types (code, name) values (6, 'Area FIPS');
insert into bls_oe_types (code, name) values (7, 'Area Type');
insert into bls_oe_types (code, name) values (8, 'Data Type');
insert into bls_oe_types (code, name) values (9, 'Footnote');
insert into bls_oe_types (code, name) values (10, 'Seasonal');
insert into bls_oe_types (code, name) values (11, 'State');


/* This table maps various codes (area type, occupation group, 
   industry, etc.) to meaningful names. */
create table if not exists bls_oe_codes
(
		code varchar(20) not null,
		type smallint not null,
		value varchar(255) not null,
		definition text null
);

/* create unique index ix_bls_oe_codes on bls_oe_codes (code, type); */


/*
	This is the primary data table.
	We build several indexes on this table AFTER running transformations!

	We build indexes after populating the table so that we don't slow
	down the data import process. Defining indexes before inserting 
	causes the db to have to update the index every time we do an insert.
	That's a lot of overhead when we're doing 5,000,000+ inserts.

	Should index area_code, area_type_code, industry_code, occupation_code.
	No need for index or primary key on series_id, because we will not be
	searching on that field.
*/
create table if not exists bls_oe_current
(
		seasonal char(1) not null,
		areatype_code char(1) not null,
		area_code char(7) not null,
		industry_code char(6) not null,
		occupation_code char(6) not null,
		datatype_code char(2) not null,
		year int not null,
		period char(3) not null,
		value numeric(12,2) not null,
		footnote_codes char(1) null
);
