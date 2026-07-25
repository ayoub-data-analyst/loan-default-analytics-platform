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
        "Amount Requested" AS amount_requested,

        -- =========================
        -- Application Date
        -- =========================
        TRY_TO_DATE("Application Date") AS application_date,

        -- =========================
        -- Loan Details
        -- =========================
        TRIM("Loan Title") AS loan_title,

        -- =========================
        -- Risk Score
        -- =========================
        "Risk_Score" AS risk_score,

        -- =========================
        -- Financial
        -- =========================
        TRY_TO_NUMBER(REPLACE("Debt-To-Income Ratio", '%', '')) AS debt_to_income_ratio,

        -- =========================
        -- Location
        -- =========================
        TRIM("Zip Code") AS zip_code,
        UPPER(TRIM("State")) AS state,

        -- =========================
        -- Employment
        -- =========================
        CASE
            WHEN "Employment Length" = '< 1 year' THEN 0
            WHEN "Employment Length" = '1 year' THEN 1
            WHEN "Employment Length" = '2 years' THEN 2
            WHEN "Employment Length" = '3 years' THEN 3
            WHEN "Employment Length" = '4 years' THEN 4
            WHEN "Employment Length" = '5 years' THEN 5
            WHEN "Employment Length" = '6 years' THEN 6
            WHEN "Employment Length" = '7 years' THEN 7
            WHEN "Employment Length" = '8 years' THEN 8
            WHEN "Employment Length" = '9 years' THEN 9
            WHEN "Employment Length" = '10+ years' THEN 10
            ELSE NULL
        END AS employment_length,

        "Policy Code" AS policy_code

    FROM source

)

SELECT *
FROM cleaned