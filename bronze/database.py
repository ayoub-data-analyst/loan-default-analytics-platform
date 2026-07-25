import os
from dotenv import load_dotenv

load_dotenv()


def create_database(session):
    database = os.getenv("SNOWFLAKE_DATABASE")

    session.sql(f"""
        CREATE DATABASE IF NOT EXISTS {database};
    """).collect()

    print(f"Database '{database}' is ready.")


def create_schemas(session):
    database = os.getenv("SNOWFLAKE_DATABASE")

    bronze = os.getenv("SNOWFLAKE_BRONZE_SCHEMA")
    silver = os.getenv("SNOWFLAKE_SILVER_SCHEMA")
    gold = os.getenv("SNOWFLAKE_GOLD_SCHEMA")

    session.sql(f"CREATE SCHEMA IF NOT EXISTS {database}.{bronze};").collect()
    session.sql(f"CREATE SCHEMA IF NOT EXISTS {database}.{silver};").collect()
    session.sql(f"CREATE SCHEMA IF NOT EXISTS {database}.{gold};").collect()

    print("Schemas are ready.")


def create_stage(session):
    database = os.getenv("SNOWFLAKE_DATABASE")
    bronze = os.getenv("SNOWFLAKE_BRONZE_SCHEMA")

    session.sql(f"""
        CREATE STAGE IF NOT EXISTS
        {database}.{bronze}.BRONZE_STAGE;
    """).collect()

    print("Stage is ready.")


def create_file_format(session):
    database = os.getenv("SNOWFLAKE_DATABASE")
    bronze = os.getenv("SNOWFLAKE_BRONZE_SCHEMA")

    session.sql(f"""
        CREATE FILE FORMAT IF NOT EXISTS
        {database}.{bronze}.PARQUET_FORMAT
        TYPE = PARQUET;
    """).collect()

    print("Parquet File Format is ready.")