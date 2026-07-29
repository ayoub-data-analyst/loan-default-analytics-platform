WITH verification AS (

    SELECT

        verification_status

    FROM {{ ref('accepted_loans') }}

),

clean_verification AS (

    SELECT DISTINCT

        TRIM(verification_status) AS verification_status

    FROM verification

    WHERE verification_status IS NOT NULL
      AND TRIM(verification_status) <> ''

)

SELECT

    ROW_NUMBER() OVER (
        ORDER BY verification_status
    ) AS verification_key,

    verification_status

FROM clean_verification