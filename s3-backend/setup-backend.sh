#!/bin/bash

# Backend Infrastructure Setup Script
# This script sets up the S3 bucket and DynamoDB table for Terraform remote state
# IMPORTANT: This is a ONE-TIME setup that should NOT be destroyed

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Terraform Backend Infrastructure Setup ===${NC}"
echo ""
echo -e "${YELLOW}⚠️  IMPORTANT: This is a ONE-TIME setup for remote state management${NC}"
echo -e "${YELLOW}   The S3 bucket and DynamoDB table created here should NEVER be destroyed${NC}"
echo ""

# Check if we're in the backend infrastructure directory
if [ ! -f "backend-infrastructure.tf" ]; then
    echo -e "${GREEN}Error: This script must be run from the backend-infrastructure directory${NC}"
    exit 1
fi

echo -e "${GREEN}Step 1: Initializing Terraform for backend infrastructure...${NC}"
terraform init

echo ""
echo -e "${GREEN}Step 2: Planning backend infrastructure creation...${NC}"
terraform plan

echo ""
echo -e "${YELLOW}⚠️  WARNING: This will create S3 bucket and DynamoDB table for remote state management${NC}"
echo -e "${YELLOW}   These resources should NOT be destroyed as they contain your Terraform state!${NC}"
echo ""
read -p "Do you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Setup cancelled"
    exit 0
fi

echo ""
echo -e "${GREEN}Step 3: Creating backend infrastructure...${NC}"
terraform apply -auto-approve

echo ""
echo -e "${GREEN}✅ Backend infrastructure created successfully!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Go to the main infrastructure directory:"
echo "   cd ../tf-infra"
echo ""
echo "2. Set up the remote backend:"
echo "   ./setup-remote-backend.sh"
echo ""
echo -e "${YELLOW}⚠️  REMEMBER: Do NOT destroy the backend infrastructure!${NC}"
echo -e "${YELLOW}   It contains your Terraform state and should be permanent.${NC}"
