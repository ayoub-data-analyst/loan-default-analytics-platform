from datetime import datetime

from airflow import DAG
from airflow.operators.bash import BashOperator


with DAG(
    dag_id="loan_default_pipeline",
    start_date=datetime(2026, 1, 1),
    schedule="@daily",
    catchup=False,
    tags=["loan-default"],
) as dag:

    bronze = BashOperator(
        task_id="bronze_ingestion",
        bash_command="""
        cd /opt/project &&
        python -m bronze.ingestion
        """
    )

    silver = BashOperator(
        task_id="dbt_run_silver",
        bash_command="""
        cd /opt/project/dbt_project &&
        dbt run --select silver
        """
    )

    gold = BashOperator(
        task_id="dbt_run_gold",
        bash_command="""
        cd /opt/project/dbt_project &&
        dbt run --select gold
        """
    )

    tests = BashOperator(
        task_id="dbt_test",
        bash_command="""
        cd /opt/project/dbt_project &&
        dbt test
        """
    )

    bronze >> silver >> gold >> tests