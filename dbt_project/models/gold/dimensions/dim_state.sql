WITH all_states AS (

    SELECT addr_state AS state_code
    FROM {{ ref('accepted_loans') }}

    UNION

    SELECT state AS state_code
    FROM {{ ref('rejected_loans') }}

),

clean_states AS (

    SELECT DISTINCT
        TRIM(state_code) AS state_code

    FROM all_states

    WHERE state_code IS NOT NULL
      AND TRIM(state_code) <> ''

)

SELECT

    ROW_NUMBER() OVER (ORDER BY state_code) AS state_key,

    state_code

FROM clean_states