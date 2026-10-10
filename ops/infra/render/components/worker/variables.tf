variable "name" {
  description = "Render worker service name."
  type        = string
}

variable "environment" {
  description = "Render environment name."
  type        = string
}

variable "branch" {
  description = "Git branch used for deploys."
  type        = string
}

variable "start_command" {
  description = "Start command for the worker service."
  type        = string
}

variable "instance_type" {
  description = "Render instance type for the worker service."
  type        = string
}

variable "region" {
  description = "Render region for the worker service."
  type        = string
}

variable "env_vars" {
  description = "Environment variables for the worker service."
  type = map(object({
    value          = optional(string)
    generate_value = optional(bool)
  }))
}
