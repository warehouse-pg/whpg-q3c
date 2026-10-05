CREATE OR REPLACE FUNCTION q3c_nearby_it(double precision, double precision, 
					 double precision, integer)
        RETURNS bigint
        AS 'MODULE_PATHNAME', 'pgq3c_nearby_it'
        LANGUAGE C IMMUTABLE STRICT COST 100;

CREATE OR REPLACE FUNCTION q3c_nearby_pm_it(
       ra1 double precision, dec1 double precision, 
       pmra1 double precision, pmdec1 double precision,
       cosdec_flag int,
       maxepoch_delta double precision, rad double precision, flag integer)
        RETURNS bigint
        AS 'MODULE_PATHNAME', 'pgq3c_nearby_pm_it'
        LANGUAGE C IMMUTABLE COST 100; 
-- Importantly this is NOT as strict function because we accept nulls as pms

CREATE OR REPLACE FUNCTION q3c_ellipse_nearby_it(double precision, double precision, 
		double precision, double precision, double precision, integer)
        RETURNS bigint
        AS 'MODULE_PATHNAME', 'pgq3c_ellipse_nearby_it'
        LANGUAGE C IMMUTABLE STRICT COST 100;

-- PARALLEL {SAFE|RESTRICTED} requires PG >= 9.6 (WHPG7/WHPG19); WHPG6
-- (PG9.4) does not have the grammar for it at all, not even as a
-- no-op, so it cannot appear in the CREATE FUNCTION statements above
-- unconditionally. Unlike a bare statement in a DO block (which
-- PL/pgSQL parses at compile time regardless of which branch runs,
-- and so would still fail on 9.4), EXECUTE takes a runtime string
-- that is only parsed if this branch actually executes -- verified
-- directly against a real PG 9.4 server.
DO $$
BEGIN
    IF current_setting('server_version_num')::int >= 90600 THEN
        EXECUTE 'ALTER FUNCTION q3c_nearby_it(double precision, double precision, double precision, integer) PARALLEL SAFE';
        EXECUTE 'ALTER FUNCTION q3c_nearby_pm_it(ra1 double precision, dec1 double precision, pmra1 double precision, pmdec1 double precision, cosdec_flag int, maxepoch_delta double precision, rad double precision, flag integer) PARALLEL SAFE';
        EXECUTE 'ALTER FUNCTION q3c_ellipse_nearby_it(double precision, double precision, double precision, double precision, double precision, integer) PARALLEL SAFE';
    END IF;
END
$$;
