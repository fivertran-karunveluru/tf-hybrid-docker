# This file serves as the main entry point for the Terraform configuration
# All resources are defined in their respective files:
# - iam.tf: IAM roles, policies, and instance profile
# - security.tf: Security group configuration
# - ec2.tf: EC2 instance configuration
# - outputs.tf: Output values
# - variables.tf: Input variables
# - locals.tf: Local values and environment mappings
# - providers.tf: Provider configuration
# - versions.tf: Terraform and provider version requirements

# The configuration is designed to be deployed across multiple environments
# (dev, qa, stg, prd, internal-sales) with environment-specific
# VPC and subnet configurations defined in locals.tf
