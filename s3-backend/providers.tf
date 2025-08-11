provider "aws" {
  region = var.aws_region
  
  # Use profile only if explicitly set and not default
  profile = var.aws_profile != "default" ? var.aws_profile : null
  
  # Allow shared credentials file and environment variables
  shared_credentials_files = ["~/.aws/credentials"]
  
  # Default tags for all resources
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
