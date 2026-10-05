-- Regression coverage for the array null-bitmap walk in
-- convert_pgarray2poly()/read_from_array() (q3c.c). Nothing previously
-- exercised this path: every existing test builds polygon arrays with no
-- NULL elements at all, so a bitmap-pointer type or width bug here could
-- pass the whole suite while silently misreading coordinates.
--
-- q3c_in_poly(ra, dec, double precision[]) is the simplest entry point
-- into convert_pgarray2poly(), which walks the array's ARR_NULLBITMAP one
-- bit per element via read_from_array().

CREATE EXTENSION IF NOT EXISTS q3c;

-- Control: an otherwise-identical 5-vertex polygon with no NULLs succeeds,
-- so the ERROR cases below are attributable to the NULL, not the shape.
SELECT q3c_in_poly(15, 15, ARRAY[10,10, 20,10, 20,20, 10,20, 15,25]::double precision[]);

-- NULL inside the first null-bitmap byte (element 6 of 6, bit 5).
SELECT q3c_in_poly(15, 15, ARRAY[10,10, 20,10, 20,NULL]::double precision[]);

-- NULL that lands just after the null-bitmap byte boundary (element 10 of
-- 10, bit 1 of the *second* bitmap byte): exercises the bitmap++/bitmask
-- reset in read_from_array() once the first 8 elements are consumed.
SELECT q3c_in_poly(15, 15, ARRAY[10,10, 20,10, 20,20, 10,20, 15,NULL]::double precision[]);

-- NULL further into the second bitmap byte (element 12 of 12, bit 3),
-- with non-null elements on both sides of the byte boundary.
SELECT q3c_in_poly(15, 15, ARRAY[10,10, 20,10, 20,20, 10,20, 15,25, 12,NULL]::double precision[]);
