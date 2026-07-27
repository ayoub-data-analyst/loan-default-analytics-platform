WITH source AS (

    SELECT *
    FROM {{ source('bronze', 'accepted_loans') }}

),

cleaned AS (

    SELECT

        -- =========================
        -- ID
        -- =========================
        "id" AS loan_id,

        -- =========================
        -- Loan Information
        -- =========================
        "loan_amnt" AS loan_amnt,
        "funded_amnt" AS funded_amnt,

        -- =========================
        -- Loan Details
        -- =========================
        TRY_TO_NUMBER(REPLACE(TRIM("term"), ' months', '')) AS term_months,
        "int_rate" AS int_rate,
        "installment" AS installment,
        NULLIF(UPPER(TRIM("grade")), '') AS grade,
        NULLIF(UPPER(TRIM("sub_grade")), '') AS sub_grade,

        -- =========================
        -- Employment
        -- =========================

        CASE
            WHEN "emp_length" = '< 1 year' THEN 0
            WHEN "emp_length" = '1 year' THEN 1
            WHEN "emp_length" = '2 years' THEN 2
            WHEN "emp_length" = '3 years' THEN 3
            WHEN "emp_length" = '4 years' THEN 4
            WHEN "emp_length" = '5 years' THEN 5
            WHEN "emp_length" = '6 years' THEN 6
            WHEN "emp_length" = '7 years' THEN 7
            WHEN "emp_length" = '8 years' THEN 8
            WHEN "emp_length" = '9 years' THEN 9
            WHEN "emp_length" = '10+ years' THEN 10
            ELSE NULL
        END AS emp_length,

        -- =========================
        -- Borrower
        -- =========================
        NULLIF(UPPER(TRIM("home_ownership")), '') AS home_ownership,
        "annual_inc" AS annual_inc,
        NULLIF(UPPER(TRIM("verification_status")), '') AS verification_status,

        -- =========================
        -- Dates
        -- =========================
        TRY_TO_DATE(NULLIF("issue_d", ''), 'Mon-YYYY') AS issue_date,
        TRY_TO_DATE(NULLIF("earliest_cr_line", ''), 'Mon-YYYY') AS earliest_credit_date,

        -- =========================
        -- Loan Status
        -- =========================
        NULLIF(UPPER(TRIM("loan_status")), '') AS loan_status,
        NULLIF(UPPER(TRIM("purpose")), '') AS purpose,
        NULLIF(UPPER(TRIM("addr_state")), '') AS addr_state,

        -- =========================
        -- Credit
        -- =========================
        CASE
            WHEN "dti" = -1 THEN NULL
            WHEN "dti" > 999 THEN NULL
            ELSE "dti"
        END AS dti,

        "delinq_2yrs" AS delinq_2yrs,
        "fico_range_low" AS fico_range_low,
        "fico_range_high" AS fico_range_high,
        "inq_last_6mths" AS inq_last_6mths,

        "mths_since_last_delinq" AS mths_since_last_delinq,
        "mths_since_last_record" AS mths_since_last_record,

        "open_acc" AS open_acc,
        "pub_rec" AS pub_rec,
        "revol_bal" AS revol_bal,
        "revol_util" AS revol_util,
        "total_acc" AS total_acc,
        
        "out_prncp" AS out_prncp,

        "total_pymnt" AS total_pymnt,

        "total_rec_prncp" AS total_rec_prncp,
        "total_rec_int" AS total_rec_int,
        "total_rec_late_fee" AS total_rec_late_fee,

        "recoveries" AS recoveries,

        TRY_TO_DATE(NULLIF("last_pymnt_d", ''), 'Mon-YYYY') AS last_payment_date,

        "last_pymnt_amnt" AS last_pymnt_amnt,

        TRY_TO_DATE(NULLIF("next_pymnt_d", ''), 'Mon-YYYY') AS next_payment_date,

        TRY_TO_DATE(NULLIF("last_credit_pull_d", ''), 'Mon-YYYY') AS last_credit_pull_date,

        NULLIF(UPPER(TRIM("application_type")), '') AS application_type,

        "acc_now_delinq" AS acc_now_delinq,
        "tot_cur_bal" AS tot_cur_bal,

        "max_bal_bc" AS max_bal_bc,
        "all_util" AS all_util,

        "total_rev_hi_lim" AS total_rev_hi_lim,

        "avg_cur_bal" AS avg_cur_bal,

        "bc_util" AS bc_util,

        "pub_rec_bankruptcies" AS pub_rec_bankruptcies,

        "total_bal_ex_mort" AS total_bal_ex_mort

    FROM source

    WHERE "annual_inc" IS NOT NULL
        AND "dti" IS NOT NULL
        AND "revol_util" IS NOT NULL
        AND TRY_TO_DATE(NULLIF(TRIM("issue_d"), ''), 'Mon-YYYY') IS NOT NULL
        AND TRY_TO_DATE(NULLIF(TRIM("earliest_cr_line"), ''), 'Mon-YYYY') IS NOT NULL

)

SELECT *
FROM cleaned