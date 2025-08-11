# Fivetran Hybrid Agent Terraform Infrastructure

This directory contains Terraform configurations to deploy Fivetran Hybrid Agent infrastructure on AWS. The configuration supports multiple environments and is designed to be easily deployable across different stages of development.

## Overview

This Terraform configuration creates:
- IAM roles and policies for the Fivetran Agent EC2 instance
- Security groups with appropriate ingress/egress rules
- EC2 instance with Docker and Fivetran Agent installation
- Instance profile for EC2 instance permissions

## Prerequisites

1. **Terraform**: Version >= 1.0
2. **AWS CLI**: Configured with appropriate credentials
3. **AWS Permissions**: Ability to create IAM roles, EC2 instances, security groups, S3 buckets, and DynamoDB tables

## Remote State Management

This infrastructure uses remote state management with AWS S3 as the backend. The setup is divided into two phases:

### Phase 1: Backend Infrastructure (One-time setup)
The backend infrastructure (S3 bucket and DynamoDB table) is managed separately in the `../s3-backend/` directory.

```bash
# Navigate to backend infrastructure directory
cd ../s3-backend

# Set up the backend infrastructure (S3 bucket + DynamoDB table)
./setup-backend.sh
```

### Phase 2: Main Infrastructure
After the backend is set up, deploy the main infrastructure:

```bash
# Navigate back to main infrastructure
cd ../infrastructure

# Quick setup (recommended)
./quick-setup.sh

# Or manual setup
terraform init
# Create backend-config.tf manually, then:
terraform init -reconfigure
terraform plan
terraform apply
```

## Quick Start

### 1. Set up Backend Infrastructure (One-time)
```bash
cd ../backend-infrastructure
./setup-backend.sh
```

### 2. Deploy Main Infrastructure
```bash
cd ../infrastructure
./quick-setup.sh
```

## File Structure

### Root Directory Files

```
infrastructure/
├── versions.tf          # Terraform version and provider requirements
├── variables.tf         # Input variables definition
├── locals.tf           # Local values and environment mappings
├── providers.tf        # AWS provider configuration
├── iam.tf             # IAM roles, policies, and instance profile
├── security.tf        # Security group configuration
├── ec2.tf             # EC2 instance configuration
├── outputs.tf         # Output values
├── main.tf            # Main configuration file
├── user_data.sh       # User data script for EC2 instance
├── deploy.sh          # Deployment script
├── quick-setup.sh     # One-command setup for main infrastructure with remote backend
├── files/            # JSON policy files
├── environments/     # Environment-specific variable files
└── README.md         # This file
```

### Backend Infrastructure Directory

```
../s3-backend/
├── backend-infrastructure.tf # S3 bucket and DynamoDB table resources
├── variables.tf              # Backend-specific variables
├── versions.tf               # Terraform version requirements
├── providers.tf              # AWS provider configuration
├── setup-backend.sh          # One-time backend setup script
└── README.md                 # Backend setup documentation
```

### Core Terraform Files

#### `versions.tf`
- Specifies required Terraform version (>= 1.0)
- Defines required provider versions (AWS provider ~> 5.0)
- Sets provider source constraints
- Ensures consistent tooling across deployments

#### `variables.tf`
- Defines all input variables with descriptions and validation rules
- Includes environment, instance type, and AWS configuration variables
- Contains sensitive variables like agent_token with appropriate markings
- Provides validation for environment names and instance types
- Sets default values for optional parameters

#### `locals.tf`
- Contains environment-specific VPC and subnet mappings
- Defines common tags used across resources
- Sets up stack naming conventions
- Manages environment-specific configurations for:
  - VPC IDs
  - Subnet IDs
  - Availability Zones
  - Common resource tags

#### `providers.tf`
- Configures the AWS provider with region and profile settings
- Sets up shared credentials file handling
- Configures default tags for all resources
- Manages provider-level settings like:
  - AWS region
  - Authentication profiles
  - Default resource tags
  - Shared credentials configuration

#### `iam.tf`
- Creates IAM role for EC2 instance with trust policy
- Sets up policies for metadata access, S3, and DynamoDB
- Creates instance profile for EC2 instance
- All resources are environment and project-specific
- Defines:
  - `Role-{environment}-{project_name}`
  - `ReadMetadata-{environment}-{project_name}`
  - `S3Permissions-{environment}-{project_name}`
  - `DynamoPermissions-{environment}-{project_name}`
  - `EC2-IP-{environment}-{project_name}`

#### `security.tf`
- Defines security group with ingress/egress rules
- Configures SSH access from specified IP
- Sets up access for Fivetran API, IdP, and GitHub
- Includes health check port configuration
- Manages:
  - Inbound SSH access (port 22)
  - Fivetran API access (port 443)
  - Health check port access
  - GitHub repository access
  - All outbound traffic

#### `ec2.tf`
- Creates EC2 instance with specified AMI and instance type
- Configures user data for Docker and Fivetran Agent installation
- Sets up volume configuration and monitoring
- Associates security group and IAM instance profile
- Configures:
  - Instance type and AMI
  - Root volume (60GB GP3)
  - User data script
  - Security group association
  - IAM instance profile
  - Monitoring settings

#### `outputs.tf`
- Defines output values for resource IDs and ARNs
- Includes instance IPs, security group ID, and role ARNs
- Provides stack name and other useful information
- Outputs:
  - EC2 instance IDs and IPs
  - Security group IDs
  - IAM role ARNs
  - Instance profile ARNs
  - Stack name

#### `main.tf`
- Main entry point for the Terraform configuration
- Contains high-level resource organization
- Documents the overall infrastructure layout
- Serves as a central reference point

#### `user_data.sh`
- EC2 instance initialization script
- Installs and configures Docker
- Sets up Fivetran Agent with provided token
- Configures:
  - Docker installation
  - AWS SSM agent
  - Fivetran user and permissions
  - Agent installation and configuration

#### `deploy.sh`
- Deployment automation script
- Handles environment selection and validation
- Supports init, plan, apply, and destroy actions
- Includes error handling and status reporting
- Features:
  - Environment validation
  - Action validation
  - Workspace management
  - Colored output
  - Error handling
  - State management

### Subdirectories

#### `files/` Directory
Contains JSON policy files for IAM roles and policies:
- `assume_role_policy.json` - Trust policy for EC2 role
- `agent_ec2_read_metadata_policy.json` - EC2 metadata access policy
- `ft_agent_ec2_s3_policy.json` - S3 access permissions
- `ft_agent_dynamo_policy.json` - DynamoDB permissions

Each JSON file contains IAM policy definitions that follow AWS best practices and principle of least privilege.

#### `environments/` Directory
Environment-specific variable files:
- `dev.tfvars` - Development environment settings
- `qa.tfvars` - QA environment settings
- `stg.tfvars` - Staging environment settings
- `prd.tfvars` - Production environment settings

Each .tfvars file contains environment-specific values for:
- Instance types
- AWS region and profile
- Project name and environment
- Team and department information
- Resource tags and expiration dates

## Resource Naming Convention

All resources follow a consistent naming pattern:
- IAM Role: `Role-{environment}-{project_name}`
- IAM Policies: 
  - `ReadMetadata-{environment}-{project_name}`
  - `S3Permissions-{environment}-{project_name}`
  - `DynamoPermissions-{environment}-{project_name}`
- Instance Profile: `EC2-IP-{environment}-{project_name}`
- Security Group: `{project_name}-{environment}-fivetran-agent-sg`
- EC2 Instance Name Tag: `{project_name}-{environment}-ec2`

## Quick Start

### 1. Initialize Terraform

```bash
cd infrastructure
terraform init
```

### 2. Deploy to Development Environment

```bash
# Plan the deployment
./deploy.sh dev plan

# Apply the deployment
./deploy.sh dev apply
```

### 3. Deploy to Production Environment

```bash
# Plan the deployment
./deploy.sh prd plan

# Apply the deployment
./deploy.sh prd apply
```

## Deployment Script Usage

The `deploy.sh` script provides a convenient way to manage deployments:

```bash
./deploy.sh [environment] [action]
```

### Actions:
- `init` - Initialize Terraform
- `plan` - Create a Terraform plan
- `apply` - Apply the Terraform configuration
- `destroy` - Destroy the infrastructure

### Examples:

```bash
# Initialize Terraform
./deploy.sh dev init

# Plan deployment for development
./deploy.sh dev plan

# Apply deployment for production
./deploy.sh prd apply

# Destroy infrastructure for staging
./deploy.sh stg destroy
```

## Security Considerations

1. **Agent Token**: The `agent_token` variable is marked as sensitive and should be provided securely
2. **IP Access**: Only specified IP addresses can SSH to the instance
3. **IAM Permissions**: Follows the principle of least privilege
4. **Security Groups**: Restrictive ingress rules with specific CIDR blocks

## Troubleshooting

### Common Issues

1. **AMI Not Found**: Ensure the AMI ID is available in the target region
2. **Key Pair Not Found**: Verify the key pair exists in AWS
3. **VPC/Subnet Issues**: Check that the VPC and subnet IDs are correct for the environment
4. **IAM Permissions**: Ensure your AWS credentials have sufficient permissions
5. **Credential Issues**: Verify AWS credentials are properly configured

### Debugging

```bash
# Check Terraform state
terraform show

# Check specific resource
terraform state show aws_instance.hybrid_agent_instance

# View logs
terraform logs

# Test AWS credentials
aws sts get-caller-identity
```