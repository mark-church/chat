#!/bin/bash

# Initialize the database
python -c 'import database; database.create_tables(database.connect_with_connector())'

# Start the Streamlit app in the background on its default port
streamlit run app.py --server.port 8501 &

# Start the FastAPI server in the foreground on the port Cloud Run expects
uvicorn api:app --host 0.0.0.0 --port 8080
