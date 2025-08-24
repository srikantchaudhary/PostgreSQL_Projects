# PAN Card Validation Project

## Overview
This project is designed to **validate PAN (Permanent Account Number) records** in a dataset using **PostgreSQL**. It handles data cleaning, duplicate detection, format validation, and checks for adjacent and sequential characters to categorize PANs as **Valid** or **Invalid**.

---

## Table of Contents
1. [Project Structure](#project-structure)  
2. [Database Table](#database-table)  
3. [Data Cleaning](#data-cleaning)  
4. [Validation Functions](#validation-functions)  
5. [PAN Validation Logic](#pan-validation-logic)  
6. [Views](#views)  
7. [Summary Reports](#summary-reports)  
8. [Usage](#usage)  
9. [Future Enhancements](#future-enhancements)

---

## Project Structure
- `stg_pan_numbers_dataset` - staging table containing raw PAN numbers  
- `fn_check_adjacent_characters` - function to check if adjacent characters are the same  
- `fn_check_sequencial_characters` - function to check if characters form a sequence  
- `vw_valid_invalid_pans` - view to categorize PANs as valid or invalid  

---

## Database Table

```sql
CREATE TABLE stg_pan_numbers_dataset (
    pan_number TEXT
);
```

### Sample Query

```sql
SELECT * FROM STG_PAN_NUMBERS_DATASET;
```

---

## Data Cleaning

1. **Identify Missing Data**
```sql
SELECT COUNT(*)
FROM STG_PAN_NUMBERS_DATASET
WHERE PAN_NUMBER IS NULL;
```

2. **Check Duplicates**
```sql
SELECT PAN_NUMBER, COUNT(*)
FROM STG_PAN_NUMBERS_DATASET
WHERE PAN_NUMBER IS NOT NULL
GROUP BY PAN_NUMBER
HAVING COUNT(*) > 1;
```

3. **Handle Leading/Trailing Spaces**
```sql
SELECT *
FROM STG_PAN_NUMBERS_DATASET
WHERE PAN_NUMBER <> TRIM(PAN_NUMBER);
```

4. **Correct Letter Case**
```sql
SELECT *
FROM STG_PAN_NUMBERS_DATASET
WHERE PAN_NUMBER <> UPPER(PAN_NUMBER);
```

5. **Cleaned PAN Numbers**
```sql
SELECT DISTINCT UPPER(TRIM(PAN_NUMBER)) AS PAN_NUMBER
FROM STG_PAN_NUMBERS_DATASET
WHERE PAN_NUMBER IS NOT NULL AND TRIM(PAN_NUMBER) <> '';
```

---

## Validation Functions

### 1. Check Adjacent Characters
```sql
CREATE OR REPLACE FUNCTION FN_CHECK_ADJACENT_CHARACTERS(p_str text)
RETURNS BOOLEAN AS $$
BEGIN
    FOR i IN 1 .. (length(p_str) - 1) LOOP
        IF substring(p_str,i,1) = substring(p_str,i+1,1) THEN
            RETURN TRUE; -- Adjacent characters are same
        END IF;
    END LOOP;
    RETURN FALSE; -- No adjacent characters found
END;
$$ LANGUAGE plpgsql;
```

### 2. Check Sequential Characters
```sql
CREATE OR REPLACE FUNCTION fn_check_sequencial_characters(p_str text)
RETURNS BOOLEAN AS $$
BEGIN
    FOR i IN 1 .. (length(p_str) - 1) LOOP
        IF ascii(substring(p_str,i+1,1)) - ascii(substring(p_str,i,1)) <> 1 THEN
            RETURN FALSE; -- String does not form sequence
        END IF;
    END LOOP;
    RETURN TRUE; -- String forms sequence
END;
$$ LANGUAGE plpgsql;
```

---

## PAN Validation Logic

- Valid PAN format: **5 letters + 4 digits + 1 letter**  
  Regex: `^[A-Z]{5}[0-9]{4}[A-Z]$`
- Checks performed:
  - No **adjacent repeated characters**
  - No **sequential letters in first 5 letters**
  - No **sequential digits in next 4 numbers**
  - Matches the **PAN regex pattern**

### Query for Valid/Invalid PANs
```sql
WITH cte_cleaned_pan AS (
    SELECT DISTINCT UPPER(TRIM(PAN_NUMBER)) AS PAN_NUMBER
    FROM STG_PAN_NUMBERS_DATASET
    WHERE PAN_NUMBER IS NOT NULL AND TRIM(PAN_NUMBER) <> ''
),
cte_valid_pans AS (
    SELECT *
    FROM cte_cleaned_pan
    WHERE FN_CHECK_ADJACENT_CHARACTERS(pan_number) = FALSE
      AND fn_check_sequencial_characters(SUBSTRING(PAN_NUMBER,1,5)) = FALSE
      AND fn_check_sequencial_characters(SUBSTRING(PAN_NUMBER,6,4)) = FALSE
      AND PAN_NUMBER ~ '^[A-Z]{5}[0-9]{4}[A-Z]$'
)
SELECT cln.pan_number,
       CASE WHEN vld.pan_number IS NOT NULL THEN 'Valid PAN'
            ELSE 'Invalid PAN'
       END AS status
FROM cte_cleaned_pan cln
LEFT JOIN cte_valid_pans vld
ON vld.pan_number = cln.pan_number;
```

---

## Views

Create a view for easier reporting:

```sql
CREATE OR REPLACE VIEW vw_valid_invalid_pans AS
WITH cte_cleaned_pan AS (
    SELECT DISTINCT UPPER(TRIM(PAN_NUMBER)) AS PAN_NUMBER
    FROM STG_PAN_NUMBERS_DATASET
    WHERE PAN_NUMBER IS NOT NULL AND TRIM(PAN_NUMBER) <> ''
),
cte_valid_pans AS (
    SELECT *
    FROM cte_cleaned_pan
    WHERE FN_CHECK_ADJACENT_CHARACTERS(pan_number) = FALSE
      AND fn_check_sequencial_characters(SUBSTRING(PAN_NUMBER,1,5)) = FALSE
      AND fn_check_sequencial_characters(SUBSTRING(PAN_NUMBER,6,4)) = FALSE
      AND PAN_NUMBER ~ '^[A-Z]{5}[0-9]{4}[A-Z]$'
)
SELECT cln.pan_number,
       CASE WHEN vld.pan_number IS NOT NULL THEN 'Valid PAN'
            ELSE 'Invalid PAN'
       END AS status
FROM cte_cleaned_pan cln
LEFT JOIN cte_valid_pans vld
ON vld.pan_number = cln.pan_number;
```

---

## Summary Reports

### Count by Status
```sql
SELECT status, COUNT(*)
FROM vw_valid_invalid_pans
GROUP BY status;
```

### Processed Records Report
```sql
WITH cte AS (
    SELECT
        (SELECT COUNT(*) FROM stg_pan_numbers_dataset) AS total_processed_records,
        COUNT(*) FILTER (WHERE status = 'Valid PAN') AS total_valid_pan,
        COUNT(*) FILTER (WHERE status = 'Invalid PAN') AS total_invalid_pan
    FROM vw_valid_invalid_pans
)
SELECT
    total_processed_records,
    total_valid_pan,
    total_invalid_pan,
    (total_processed_records - total_valid_pan - total_invalid_pan) AS total_missing_or_incomplete_PANs
FROM cte;
```

---

## Usage

1. Create the staging table `stg_pan_numbers_dataset` and load PAN numbers.  
2. Run the **data cleaning** queries.  
3. Create the **validation functions**.  
4. Run the **PAN validation logic** query or use the `vw_valid_invalid_pans` view.  
5. Generate **summary reports** for analysis.

---

## Future Enhancements

- Automate **data import from CSV or Excel**.  
- Add **logging and error handling** for invalid entries.  
- Integrate with **web dashboard** for real-time reporting.  
- Extend validation for **additional PAN rules** (if government updates patterns).

