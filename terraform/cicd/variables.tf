variable "project_id" {
  description = "The project ID to deploy to."
  type        = string
}

variable "region" {
  description = "The region to deploy to."
  type        = string
}

variable "app_name" {
  description = "The name of the application."
  type        = string
}

variable "github_owner" {
  description = "The GitHub owner (user or organization)."
  type        = string
}

variable "github_repo_name" {
  description = "The name of the GitHub repository."
  type        = string
}

variable "artifact_registry_repository_id" {
  description = "The ID of the Artifact Registry repository."
  type        = string
}

variable "adc_application_name" {
  description = "The name of the Application Design Center application."
  type        = string
}

variable "adc_space_name" {
  description = "The name of the Application Design Center space."
  type        = string
}

variable "adc_target_service_name" {
  description = "The service name within ADC to update (typically the Cloud Run service name)."
  type        = string
}

variable "app_service_account_email" {
  description = "The email of the service account for the app"
  type        = string
}

variable "public_app_url" {
  description = "The public URL of the app for stress testing"
  type        = string
}

variable "app_regions" {
  description = "The regions to deploy the app to"
  type        = list(string)
}

variable "repo_name" {
  description = "The name of the repo for the cloudbuild trigger"
  type        = string
}

variable "app_image_url" {
  description = "The full URL of the app image"
  type        = string
}

variable "manual_build_tag" {
  description = "A string that can be changed to manually trigger a new container build."
  type        = string
  default     = "v1"
}
