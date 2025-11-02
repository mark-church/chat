import os
import sqlalchemy
import logging
import google.cloud.logging

# --- LOGGING SETUP ---
client = google.cloud.logging.Client()
client.setup_logging()

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

    logging.info(f"Initializing connection for instance '{instance_connection_name}' and database '{db_name}'.")

    from google.cloud.sql.connector import Connector

    connector = Connector()

    def getconn():
        try:
            conn = connector.connect(
                instance_connection_name,
                "pg8000",
                user=db_user,
                password=db_pass,
                db=db_name,
            )
            logging.info(f"Database connection successful for user '{db_user}' to instance '{instance_connection_name}'.")
            return conn
        except Exception as e:
            logging.error(f"Database connection failed: {e}", exc_info=True)
            raise

    logging.info("Creating SQLAlchemy engine with 5s pool timeout and 20s statement timeout.")
    try:
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
        logging.info("SQLAlchemy engine created successfully.")
        return engine
    except Exception as e:
        logging.error(f"Failed to create SQLAlchemy engine: {e}", exc_info=True)
        raise


def create_tables(engine: sqlalchemy.engine.base.Engine):
    """Creates the messages table if it does not already exist."""
    logging.info("Creating 'messages' table.")
    try:
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
        logging.info("'messages' table created or already exists.")
    except Exception as e:
        logging.error(f"Error creating 'messages' table: {e}", exc_info=True)
        raise

def initialize_database(engine: sqlalchemy.engine.base.Engine):
    """Checks if the messages table exists and creates it if it does not."""
    logging.info("Starting database initialization check.")
    try:
        with engine.connect() as conn:
            # The query checks the information_schema for the table's existence.
            table_exists = conn.execute(sqlalchemy.text(
                "SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'messages')"
            )).scalar()

        if not table_exists:
            logging.info("The 'messages' table was not found. Creating it now.")
            create_tables(engine)
        else:
            logging.info("The 'messages' table already exists. Skipping creation.")
    except Exception as e:
        logging.critical(f"A critical error occurred during the database initialization check: {e}", exc_info=True)
        raise

if __name__ == '__main__':
    # This is for local testing only.
    # In a production environment, the database would be created and managed by Terraform.
    from dotenv import load_dotenv
    load_dotenv()
    engine = connect_with_connector()
    create_tables(engine)