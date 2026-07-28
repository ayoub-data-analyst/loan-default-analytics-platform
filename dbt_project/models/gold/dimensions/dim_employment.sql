WITH employment_years AS (

    SELECT emp_length AS employment_years

    FROM {{ ref('accepted_loans') }}

),

clean_employment AS (

    SELECT DISTINCT
        employment_years

    FROM employment_years

    WHERE employment_years IS NOT NULL

)

SELECT

    ROW_NUMBER() OVER (ORDER BY employment_years) AS employment_key,

    employment_years

FROM clean_employment