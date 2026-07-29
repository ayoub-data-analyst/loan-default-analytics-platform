WITH loan_status AS (

    SELECT

        loan_status

    FROM {{ ref('accepted_loans') }}

),

clean_loan_status AS (

    SELECT DISTINCT

        TRIM(loan_status) AS loan_status

    FROM loan_status

    WHERE loan_status IS NOT NULL
      AND TRIM(loan_status) <> ''

)

SELECT

    ROW_NUMBER() OVER (
        ORDER BY loan_status
    ) AS loan_status_key,

    loan_status

FROM clean_loan_status