#!/bin/bash

# Quick setup script for main infrastructure with remote state
# This script assumes the backend infrastructure (S3 bucket + DynamoDB) already exists

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Quick Setup for Main Infrastructure with Remote State${NC}"
echo "========================================================="
echo ""

# Check if we're in a Terraform directory
if [ ! -f "versions.tf" ] && [ ! -f "main.tf" ]; then
    echo -e "${GREEN}❌ Error: This script must be run from a Terraform directory${NC}"
    exit 1
fi

echo -e "${GREEN}📋 Step 1: Verifying backend infrastructure exists...${NC}"
echo "Checking if S3 bucket and DynamoDB table are accessible..."

# Get the bucket name from variables
BUCKET_NAME=$(grep -A1 'variable "terraform_state_bucket"' variables.tf | grep 'default' | sed 's/.*default.*=.*"\([^"]*\)".*/\1/')
DYNAMODB_TABLE=$(grep -A1 'variable "terraform_state_dynamodb_table"' variables.tf | grep 'default' | sed 's/.*default.*=.*"\([^"]*\)".*/\1/')
REGION=$(grep -A1 'variable "aws_region"' variables.tf | grep 'default' | sed 's/.*default.*=.*"\([^"]*\)".*/\1/')

if [ -z "$BUCKET_NAME" ] || [ -z "$DYNAMODB_TABLE" ]; then
    echo "Using default values from variables"
    BUCKET_NAME="csg-sa-kveluru-tf-state"
    DYNAMODB_TABLE="csg-sa-kveluru-tf-state-lock"
fi

if [ -z "$REGION" ]; then
    REGION="us-west-2"
fi

echo "Using bucket: $BUCKET_NAME"
echo "Using table: $DYNAMODB_TABLE"
echo "Using region: $REGION"

# Test access to backend resources with explicit region
if ! aws s3 ls "s3://$BUCKET_NAME" --region "$REGION" >/dev/null 2>&1; then
    echo -e "${GREEN}❌ Error: Cannot access S3 bucket $BUCKET_NAME in region $REGION${NC}"
    echo "Please ensure the backend infrastructure exists:"
    echo "1. Go to ../s3-backend"
    echo "2. Run: ./setup-backend.sh"
    echo "3. Come back here and run this script again"
    exit 1
fi

if ! aws dynamodb describe-table --table-name "$DYNAMODB_TABLE" --region "$REGION" >/dev/null 2>&1; then
    echo -e "${GREEN}❌ Error: Cannot access DynamoDB table $DYNAMODB_TABLE in region $REGION${NC}"
    echo "Please ensure the backend infrastructure exists:"
    echo "1. Go to ../s3-backend"
    echo "2. Run: ./setup-backend.sh"
    echo "3. Come back here and run this script again"
    exit 1
fi

echo "✅ Backend infrastructure verified successfully!"

echo ""
echo -e "${GREEN}📋 Step 2: Setting up remote backend...${NC}"

# Create the backend configuration file with modern parameters
cat > backend-config.tf << EOF
# Backend Configuration for Remote State
# This file configures Terraform to use the S3 backend

terraform {
  backend "s3" {
    bucket         = "$BUCKET_NAME"
    key            = "hybrid/docker/terraform.tfstate"
    region         = "$REGION"
    encrypt        = true
    # Note: dynamodb_table is deprecated, using use_lockfile instead
    use_lockfile   = false
  }
}
EOF

echo "Created backend-config.tf with the correct configuration"

echo ""
echo -e "${GREEN}📋 Step 3: Initializing Terraform with remote backend...${NC}"
echo "Running: terraform init -reconfigure"

# Initialize with backend reconfiguration
terraform init -reconfigure

echo ""
echo -e "${GREEN}📋 Step 4: Planning infrastructure deployment...${NC}"
terraform plan

echo ""
echo -e "${GREEN}📋 Step 5: Deploying infrastructure...${NC}"
terraform apply -auto-approve

echo ""
echo -e "${GREEN}🎉 Setup complete! Your main infrastructure is now deployed with remote state management.${NC}"
echo ""
echo -e "${BLUE}Your Terraform state is now managed remotely in:${NC}"
echo "  - S3 Bucket: $BUCKET_NAME"
echo "  - State Key: hybrid/docker/terraform.tfstate"
echo "  - Lock Table: $DYNAMODB_TABLE"
echo "  - Region: $REGION"
echo ""
echo "Next time you work on this infrastructure:"
echo "  - Clone the repository"
echo "  - Run: terraform init"
echo "  - Run: terraform plan"
echo ""
echo -e "${GREEN}Note: Always use 'terraform init' when cloning this repository or working from a new location.${NC}"
