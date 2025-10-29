terraform {
  required_version = ">= 1.3"

  backend "gcs" {
    bucket = "gca-st-eval-suite-testing-10-tfstate"
    prefix = "terraform/state"
  }
}

module "infra" {
  source     = "./infra"
  project_id = var.project_id
  region     = var.region
  app_name   = var.app_name
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
  adc_application_name          = var.adc_application_name
  adc_space_name                = var.adc_space_name
  adc_target_service_name         = module.app.cloud_run_service_name
  artifact_registry_repository_id = module.app.artifact_registry_repository_id
}