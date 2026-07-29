WITH purpose AS (

    SELECT

        purpose

    FROM {{ ref('accepted_loans') }}

),

clean_purpose AS (

    SELECT DISTINCT

        TRIM(purpose) AS purpose

    FROM purpose

    WHERE purpose IS NOT NULL
      AND TRIM(purpose) <> ''

)

SELECT

    ROW_NUMBER() OVER (
        ORDER BY purpose
    ) AS purpose_key,

    purpose

FROM clean_purpose