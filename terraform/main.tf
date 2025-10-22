terraform {
  required_version = ">= 1.3"

  backend "local" {
    path = "terraform.tfstate"
  }
}

module "infra" {
  source                 = "./infra"
  project_id             = var.project_id
  region                 = var.region
  app_name               = var.app_name
  cloud_run_service_name = module.app.cloud_run_service_name
}

module "app" {
  source                  = "./app"
  project_id              = var.project_id
  region                  = var.region
  app_name                = var.app_name
  db_name                 = var.db_name
  db_user                 = var.db_user
  app_service_account_email = module.infra.app_service_account_email
}

module "cicd" {
  source                        = "./cicd"
  project_id                    = var.project_id
  region                        = var.region
  app_name                      = var.app_name
  github_owner                  = var.github_owner
  github_repo_name              = var.github_repo_name
  artifact_registry_repository_id = module.app.artifact_registry_repository_id
}