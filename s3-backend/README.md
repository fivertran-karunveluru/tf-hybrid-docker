# Terraform Backend Infrastructure

This directory contains the Terraform configuration for setting up the remote state backend infrastructure (S3 bucket and DynamoDB table) for the main Fivetran Hybrid Agent infrastructure.

## Purpose

This is a **one-time setup** that creates:
- S3 bucket for storing Terraform state files
- DynamoDB table for state locking

**Important**: This infrastructure should NOT be destroyed as it contains your Terraform state!

## Quick Setup

```bash
# Set up the backend infrastructure
./setup-backend.sh
```

## What Gets Created

- **S3 Bucket**: `csg-sa-kveluru-tf-state`
  - Versioning enabled
  - Server-side encryption (AES256)
  - Public access blocked
  - Lifecycle policies for cost optimization

- **DynamoDB Table**: `csg-sa-kveluru-tf-state-lock`
  - PAY_PER_REQUEST billing
  - LockID as hash key

## Next Steps

After running `./setup-backend.sh`:

1. Navigate to the main infrastructure: `cd ../infrastructure`
2. Run: `./quick-setup.sh`

## File Structure

- `backend-infrastructure.tf` - S3 bucket and DynamoDB table resources
- `variables.tf` - Configuration variables
- `versions.tf` - Terraform version requirements
- `providers.tf` - AWS provider configuration
- `setup-backend.sh` - One-time setup script
- `README.md` - This file
