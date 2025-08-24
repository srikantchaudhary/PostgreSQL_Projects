
-- PAN Number Validation using SQL

CREATE TABLE stg_pan_numbers_dataset
(
	pan_number text
);

SELECT * FROM STG_PAN_NUMBERS_DATASET;

-- Identify and handle missing data:
SELECT COUNT(*) FROM STG_PAN_NUMBERS_DATASET WHERE PAN_NUMBER IS NULL;


-- Check for duplicates:
SELECT PAN_NUMBER,COUNT(*) FROM STG_PAN_NUMBERS_DATASET where pan_number is not null GROUP BY PAN_NUMBER HAVING COUNT(*) > 1;


-- Handle leading/trailing spaces:



-- Correct letter case: