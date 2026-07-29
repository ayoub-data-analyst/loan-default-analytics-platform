WITH application_type AS (

    SELECT

        application_type

    FROM {{ ref('accepted_loans') }}

),

clean_application_type AS (

    SELECT DISTINCT

        TRIM(application_type) AS application_type

    FROM application_type

    WHERE application_type IS NOT NULL
      AND TRIM(application_type) <> ''

)

SELECT

    ROW_NUMBER() OVER (
        ORDER BY application_type
    ) AS application_type_key,

    application_type

FROM clean_application_type