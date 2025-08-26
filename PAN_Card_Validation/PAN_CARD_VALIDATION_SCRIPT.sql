
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

SELECT * FROM STG_PAN_NUMBERS_DATASET WHERE PAN_NUMBER LIKE '% %';

-- OR

SELECT * FROM STG_PAN_NUMBERS_DATASET WHERE PAN_NUMBER <> TRIM(PAN_NUMBER);

-- Correct letter case:

SELECT * FROM STG_PAN_NUMBERS_DATASET WHERE PAN_NUMBER <> UPPER(PAN_NUMBER);




-- Cleaned PAN Numbers:

SELECT DISTINCT UPPER(TRIM(PAN_NUMBER)) AS PAN_NUMBER 
FROM STG_PAN_NUMBERS_DATASET 
WHERE PAN_NUMBER IS NOT NULL 
AND TRIM(PAN_NUMBER) <> '';



-- Function to check if adjacent characters are the same

CREATE OR REPLACE FUNCTION FN_CHECK_ADJACENT_CHARACTERS(p_str text)
RETURNS BOOLEAN 
as $$
BEGIN
	for i in 1 .. (length(p_str) - 1)
	loop
		if substring(p_str,i,1) = substring(p_str,i+1,1)
		then 
			return true; -- the characters are adjacent
		end if;
	end loop;
	return false;  -- non of the character adjacent to each other were the same
END;
$$
language plpgsql;


-- SELECT FN_CHECK_ADJACENT_CHARACTERS('JJCHK')


-- FUNCTION To Check if Sequencial Characters are used

CREATE OR REPLACE FUNCTION fn_check_sequencial_characters(p_str text) 
RETURNS boolean 
as $$
begin
	for i in 1 .. (length(p_str) -1)
	loop
		if ascii(substring(p_str,i+1,1)) - ascii(substring(p_str,i,1)) <> 1
		then return false;  -- String does not form the sequence
		end if;
	end loop;
	return true;  -- The String is forming a Sequence
END;
$$
LANGUAGE PLPGSQL;



SELECT fn_check_sequencial_characters('ABBDE')





-- Regular expression to validate the pattern or structure of PAN Numbers


SELECT * FROM STG_PAN_NUMBERS_DATASET WHERE PAN_NUMBER ~ '^[A-Z]{5}[0-9]{4}[A-Z]$';



SELECT * 
FROM STG_PAN_NUMBERS_DATASET 
WHERE SUBSTRING(PAN_NUMBER,1,1) NOT IN ('A','B','C','F','G','H','J','L','P','T');



--  Valid and Invalid PAN categorization


with cte_cleaned_pan as 
	 (SELECT DISTINCT UPPER(TRIM(PAN_NUMBER)) AS PAN_NUMBER 
	   	FROM STG_PAN_NUMBERS_DATASET 
		WHERE PAN_NUMBER IS NOT NULL 
		AND TRIM(PAN_NUMBER) <> ''),
	 cte_valid_pans as 
	 (select * from cte_cleaned_pan
		where FN_CHECK_ADJACENT_CHARACTERS(pan_number) = false
		AND fn_check_sequencial_characters(SUBSTRING(PAN_NUMBER,1,5)) = FALSE
		AND fn_check_sequencial_characters(SUBSTRING(PAN_NUMBER,6,4)) = FALSE
		AND PAN_NUMBER ~ '^[A-Z]{5}[0-9]{4}[A-Z]$')
select cln.pan_number,
case when vld.pan_number is not null then 'Valid PAN' 
else 'Invalid PAN' 
end as status
from cte_cleaned_pan cln left join cte_valid_pans vld on vld.pan_number = cln.pan_number








create or replace view vw_valid_invalid_pans as 
with cte_cleaned_pan as 
	 (SELECT DISTINCT UPPER(TRIM(PAN_NUMBER)) AS PAN_NUMBER 
	   	FROM STG_PAN_NUMBERS_DATASET 
		WHERE PAN_NUMBER IS NOT NULL 
		AND TRIM(PAN_NUMBER) <> ''),
	 cte_valid_pans as 
	 (select * from cte_cleaned_pan
		where FN_CHECK_ADJACENT_CHARACTERS(pan_number) = false
		AND fn_check_sequencial_characters(SUBSTRING(PAN_NUMBER,1,5)) = FALSE
		AND fn_check_sequencial_characters(SUBSTRING(PAN_NUMBER,6,4)) = FALSE
		AND PAN_NUMBER ~ '^[A-Z]{5}[0-9]{4}[A-Z]$')
select cln.pan_number,
case when vld.pan_number is not null then 'Valid PAN' 
else 'Invalid PAN' 
end as status
from cte_cleaned_pan cln left join cte_valid_pans vld on vld.pan_number = cln.pan_number




-- Summary Report

select status, count(*) from vw_valid_invalid_pans group by status;


with cte as 
	(select 
	   (select count(*) from stg_pan_numbers_dataset) as total_processed_records,
	   count(*) filter (where status = 'Valid PAN') as total_valid_pan,
       count(*) filter (where status = 'Invalid PAN') as total_invalid_pan
	 from vw_valid_invalid_pans)
select 
total_processed_records,
total_valid_pan,
total_invalid_pan,
(total_processed_records - total_valid_pan - total_invalid_pan) as Total_missing_or_incomplete_PANs
from cte;