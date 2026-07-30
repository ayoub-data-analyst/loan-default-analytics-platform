{{config(
        materialized='table'
        )
}}

WITH accepted AS (

SELECT

    -- Business Key
    loan_id,

    -- Date Columns
    issue_date,
    earliest_credit_date,
    last_payment_date,
    next_payment_date,
    last_credit_pull_date,

    -- Lookup Columns
    addr_state,
    emp_length,
    grade,
    sub_grade,
    home_ownership,
    verification_status,
    purpose,
    application_type,
    loan_status,

    -- Measures
    loan_amnt              AS loan_amount,
    funded_amnt            AS funded_amount,
    term_months,
    int_rate               AS interest_rate,
    installment,
    annual_inc             AS annual_income,
    dti,
    fico_range_low         AS fico_low,
    fico_range_high        AS fico_high,
    delinq_2yrs,
    inq_last_6mths,
    pub_rec,
    pub_rec_bankruptcies,
    acc_now_delinq,
    open_acc,
    total_acc,
    revol_bal,
    revol_util,
    tot_cur_bal,
    total_bal_ex_mort,
    total_rev_hi_lim,
    out_prncp,
    total_pymnt,
    total_rec_prncp,
    total_rec_int,
    total_rec_late_fee,
    recoveries,
    last_pymnt_amnt

FROM {{ ref('accepted_loans') }}

),

state_lookup AS (

    SELECT

        a.*,

        s.state_key

    FROM accepted a

    LEFT JOIN {{ ref('dim_state') }} s

        ON a.addr_state = s.state_code

),

employment_lookup AS (

    SELECT

        sl.*,

        e.employment_key

    FROM state_lookup sl

    LEFT JOIN {{ ref('dim_employment') }} e

        ON sl.emp_length = e.employment_years

),

grade_lookup AS (

    SELECT

        el.*,

        g.grade_key

    FROM employment_lookup el

    LEFT JOIN {{ ref('dim_grade') }} g

        ON el.grade = g.grade
       AND el.sub_grade = g.sub_grade

),

home_ownership_lookup AS (

    SELECT

        gl.*,

        h.home_ownership_key

    FROM grade_lookup gl

    LEFT JOIN {{ ref('dim_home_ownership') }} h

        ON gl.home_ownership = h.home_ownership

),

verification_lookup AS (

    SELECT

        hl.*,

        v.verification_key

    FROM home_ownership_lookup hl

    LEFT JOIN {{ ref('dim_verification') }} v

        ON hl.verification_status = v.verification_status

),

purpose_lookup AS (

    SELECT

        vl.*,

        p.purpose_key

    FROM verification_lookup vl

    LEFT JOIN {{ ref('dim_purpose') }} p

        ON vl.purpose = p.purpose

),

application_type_lookup AS (

    SELECT

        pl.*,

        a.application_type_key

    FROM purpose_lookup pl

    LEFT JOIN {{ ref('dim_application_type') }} a

        ON pl.application_type = a.application_type

),

loan_status_lookup AS (

    SELECT

        al.*,

        l.loan_status_key

    FROM application_type_lookup al

    LEFT JOIN {{ ref('dim_loan_status') }} l

        ON al.loan_status = l.loan_status

),

date_lookup AS (

    SELECT

        lsl.*,

        issue_date.date_key           AS issue_date_key,
        earliest_credit.date_key      AS earliest_credit_date_key,
        last_payment.date_key         AS last_payment_date_key,
        next_payment.date_key         AS next_payment_date_key,
        last_credit_pull.date_key     AS last_credit_pull_date_key

    FROM loan_status_lookup lsl

    LEFT JOIN {{ ref('dim_date') }} issue_date
        ON lsl.issue_date = issue_date.full_date

    LEFT JOIN {{ ref('dim_date') }} earliest_credit
        ON lsl.earliest_credit_date = earliest_credit.full_date

    LEFT JOIN {{ ref('dim_date') }} last_payment
        ON lsl.last_payment_date = last_payment.full_date

    LEFT JOIN {{ ref('dim_date') }} next_payment
        ON lsl.next_payment_date = next_payment.full_date

    LEFT JOIN {{ ref('dim_date') }} last_credit_pull
        ON lsl.last_credit_pull_date = last_credit_pull.full_date

)

SELECT

    ROW_NUMBER() OVER (ORDER BY loan_id) AS accepted_loan_key,

    loan_id,

    issue_date_key,
    earliest_credit_date_key,
    last_payment_date_key,
    next_payment_date_key,
    last_credit_pull_date_key,

    state_key,
    employment_key,
    grade_key,
    home_ownership_key,
    verification_key,
    purpose_key,
    application_type_key,
    loan_status_key,

    loan_amount,
    funded_amount,
    term_months,
    interest_rate,
    installment,
    annual_income,
    dti,
    fico_low,
    fico_high,
    delinq_2yrs,
    inq_last_6mths,
    pub_rec,
    pub_rec_bankruptcies,
    acc_now_delinq,
    open_acc,
    total_acc,
    revol_bal,
    revol_util,
    tot_cur_bal,
    total_bal_ex_mort,
    total_rev_hi_lim,
    out_prncp,
    total_pymnt,
    total_rec_prncp,
    total_rec_int,
    total_rec_late_fee,
    recoveries,
    last_pymnt_amnt

FROM date_lookup