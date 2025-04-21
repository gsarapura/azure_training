```sql
-----------------------------------------------------------------------------------------------------
-- PREREQUISITES
-- 1 - Create storage account in Azure
-- 2 - Create container in storage account

-- Using in this example
-- storage account name: nationalmodels2025q1
-- storage account container name: movenationalmodels
-----------------------------------------------------------------------------------------------------
-- SOURCE ACCOUNT
CREATE DATABASE ANALYTICS;
CREATE SCHEMA CYGNAL;

-- CREATE EXTERNAL STAGE 
CREATE STAGE ANALYTICS.CYGNAL.external_national_models_2026
  URL = 'azure://nationalmodels2025q1.blob.core.windows.net/movenationalmodels'
  CREDENTIALS=(AZURE_SAS_TOKEN='?SAS_TOKEN'); -- Question mark is required

SHOW STAGES;

-----------------------------------------------------------------
-- FOR BIG DATA LOAD: CREATE OR USE LARGE WAREHOUSE
CREATE WAREHOUSE temp_national_models_loader
  WAREHOUSE_SIZE = 'LARGE'
  AUTO_SUSPEND = 200  -- 
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE;
  
SHOW WAREHOUSES;
ALTER WAREHOUSE temp_national_models_loader SUSPEND;
DROP WAREHOUSE temp_national_models_loader;
-----------------------------------------------------------------

-- LOAD DATA INTO STORAGE ACCOUNT: ANALYTICS.CYGNAL.NATIONAL_MODELS_2026_DATA_DICTIONARY table
COPY INTO @external_national_models_dict_2026
FROM (
    SELECT *
    FROM ANALYTICS.CYGNAL.NATIONAL_MODELS_2026_DATA_DICTIONARY
)
FILE_FORMAT = (
    TYPE = PARQUET
    COMPRESSION = SNAPPY  -- o AUTO
)
HEADER = TRUE
OVERWRITE = TRUE
MAX_FILE_SIZE = 36000000; -- Snowflake will create different files based on it

-----------------------------------------------------------------------------------------------------
-- TARGET ACCOUNT
CREATE DATABASE ANALYTICS;
CREATE SCHEMA CYGNAL;


-- CREATE EXTERNAL STAGE
CREATE STAGE ANALYTICS.CYGNAL.external_national_models_dict_2026
  URL = 'azure://nationalmodels2025q1.blob.core.windows.net/move-national-models-dict'
  CREDENTIALS=(AZURE_SAS_TOKEN='?');

SHOW STAGES;
DROP STAGE ANALYTICS.CYGNAL.external_national_models_dict_2026;

-- INSPECT SCHEMA IN ONE FILE
SELECT *
  FROM TABLE(
    INFER_SCHEMA(
      LOCATION=>'@external_national_models_dict_2026/data_0_0_0.snappy.parquet'
      , FILE_FORMAT=>'move_voters_2026_parquet_format'
      )
    );

-- CREATE TABLE BY INFERRING SCHEMA
CREATE TABLE ANALYTICS.CYGNAL.NATIONAL_MODELS_2026_DATA_DICTIONARY
  USING TEMPLATE (
    SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
    WITHIN GROUP (ORDER BY order_id)
      FROM TABLE(
        INFER_SCHEMA(
          LOCATION=>'@external_national_models_dict_2026/data_0_0_0.snappy.parquet',
          FILE_FORMAT=>'move_voters_2026_parquet_format'
        )
      ));

-----------------------------------------------------------------
-- FOR BIG DATA LOAD: CREATE OR USE LARGE WAREHOUSE
CREATE WAREHOUSE temp_national_models_loader
  WAREHOUSE_SIZE = 'LARGE'
  AUTO_SUSPEND = 200  -- 
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE;
  
SHOW WAREHOUSES;
ALTER WAREHOUSE temp_national_models_loader SUSPEND;
DROP WAREHOUSE temp_national_models_loader;
-----------------------------------------------------------------

-- COPY FROM STORAGE ACCOUNT
COPY INTO ANALYTICS.CYGNAL.NATIONAL_MODELS_2026_DATA_DICTIONARY
FROM @external_national_models_dict_2026
FILE_FORMAT = (FORMAT_NAME = move_voters_2026_parquet_format)
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;

-- CHECK DATA
SELECT * FROM ANALYTICS.CYGNAL.NATIONAL_MODELS_2026_DATA_DICTIONARY;
SELECT COUNT(*) FROM ANALYTICS.CYGNAL.NATIONAL_MODELS_2026_DATA_DICTIONARY;
```