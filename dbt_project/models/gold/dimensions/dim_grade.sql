WITH grades AS (

    SELECT

        grade,

        sub_grade

    FROM {{ ref('accepted_loans') }}

),

clean_grades AS (

    SELECT DISTINCT

        TRIM(grade) AS grade,

        TRIM(sub_grade) AS sub_grade

    FROM grades

    WHERE grade IS NOT NULL
      AND sub_grade IS NOT NULL
      AND TRIM(grade) <> ''
      AND TRIM(sub_grade) <> ''

)

SELECT

    ROW_NUMBER() OVER (
        ORDER BY grade, sub_grade
    ) AS grade_key,

    grade,

    sub_grade

FROM clean_grades