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

variable "db_name" {
  description = "The name of the database."
  type        = string
}

variable "db_user" {
  description = "The name of the database user."
  type        = string
}

variable "app_service_account_email" {
  description = "The email of the service account for the application."
  type        = string
}

variable "app_regions" {
  description = "The regions to deploy the application to."
  type        = list(string)
}
