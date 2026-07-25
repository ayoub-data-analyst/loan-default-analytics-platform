import os
import re
from dotenv import load_dotenv

load_dotenv()

DATABASE = os.getenv("SNOWFLAKE_DATABASE")
SCHEMA = os.getenv("SNOWFLAKE_BRONZE_SCHEMA")

STAGE_NAME = "BRONZE_STAGE"
FILE_FORMAT_NAME = "PARQUET_FORMAT"


def upload_file(session, file_path):
    """
    Upload a parquet file to Snowflake Stage.
    """

    session.file.put(
        file_path,
        f"@{DATABASE}.{SCHEMA}.{STAGE_NAME}",
        auto_compress=False,
        overwrite=True,
    )

    print(f"Uploaded: {os.path.basename(file_path)}")


def create_table(session, table_name, file_name):
    """
    Create table from parquet schema with UPPERCASE column names.
    """

    # Get inferred schema
    infer_query = f"""
    SELECT *
    FROM TABLE(
        INFER_SCHEMA(
            LOCATION => '@{DATABASE}.{SCHEMA}.{STAGE_NAME}/{file_name}',
            FILE_FORMAT => '{DATABASE}.{SCHEMA}.{FILE_FORMAT_NAME}'
        )
    )
    """

    columns = session.sql(infer_query).collect()

    for row in columns[:3]:
        print(row)

    ddl = []

    for col in columns:
        name = f'"{col["COLUMN_NAME"]}"'
        dtype = col["TYPE"]
        ddl.append(f'{name} {dtype}')

    create_query = f"""
    CREATE OR REPLACE TABLE {DATABASE}.{SCHEMA}.{table_name} (
        {", ".join(ddl)}
    )
    """
    print(create_query)

    session.sql(create_query).collect()

    print(f"Table {table_name} created.")


def copy_into_table(session, table_name, file_name):
    query = f"""
    COPY INTO {DATABASE}.{SCHEMA}.{table_name}
    FROM '@{DATABASE}.{SCHEMA}.{STAGE_NAME}/{file_name}'
    FILE_FORMAT = (
        FORMAT_NAME = {DATABASE}.{SCHEMA}.{FILE_FORMAT_NAME}
    )
    MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;
    """

    session.sql(query).collect()

    print(f"Loaded {table_name}")