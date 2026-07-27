WITH all_dates AS (

    SELECT issue_date AS full_date
    FROM {{ ref('accepted_loans') }}

    UNION

    SELECT earliest_credit_date AS full_date
    FROM {{ ref('accepted_loans') }}

    UNION

    SELECT last_payment_date AS full_date
    FROM {{ ref('accepted_loans') }}

    UNION

    SELECT next_payment_date AS full_date
    FROM {{ ref('accepted_loans') }}

    UNION

    SELECT last_credit_pull_date AS full_date
    FROM {{ ref('accepted_loans') }}

    UNION

    SELECT application_date AS full_date
    FROM {{ ref('rejected_loans') }}

),

clean_dates AS (

    SELECT DISTINCT full_date

    FROM all_dates

    WHERE full_date IS NOT NULL

)

SELECT

    TO_NUMBER(TO_CHAR(full_date, 'YYYYMMDD')) AS date_key,

    full_date,

    DAY(full_date) AS day,

    WEEK(full_date) AS week,

    MONTH(full_date) AS month,

    MONTHNAME(full_date) AS month_name,

    QUARTER(full_date) AS quarter,

    YEAR(full_date) AS year

FROM clean_dates