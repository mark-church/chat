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

variable "app_regions" {
  description = "The regions to deploy the application to."
  type        = list(string)
}

variable "cloud_run_service_names" {
  description = "A map of Cloud Run service names keyed by region."
  type        = map(string)
}
