import os
from dotenv import load_dotenv

from bronze.connection import create_session
from bronze.database import (
    create_database,
    create_schemas,
    create_stage,
    create_file_format,
)

from bronze.loader import (
    upload_file,
    create_table,
    copy_into_table,
)

load_dotenv()


def main():

    session = create_session()

    try:

        create_database(session)
        create_schemas(session)
        create_stage(session)
        create_file_format(session)

        datasets = [
            (
                os.getenv("ACCEPTED_PARQUET_PATH"),
                os.getenv("ACCEPTED_TABLE"),
            ),
            (
                os.getenv("REJECTED_PARQUET_PATH"),
                os.getenv("REJECTED_TABLE"),
            ),
        ]

        for file_path, table_name in datasets:

            file_name = os.path.basename(file_path)

            upload_file(session, file_path)

            create_table(
                session=session,
                table_name=table_name,
                file_name=file_name,
            )

            copy_into_table(
                session=session,
                table_name=table_name,
                file_name=file_name,
            )

        print("\nBronze Layer completed successfully.")

    finally:

        session.close()


if __name__ == "__main__":
    main()