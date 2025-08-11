variable "project_name" {
  description = "Name of project for tag and instance names and instance profiles"
  type        = string
  default     = "Docker-Hybrid-Agent"
}

variable "environment" {
  description = "The AWS account to create resources in (lowercase)"
  type        = string
  default     = "internal-sales"
  validation {
    condition     = contains(["internal-sales", "dev", "qa", "stg", "prd"], var.environment)
    error_message = "Environment must be one of: internal-sales, dev, qa, stg, prd."
  }
}

variable "team_name" {
  description = "Team Name"
  type        = string
  default     = "solution_architects"
}

variable "department_name" {
  description = "Department Name"
  type        = string
  default     = "customer_solutions_group"
}

variable "owner_name" {
  description = "Owner Name"
  type        = string
  default     = "karunakar.veluru@fivetran.com"
}

variable "expires_on" {
  description = "Expires On"
  type        = string
  default     = "2025-08-30"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "aws_profile" {
  description = "AWS profile to use for authentication. Set to 'default' to use default credentials or specify a profile name from ~/.aws/credentials"
  type        = string
  default     = "fivetran"
}

# S3 Backend Configuration Variables
variable "terraform_state_bucket" {
  description = "S3 bucket name for storing Terraform state"
  type        = string
  default     = "csg-sa-kveluru-tf-state"
}

variable "terraform_state_key" {
  description = "S3 key path for the Terraform state file"
  type        = string
  default     = "hybrid/docker/terraform.tfstate"
}

variable "terraform_state_region" {
  description = "AWS region for the S3 backend"
  type        = string
  default     = "us-west-2"
}

variable "terraform_state_dynamodb_table" {
  description = "DynamoDB table name for state locking"
  type        = string
  default     = "csg-sa-kveluru-tf-state-lock"
}

variable "terraform_state_encrypt" {
  description = "Whether to encrypt the Terraform state file"
  type        = bool
  default     = true
}
