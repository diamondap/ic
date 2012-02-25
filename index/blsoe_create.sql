/* Create index file for Bureau of Labor Statistics 
   Occupational Employment data */

-- index with varchar_pattern_ops works with 'like' query
CREATE INDEX ix_autofill ON bls_oe_autofill (word varchar_pattern_ops);

CREATE INDEX ix_bls_oe_data_area_code ON bls_oe_data (area_code);
CREATE INDEX ix_bls_oe_data_industry_code ON bls_oe_data (industry_code);
CREATE INDEX ix_bls_oe_data_occupation_code ON bls_oe_data (occupation_code);
CREATE INDEX ix_bls_oe_data_area_and_occupation ON bls_oe_data (area_code, occupation_code);
CREATE INDEX ix_bls_oe_data_area_and_industry ON bls_oe_data (area_code, industry_code);
CREATE INDEX ix_bls_oe_codes ON bls_oe_codes (code, type);
