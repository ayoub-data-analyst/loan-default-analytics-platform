{{ config(
    materialized='table'
) }}

WITH rejected AS (

    SELECT

        -- Date
        application_date,

        -- Lookup Columns
        state,
        employment_length,

        -- Measures
        amount_requested,
        risk_score,
        debt_to_income_ratio

    FROM {{ ref('rejected_loans') }}

),

state_lookup AS (

    SELECT

        r.*,

        s.state_key

    FROM rejected r

    LEFT JOIN {{ ref('dim_state') }} s
        ON r.state = s.state_code

),

employment_lookup AS (

    SELECT

        sl.*,

        e.employment_key

    FROM state_lookup sl

    LEFT JOIN {{ ref('dim_employment') }} e
        ON sl.employment_length = e.employment_years

),

date_lookup AS (

    SELECT

        el.*,

        d.date_key AS application_date_key

    FROM employment_lookup el

    LEFT JOIN {{ ref('dim_date') }} d
        ON el.application_date = d.full_date

)

SELECT

    ROW_NUMBER() OVER (ORDER BY application_date, state) AS rejected_loan_key,

    application_date_key,

    state_key,
    employment_key,

    amount_requested,
    risk_score,
    debt_to_income_ratio

FROM date_lookup