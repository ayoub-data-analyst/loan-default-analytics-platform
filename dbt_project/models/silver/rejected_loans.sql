{{ config(
    materialized='table'
) }}

WITH source AS (

    SELECT *
    FROM {{ source('bronze', 'rejected_loans') }}

),

cleaned AS (

    SELECT DISTINCT

        -- =========================
        -- Loan Information
        -- =========================
        amount_requested,

        -- =========================
        -- Application Date
        -- =========================
        TRY_TO_DATE(application_date) AS application_date,

        -- =========================
        -- Loan Details
        -- =========================
        TRIM(loan_title) AS loan_title,

        -- =========================
        -- Risk Score
        -- =========================
        risk_score,

        -- =========================
        -- Financial
        -- =========================
        TRY_TO_NUMBER(REPLACE(debt_to_income_ratio, '%', '')) AS debt_to_income_ratio,

        -- =========================
        -- Location
        -- =========================
        TRIM(zip_code) AS zip_code,
        UPPER(TRIM(state)) AS state,

        -- =========================
        -- Employment
        -- =========================
        CASE
            WHEN employment_length = '< 1 year' THEN 0
            WHEN employment_length = '1 year' THEN 1
            WHEN employment_length = '2 years' THEN 2
            WHEN employment_length = '3 years' THEN 3
            WHEN employment_length = '4 years' THEN 4
            WHEN employment_length = '5 years' THEN 5
            WHEN employment_length = '6 years' THEN 6
            WHEN employment_length = '7 years' THEN 7
            WHEN employment_length = '8 years' THEN 8
            WHEN employment_length = '9 years' THEN 9
            WHEN employment_length = '10+ years' THEN 10
            ELSE NULL
        END AS employment_length

    FROM source

)

SELECT *
FROM cleaned;