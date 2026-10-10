variable "owner_id" {
  description = "Render owner identifier."
  type        = string
}

variable "adopted_web_service_id" {
  description = "QA Render web service ID to adopt."
  type        = string
}

variable "adopted_database_id" {
  description = "QA Render database ID to adopt."
  type        = string
}

variable "adopted_environment_id" {
  description = "QA Render environment ID to adopt."
  type        = string
}

variable "rails_master_key" {
  description = "QA Rails master key."
  type        = string
  sensitive   = true
}

variable "enable_worker" {
  description = "Whether the QA background worker should be enabled."
  type        = bool
  default     = false
}

variable "aws_access_key_id" {
  description = "QA ActiveStorage access key."
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "QA ActiveStorage secret key."
  type        = string
  sensitive   = true
}

variable "aws_region" {
  description = "QA ActiveStorage region."
  type        = string
}

variable "aws_bucket" {
  description = "QA ActiveStorage bucket name."
  type        = string
}

variable "aws_endpoint" {
  description = "QA ActiveStorage endpoint for S3-compatible storage."
  type        = string
  default     = null
}

variable "aws_force_path_style" {
  description = "Whether QA storage should use path-style S3 requests."
  type        = bool
  default     = false
}
