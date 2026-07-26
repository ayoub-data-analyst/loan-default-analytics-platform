WITH source AS (

    SELECT *
    FROM {{ source('bronze', 'rejected_loans') }}

),

typed AS (

    SELECT
        *,
        TRY_TO_NUMBER(REPLACE("Debt-To-Income Ratio", '%', '')) AS dti
    FROM source

),

cleaned AS (

    SELECT DISTINCT

        "Amount Requested" AS amount_requested,

        TRY_TO_DATE("Application Date") AS application_date,

        "Risk_Score" AS risk_score,

        CASE
            WHEN dti = -1 THEN NULL
            WHEN dti > 999 THEN NULL
            ELSE dti
        END AS debt_to_income_ratio,

        UPPER(TRIM("State")) AS state,

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
        END AS employment_length

    FROM typed

)

SELECT *
FROM cleaned