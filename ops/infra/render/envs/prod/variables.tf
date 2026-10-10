variable "owner_id" {
  description = "Render owner identifier."
  type        = string
}

variable "rails_master_key" {
  description = "Production Rails master key."
  type        = string
  sensitive   = true
}

variable "environment_id" {
  description = "Production Render environment identifier."
  type        = string
}

variable "enable_worker" {
  description = "Whether the production worker should be enabled."
  type        = bool
  default     = false
}

variable "aws_access_key_id" {
  description = "Production ActiveStorage access key."
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "Production ActiveStorage secret key."
  type        = string
  sensitive   = true
}

variable "aws_region" {
  description = "Production ActiveStorage region."
  type        = string
}

variable "aws_bucket" {
  description = "Production ActiveStorage bucket name."
  type        = string
}

variable "aws_endpoint" {
  description = "Production ActiveStorage endpoint for S3-compatible storage."
  type        = string
  default     = null
}

variable "aws_force_path_style" {
  description = "Whether production storage should use path-style S3 requests."
  type        = bool
  default     = false
}
