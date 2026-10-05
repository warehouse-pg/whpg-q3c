\echo Use "CREATE EXTENSION q3c" to load this file. \quit

-- make functions parallel safe

CREATE OR REPLACE FUNCTION q3c_ang2ipix(double precision, double precision)
        RETURNS bigint
        AS 'MODULE_PATHNAME', 'pgq3c_ang2ipix'
        LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION q3c_ang2ipix(ra real, decl real)
        RETURNS bigint
        AS 'MODULE_PATHNAME', 'pgq3c_ang2ipix_real'
        LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION q3c_ipix2ang(ipix bigint)
        RETURNS double precision[]
        AS 'MODULE_PATHNAME', 'pgq3c_ipix2ang'
        LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION q3c_pixarea(ipix bigint, depth int)
        RETURNS double precision
        AS 'MODULE_PATHNAME', 'pgq3c_pixarea'
        LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION q3c_dist(ra1 double precision, dec1 double precision,
									ra2 double precision, dec2 double precision)
        RETURNS double precision
        AS 'MODULE_PATHNAME', 'pgq3c_dist'
        LANGUAGE C IMMUTABLE STRICT; 

CREATE OR REPLACE FUNCTION q3c_sindist(double precision, double precision,
                                       double precision, double precision)
        RETURNS double precision
        AS 'MODULE_PATHNAME', 'pgq3c_sindist'
        LANGUAGE C IMMUTABLE STRICT COST 100;

CREATE OR REPLACE FUNCTION q3c_sindist_pm(
       ra1 double precision, dec1 double precision,
       pmra1 double precision, pmdec1 double precision,
       cosdec_flag integer,
       epoch1 double precision, ra2 double precision, dec2 double precision,
       epoch2 double precision)
        RETURNS double precision
        AS 'MODULE_PATHNAME', 'pgq3c_sindist_pm'
        LANGUAGE C IMMUTABLE COST 100;

CREATE OR REPLACE FUNCTION q3c_dist_pm(
       ra1 double precision, dec1 double precision,
       pmra1 double precision, pmdec1 double precision,
       cosdec_flag int,
       epoch1 double precision, ra2 double precision, dec2 double precision,
       epoch2 double precision)
        RETURNS double precision
        AS 'MODULE_PATHNAME', 'pgq3c_dist_pm'
        LANGUAGE C IMMUTABLE COST 100;

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
        EXECUTE 'ALTER FUNCTION q3c_ang2ipix(double precision, double precision) PARALLEL SAFE';
        EXECUTE 'ALTER FUNCTION q3c_ang2ipix(ra real, decl real) PARALLEL SAFE';
        EXECUTE 'ALTER FUNCTION q3c_ipix2ang(ipix bigint) PARALLEL SAFE';
        EXECUTE 'ALTER FUNCTION q3c_pixarea(ipix bigint, depth int) PARALLEL SAFE';
        EXECUTE 'ALTER FUNCTION q3c_dist(ra1 double precision, dec1 double precision, ra2 double precision, dec2 double precision) PARALLEL SAFE';
        EXECUTE 'ALTER FUNCTION q3c_sindist(double precision, double precision, double precision, double precision) PARALLEL SAFE';
        EXECUTE 'ALTER FUNCTION q3c_sindist_pm(ra1 double precision, dec1 double precision, pmra1 double precision, pmdec1 double precision, cosdec_flag integer, epoch1 double precision, ra2 double precision, dec2 double precision, epoch2 double precision) PARALLEL SAFE';
        EXECUTE 'ALTER FUNCTION q3c_dist_pm(ra1 double precision, dec1 double precision, pmra1 double precision, pmdec1 double precision, cosdec_flag int, epoch1 double precision, ra2 double precision, dec2 double precision, epoch2 double precision) PARALLEL SAFE';
    END IF;
END
$$;
