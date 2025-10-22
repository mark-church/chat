# Gemini Chat Application

This is a real-time chat application built with Python, featuring a Streamlit frontend and a FastAPI backend. The infrastructure is fully defined using Terraform for easy deployment on Google Cloud Platform.

![Application Screenshot](placeholder.png)
*(Note: Replace `placeholder.png` with an actual screenshot of the application.)*

## Features

-   Real-time chat interface.
-   Multiple channels for different topics (`#general`, `#random`, `#tech`).
-   User avatars and randomized usernames for new sessions.
-   Scalable backend API for sending messages.
-   Persistent message history stored in a PostgreSQL database.
-   Automated CI/CD pipeline using Google Cloud Build and GitHub.

## Tech Stack

-   **Frontend:** [Streamlit](https://streamlit.io/)
-   **Backend API:** [FastAPI](https://fastapi.tiangolo.com/)
-   **Database:** [Google Cloud SQL](https://cloud.google.com/sql) (PostgreSQL)
-   **Containerization:** [Docker](https://www.docker.com/)
-   **Infrastructure as Code:** [Terraform](https://www.terraform.io/)
-   **Deployment:**
    -   [Google Cloud Run](https://cloud.google.com/run) for serving the application.
    -   [Google Cloud Build](https://cloud.google.com/build) for automated builds.
    -   [Google Artifact Registry](https://cloud.google.com/artifact-registry) for Docker image storage.
    -   [Google Secret Manager](https://cloud.google.com/secret-manager) for database credentials.
    -   [Google Cloud Load Balancing](https://cloud.google.com/load-balancing) for custom domain and SSL.

## Project Structure

```
.
├── .gitignore
├── Dockerfile              # Defines the container for the application
├── entrypoint.sh           # Script to start both FastAPI and Streamlit servers
├── requirements.txt        # Python dependencies
├── src/                    # Application source code
│   ├── api.py              # FastAPI backend
│   ├── app.py              # Streamlit frontend
│   ├── database.py         # Database connection and table creation logic
│   └── populate_db.py      # Script to populate the database with initial data
└── terraform/              # Terraform configuration for GCP infrastructure
    ├── cloudrun.tf
    ├── database.tf
    ├── iam.tf
    ├── lb.tf
    ├── main.tf
    ├── network.tf
    ├── terraform.tfvars    # Variables for your specific deployment
    ├── variables.tf
    └── self-signed.crt     # Generated SSL certificate
    └── self-signed.key     # Generated SSL private key
```

## Local Development Setup

### Prerequisites

-   Python 3.10+
-   `pip` and `venv`
-   [Google Cloud SDK](https://cloud.google.com/sdk/install)
-   [Cloud SQL Auth Proxy](https://cloud.google.com/sql/docs/postgres/connect-auth-proxy)

### Steps

1.  **Clone the repository:**
    ```bash
    git clone <your-repository-url>
    cd <repository-name>
    ```

2.  **Create and activate a virtual environment:**
    ```bash
    python3 -m venv .venv
    source .venv/bin/activate
    ```

3.  **Install dependencies:**
    ```bash
    pip install -r requirements.txt
    ```

4.  **Set up Environment Variables:**
    You will need a running Cloud SQL instance to connect to. First, deploy the infrastructure using the Terraform steps below. Once deployed, create a `.env` file in the root directory with the following content, replacing the placeholder values with your actual database credentials and connection name.

    **`.env` file:**
    ```
    INSTANCE_CONNECTION_NAME="your-gcp-project-id:your-region:your-instance-name"
    DB_USER="chat-user"
    DB_PASS="your-database-password" # You can get this from Secret Manager
    DB_NAME="chat-db"
    ```

5.  **Start the Cloud SQL Auth Proxy:**
    Open a separate terminal and run the following command to allow local connections to your Cloud SQL database.
    ```bash
    cloud-sql-proxy your-gcp-project-id:your-region:your-instance-name
    ```

6.  **Initialize and Populate the Database:**
    Run the `database.py` script directly to create the necessary tables.
    ```bash
    python src/database.py
    ```
    *(Note: You may need to temporarily add `from dotenv import load_dotenv; load_dotenv()` to the top of `database.py` for it to pick up your `.env` file.)*

7.  **Run the Application:**
    Use the entrypoint script to start both the frontend and backend servers.
    ```bash
    ./entrypoint.sh
    ```
    -   The Streamlit frontend will be available at `http://localhost:8080`.
    -   The FastAPI backend will be available at `http://localhost:8000`.

## Deployment to Google Cloud

### Prerequisites

-   A Google Cloud Platform project.
-   [Google Cloud SDK](https://cloud.google.com/sdk/install) installed and authenticated (`gcloud auth login`).
-   [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) installed.
-   A GitHub repository for the project.

### Steps

1.  **Configure Terraform:**
    -   Update `terraform/terraform.tfvars` with your GCP `project_id`.
    -   In `terraform/cloudrun.tf`, replace the placeholder values `your-github-owner` and `your-github-repo` with your actual GitHub username and repository name.

2.  **Authenticate for Application Default Credentials:**
    ```bash
    gcloud auth application-default login
    ```

3.  **Deploy the Infrastructure:**
    Navigate to the Terraform directory and run the following commands:
    ```bash
    cd terraform
    terraform init
    terraform plan
    terraform apply -auto-approve
    ```
    This will provision all the necessary GCP resources, including the database, Cloud Run service, and the Cloud Build trigger.

4.  **Connect Cloud Build to GitHub:**
    -   In the Google Cloud Console, navigate to "Cloud Build" > "Triggers".
    -   Find the trigger named `chat-app-build-trigger` and connect it to your GitHub repository. You may need to authorize the Google Cloud Build app on GitHub.

5.  **Trigger the Deployment:**
    Push your code to the `main` branch of your GitHub repository.
    ```bash
    git push origin main
    ```
    This will automatically trigger the Cloud Build pipeline, which will:
    -   Build the Docker image.
    -   Push the image to Artifact Registry.
    -   Deploy the new image to the Cloud Run service.

Your application will then be available at the URL provided by the Google Cloud Load Balancer.

## License

This project is licensed under the terms of the Apache 2.0 License.
