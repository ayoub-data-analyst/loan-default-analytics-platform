import os
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
    Create a table from the parquet schema.
    """

    query = f"""
    CREATE OR REPLACE TABLE {DATABASE}.{SCHEMA}.{table_name}

    USING TEMPLATE (

        SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))

        FROM TABLE(

            INFER_SCHEMA(

                LOCATION => '@{DATABASE}.{SCHEMA}.{STAGE_NAME}/{file_name}',

                FILE_FORMAT => '{DATABASE}.{SCHEMA}.{FILE_FORMAT_NAME}'

            )

        )

    );
    """

    session.sql(query).collect()

    print(f"Table '{table_name}' created.")


def copy_into_table(session, table_name, file_name):
    """
    Load one parquet file into its corresponding table.
    """

    query = f"""
    COPY INTO {DATABASE}.{SCHEMA}.{table_name}

    FROM '@{DATABASE}.{SCHEMA}.{STAGE_NAME}/{file_name}'

    FILE_FORMAT = (
        FORMAT_NAME = {DATABASE}.{SCHEMA}.{FILE_FORMAT_NAME}
    )

    MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;
    """

    session.sql(query).collect()

    print(f"Data loaded into '{table_name}'.")