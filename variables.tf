############################################################
# Root variables
############################################################

variable "aws_region" {
  description = "AWS region for provider configuration."
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "Shared credentials profile to use for authentication."
  type        = string
  default     = "default"
}

variable "base_bucket_name" {
  description = "Base bucket name; workspace suffix is appended to make it unique per environment."
  type        = string
  default     = "terraform-demo-bucket"
}

variable "enable_access_logging" {
  description = "Toggle S3 server access logging for auditability."
  type        = bool
  default     = false
}

variable "logging_bucket_id" {
  description = "ID of the bucket where access logs will be stored when logging is enabled."
  type        = string
  default     = null
}

variable "logging_prefix" {
  description = "Prefix for access log objects in the logging bucket."
  type        = string
  default     = "access-logs/"
}

variable "default_tags" {
  description = "Baseline tags applied to all resources for governance, cost allocation, and ownership."
  type        = map(string)
  default = {
    project = "terraform-demo"
    owner   = "student"
  }
}
