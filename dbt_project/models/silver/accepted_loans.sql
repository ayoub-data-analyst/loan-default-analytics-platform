{{ config(
    materialized='table'
) }}

WITH source AS (

    SELECT *
    FROM {{ source('bronze', 'accepted_loans') }}

),

cleaned AS (

    SELECT DISTINCT

        -- =========================
        -- IDs
        -- =========================
        id,

        -- =========================
        -- Loan Information
        -- =========================
        loan_amnt,
        funded_amnt,
        funded_amnt_inv,

        -- =========================
        -- Loan Details
        -- =========================
        TRY_TO_NUMBER(REPLACE(term, ' months', '')) AS term_months,
        int_rate,
        installment,
        UPPER(TRIM(grade)) AS grade,
        UPPER(TRIM(sub_grade)) AS sub_grade,

        -- =========================
        -- Employment
        -- =========================
        TRIM(emp_title) AS emp_title,

        CASE
            WHEN emp_length = '< 1 year' THEN 0
            WHEN emp_length = '1 year' THEN 1
            WHEN emp_length = '2 years' THEN 2
            WHEN emp_length = '3 years' THEN 3
            WHEN emp_length = '4 years' THEN 4
            WHEN emp_length = '5 years' THEN 5
            WHEN emp_length = '6 years' THEN 6
            WHEN emp_length = '7 years' THEN 7
            WHEN emp_length = '8 years' THEN 8
            WHEN emp_length = '9 years' THEN 9
            WHEN emp_length = '10+ years' THEN 10
            ELSE NULL
        END AS emp_length,

        -- =========================
        -- Borrower
        -- =========================
        UPPER(TRIM(home_ownership)) AS home_ownership,
        annual_inc,
        UPPER(TRIM(verification_status)) AS verification_status,

        -- =========================
        -- Dates
        -- =========================
        TO_DATE(issue_d, 'Mon-YYYY') AS issue_date,
        TO_DATE(earliest_cr_line, 'Mon-YYYY') AS earliest_credit_date,

        -- =========================
        -- Loan Status
        -- =========================
        UPPER(TRIM(loan_status)) AS loan_status,
        UPPER(TRIM(pymnt_plan)) AS pymnt_plan,
        TRIM(purpose) AS purpose,
        TRIM(title) AS title,
        TRIM(zip_code) AS zip_code,
        UPPER(TRIM(addr_state)) AS addr_state,

        -- =========================
        -- Credit
        -- =========================
        dti,
        delinq_2yrs,
        fico_range_low,
        fico_range_high,
        inq_last_6mths,

        mths_since_last_delinq,
        mths_since_last_record,

        open_acc,
        pub_rec,
        revol_bal,
        revol_util,
        total_acc,

        initial_list_status,

        out_prncp,
        out_prncp_inv,

        total_pymnt,
        total_pymnt_inv,

        total_rec_prncp,
        total_rec_int,
        total_rec_late_fee,

        recoveries,
        collection_recovery_fee,

        TO_DATE(last_pymnt_d, 'Mon-YYYY') AS last_payment_date,

        last_pymnt_amnt,

        TO_DATE(next_pymnt_d, 'Mon-YYYY') AS next_payment_date,

        TO_DATE(last_credit_pull_d, 'Mon-YYYY') AS last_credit_pull_date,

        last_fico_range_low,
        last_fico_range_high,

        collections_12_mths_ex_med,
        mths_since_last_major_derog,

        UPPER(TRIM(application_type)) AS application_type,

        acc_now_delinq,
        tot_coll_amt,
        tot_cur_bal,

        open_acc_6m,
        open_act_il,
        open_il_12m,
        open_il_24m,

        mths_since_rcnt_il,
        total_bal_il,
        il_util,

        open_rv_12m,
        open_rv_24m,

        max_bal_bc,
        all_util,

        total_rev_hi_lim,

        inq_fi,
        total_cu_tl,
        inq_last_12m,

        acc_open_past_24mths,
        avg_cur_bal,

        bc_open_to_buy,
        bc_util,

        chargeoff_within_12_mths,
        delinq_amnt,

        mo_sin_old_il_acct,
        mo_sin_old_rev_tl_op,
        mo_sin_rcnt_rev_tl_op,
        mo_sin_rcnt_tl,

        mort_acc,

        mths_since_recent_bc,
        mths_since_recent_bc_dlq,
        mths_since_recent_inq,
        mths_since_recent_revol_delinq,

        num_accts_ever_120_pd,
        num_actv_bc_tl,
        num_actv_rev_tl,
        num_bc_sats,
        num_bc_tl,
        num_il_tl,
        num_op_rev_tl,
        num_rev_accts,
        num_rev_tl_bal_gt_0,
        num_sats,

        num_tl_120dpd_2m,
        num_tl_30dpd,
        num_tl_90g_dpd_24m,
        num_tl_op_past_12m,

        pct_tl_nvr_dlq,
        percent_bc_gt_75,

        pub_rec_bankruptcies,
        tax_liens,

        tot_hi_cred_lim,
        total_bal_ex_mort,
        total_bc_limit,
        total_il_high_credit_limit

    FROM source

    WHERE annual_inc IS NOT NULL
      AND dti IS NOT NULL
      AND revol_util IS NOT NULL
      AND emp_title IS NOT NULL
      AND TRIM(emp_title) <> ''
      AND title IS NOT NULL
      AND TRIM(title) <> ''

)

SELECT *
FROM cleaned;