import os
import sqlalchemy
import logging

# --- DATABASE SETUP ---
def connect_with_connector() -> sqlalchemy.engine.base.Engine:
    """
    Initializes a connection pool for a Cloud SQL instance of Postgres.

    Uses the Cloud SQL Python Connector package.
    """
    # Note: Saving credentials in environment variables is convenient, but not
    # secure - consider a more secure solution such as
    # Cloud Secret Manager to help keep secrets safe.
    instance_connection_name = os.environ["INSTANCE_CONNECTION_NAME"]  # e.g. 'project:region:instance'
    db_user = os.environ["DB_USER"]  # e.g. 'my-db-user'
    db_pass = os.environ["DB_PASS"]  # e.g. 'my-db-password'
    db_name = os.environ["DB_NAME"]  # e.g. 'my-database'

    from google.cloud.sql.connector import Connector

    connector = Connector()

    def getconn():
        conn = connector.connect(
            instance_connection_name,
            "pg8000",
            user=db_user,
            password=db_pass,
            db=db_name,
        )
        return conn

    logging.info("Creating SQLAlchemy engine with 5s pool timeout and 10s statement timeout.")
    engine = sqlalchemy.create_engine(
        "postgresql+pg8000://",
        creator=getconn,
        # How long to wait for a connection from the pool.
        pool_timeout=5,
        # Arguments passed directly to the pg8000 driver.
        connect_args={
            # How long a single SQL query can run (in seconds).
            "timeout": 20
        }
    )
    return engine


def create_tables(engine: sqlalchemy.engine.base.Engine):
    """Creates the messages table if it does not already exist."""
    with engine.connect() as conn:
        conn.execute(
            sqlalchemy.text(
                """
                CREATE TABLE IF NOT EXISTS messages (
                    id SERIAL PRIMARY KEY,
                    username TEXT,
                    message TEXT,
                    avatar TEXT,
                    channel TEXT,
                    timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
                );
                """
            )
        )
        conn.commit()

if __name__ == '__main__':
    # This is for local testing only.
    # In a production environment, the database would be created and managed by Terraform.
    from dotenv import load_dotenv
    load_dotenv()
    engine = connect_with_connector()
    create_tables(engine)