#############################
# Module input variables
#############################

variable "bucket_name" {
  description = "Name of the S3 bucket. Consider using workspace-aware naming to avoid collisions."
  type        = string
}

variable "enable_versioning" {
  description = "Toggle object versioning for rollback and retention."
  type        = bool
  default     = true
}

variable "enable_access_logging" {
  description = "Whether to enable server access logging to a target bucket."
  type        = bool
  default     = false
}

variable "logging_bucket_id" {
  description = "ID of the bucket that will receive access logs. Required when enable_access_logging is true."
  type        = string
  default     = null
}

variable "logging_prefix" {
  description = "Prefix to use for access log objects in the target bucket."
  type        = string
  default     = "logs/"
}

variable "enable_lifecycle_rules" {
  description = "Enable lifecycle rules to transition noncurrent versions for cost optimization."
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Map of tags to apply to resources for governance and cost allocation."
  type        = map(string)
  default     = {}
}
