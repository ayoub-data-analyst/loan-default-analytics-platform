WITH home_ownership AS (

    SELECT

        home_ownership

    FROM {{ ref('accepted_loans') }}

),

clean_home_ownership AS (

    SELECT DISTINCT

        TRIM(home_ownership) AS home_ownership

    FROM home_ownership

    WHERE home_ownership IS NOT NULL
      AND TRIM(home_ownership) <> ''

)

SELECT

    ROW_NUMBER() OVER (
        ORDER BY home_ownership
    ) AS home_ownership_key,

    home_ownership

FROM clean_home_ownership