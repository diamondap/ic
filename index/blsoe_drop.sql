-- Drop index file for Bureau of Labor Statistics 
-- Occupational Employment data 

DROP INDEX IF EXISTS ix_autofill;
DROP INDEX IF EXISTS ix_bls_oe_data_area_code;
DROP INDEX IF EXISTS ix_bls_oe_data_industry_code;
DROP INDEX IF EXISTS ix_bls_oe_data_occupation_code;
DROP INDEX IF EXISTS ix_bls_oe_data_area_and_occupation;
DROP INDEX IF EXISTS ix_bls_oe_data_area_and_industry;
DROP INDEX IF EXISTS ix_bls_oe_codes;
