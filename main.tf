############################################################
# Root module
# Demonstrates provider configuration, remote backend,
# workspaces, and consumption of a reusable module.
############################################################

terraform {
  # Pin versions for reproducibility and quicker init.
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote backend example: keeps state off local disk and adds locking.
  # Replace the placeholder values with your own bucket/table names
  # before running `terraform init`.
  backend "s3" {
    bucket         = "my-terraform-state-bucket"   # S3 bucket that holds state files
    key            = "s3-demo/terraform.tfstate"    # Path within the bucket, can be workspace-aware
    region         = "us-east-1"                    # Region of the backend bucket
    dynamodb_table = "terraform-locks"              # Optional table for state locking
    encrypt        = true                            # Server-side encryption for the state file
  }
}

# Configure the AWS provider.
provider "aws" {
  region = var.aws_region

  # Allow workspace-specific credentials via profiles for multi-account setups.
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = var.aws_profile
}

# Derive names from the active workspace to avoid collisions when experimenting.
locals {
  workspace_suffix = terraform.workspace == "default" ? "dev" : terraform.workspace
  bucket_name      = "${var.base_bucket_name}-${local.workspace_suffix}"

  common_tags = merge(
    var.default_tags,
    {
      "environment" = local.workspace_suffix,
      "managed_by"  = "terraform"
    }
  )
}

# Create the S3 bucket using the reusable module.
module "s3_bucket" {
  source = "./modules/s3_bucket"

  bucket_name            = local.bucket_name
  enable_versioning      = true
  enable_access_logging  = var.enable_access_logging
  logging_bucket_id      = var.logging_bucket_id
  logging_prefix         = var.logging_prefix
  enable_lifecycle_rules = true
  common_tags            = local.common_tags
}

# Example output showing how to reference module values.
output "bucket_id" {
  description = "ID of the created S3 bucket for this workspace."
  value       = module.s3_bucket.bucket_id
}
