# Backend Infrastructure Resources
# This file creates the S3 bucket and DynamoDB table needed for remote state management

# S3 Bucket for Terraform State
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.terraform_state_bucket

tags = {
  Name        = "terraform-state-backend"
  Purpose     = "Terraform remote state storage"
  Project     = "Docker-Hybrid-Agent"
  Environment = "dev"
  ManagedBy   = "terraform"
  owner       = "karunakar.veluru@fivetran.com"
  team        = "solution_architects"
  department  = "customer_solutions_group"
  expires_on  = "2025-12-31"
}
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Server-Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Lifecycle Configuration (optional - for cost optimization)
resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id     = "state-file-lifecycle"
    status = "Enabled"

    # Required filter - applies to all objects
    filter {
      prefix = ""
    }

    # Move old state files to IA after 30 days
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    # Move to Glacier after 90 days
    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    # Delete after 1 year
    expiration {
      days = 365
    }
  }
}

# DynamoDB Table for State Locking
resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = var.terraform_state_dynamodb_table
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "terraform-state-lock"
    Purpose     = "Terraform state locking"
    Project     = "Docker-Hybrid-Agent"
    Environment = "dev"
    ManagedBy   = "terraform"
    owner       = "karunakar.veluru@fivetran.com"
    team        = "solution_architects"
    department  = "customer_solutions_group"
    expires_on  = "2025-12-31"
  }
}

# Outputs for backend information
output "backend_s3_bucket" {
  description = "S3 bucket created for Terraform state"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "backend_dynamodb_table" {
  description = "DynamoDB table created for state locking"
  value       = aws_dynamodb_table.terraform_state_lock.name
}
