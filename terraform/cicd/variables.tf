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

variable "service_name" {
  description = "The name of the Cloud Run service to update in the build."
  type        = string
}

variable "space" {
  description = "The Design Center space name."
  type        = string
}
