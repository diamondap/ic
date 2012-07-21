-- Create schema for Bureau of Labor Statistics Occupational Employment

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


-- This table maps various codes (area type, occupation group, 
-- industry, etc.) to meaningful names. 
create table if not exists bls_oe_codes
(
		code varchar(20) not null,
		type smallint not null,
		value varchar(255) not null,
		definition text null
);


-- This is the primary data table.

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
		footnote_codes char(1) null,
		number_employed numeric(12,2) not null,
		employment_percent numeric(12,2) not null,
		hourly_mean_wage numeric(12,2) not null,
		annual_mean_wage numeric(12,2) not null,
		wage_percent numeric(12,2) not null,
		hourly_wage_10th_percentile numeric(12,2) not null,
		hourly_wage_25th_percentile numeric(12,2) not null,
		hourly_wage_median numeric(12,2) not null,
		hourly_wage_75th_percentile numeric(12,2) not null,
		hourly_wage_90th_percentile numeric(12,2) not null,
		annual_wage_10th_percentile numeric(12,2) not null,
		annual_wage_25th_percentile numeric(12,2) not null,
		annual_wage_median numeric(12,2) not null,
		annual_wage_75th_percentile numeric(12,2) not null,
		annual_wage_90th_percentile numeric(12,2) not null
);
