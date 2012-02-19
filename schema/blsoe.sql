/*
		Scheme comes from http://developer.dol.gov/DOL-BLS2010-DATASET.htm
		Some column names have been slightly altered. 
		Raw data tables start below.
*/

drop table raw_bls_oe_area;
create table raw_bls_oe_area 
(
		area_code varchar(7) null,
		areatype_code varchar(1) null,
		area_name varchar(100) null
);

drop table raw_bls_oe_area_definitions;
create table raw_bls_oe_area_definitions
(
		fips varchar(10) null,
		state varchar(100) null,
		msa_code varchar(20) null,
		msa_name varchar(255) null,
		aggregate_msa_code varchar(20) null,
		aggregate_msa_name varchar(255) null,
		country_code varchar(20),
		township_code varchar(20),
		country_name varchar(255),
		township_name varchar(255)
);

drop table raw_bls_oe_areatype;
create table raw_bls_oe_areatype
(
		areatype_code varchar(1) null,
		areatype_name varchar(100) null
);

drop table raw_bls_oe_data_current;
create table raw_bls_oe_data_current
(
		series_id varchar(30) null,
		year varchar(4) null,
		period varchar(3) null,
		value varchar(12) null,
		footnote_codes varchar(1) null
);

drop table raw_bls_oe_datatype;
create table raw_bls_oe_datatype
(
		datatype_code varchar(2) null,
		datatype_name varchar(100) null,
		footnote_code varchar(1) null
);

drop table raw_bls_oe_footnote;
create table raw_bls_oe_footnote
(
		footnote_code varchar(1) null,
		footnote_text varchar(250) null
);

drop table raw_bls_oe_industry;
create table raw_bls_oe_industry
(
		industry_code varchar(6) null,
		industry_name varchar(100) null,
		display_level varchar(2) null,
		selectable varchar(1) null,
		sort_sequence varchar(5) null
);

drop table raw_bls_oe_industry_titles;
create table raw_bls_oe_industry_titles
(
		industry_code varchar(6) null,
		industry_title varchar(255) null
);

drop table raw_bls_oe_occugroup;
create table raw_bls_oe_occugroup
(
		occugroup_code varchar(6) null,
		occugroup_name varchar(100) null
);

drop table raw_bls_oe_occupation;
create table raw_bls_oe_occupation
(
		occupation_code varchar(6) null,
		occupation_name varchar(100) null,
		display_level varchar(1) null,
		selectable varchar(1) null,
		sort_sequence varchar(5) null
);

/* Column names in this table differ slightly from online doc. */
drop table raw_bls_oe_occupation_definitions;
create table raw_bls_oe_occupation_definitions
(
		code varchar(10) null,
		title varchar(255) null,
		definition text null
);

drop table raw_bls_oe_release;
create table raw_bls_oe_release
(
		release_date varchar(7) null,
		description varchar(50) null
);

drop table raw_bls_oe_seasonal;
create table raw_bls_oe_seasonal
(
		seasonal varchar(1) null,
		seasonal_text varchar(30) null
);

drop table raw_bls_oe_sector;
create table raw_bls_oe_sector
(
		sector_code varchar(6) null,
		sector_name varchar(100) null
);

drop table raw_bls_oe_series;
create table raw_bls_oe_series
(
		series_id varchar(30) null,
		seasonal varchar(1) null,
		areatype_code varchar(1) null,
		area_code varchar(7) null,
		industry_code varchar(6) null,
		occupation_code varchar(6) null,
		datatype_code varchar(2) null,
		footnote_codes varchar(10) null,
		begin_year varchar(4) null,
		begin_period varchar(3) null,
		end_year varchar(4) null,
		end_period varchar(3) null		
);

drop table raw_bls_oe_statemsa;
create table raw_bls_oe_statemsa
(
		state_code varchar(2) null,
		msa_code varchar(7) null,
		msa_name varchar(100) null
);

/* End of raw tables. Below are tables that come from transformed data. */

drop table bls_oe_autofill;
create table bls_oe_autofill
(
		word varchar(255) not null, 
		type smallint not null, 
		matches_start boolean not null, 
		code varchar(40) not null, 
		value varchar(255) not null
);

drop table bls_oe_types;
create table bls_oe_types
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
drop table bls_oe_codes;
create table bls_oe_codes
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
drop table bls_oe_current;
create table bls_oe_current
(
		/* from raw_bls_oe_series */
		seasonal char(1) not null,
		areatype_code char(1) not null,
		area_code char(7) not null,
		industry_code char(6) not null,
		occupation_code char(6) not null,
		datatype_code char(2) not null,

		/* from raw_bls_oe_data_current */
		year int not null,
		period char(3) not null,
		value numeric(12,2) not null,
		footnote_codes char(1) null
);
