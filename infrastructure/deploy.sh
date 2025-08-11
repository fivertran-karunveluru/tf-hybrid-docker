#!/bin/bash

# Fivetran Hybrid Agent Terraform Deployment Script
# Usage: ./deploy.sh [environment] [action]
# Example: ./deploy.sh dev plan
# Example: ./deploy.sh prd apply

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if environment and action are provided
if [ $# -lt 2 ]; then
    print_error "Usage: $0 [environment] [action]"
    print_error "Environments: dev, qa, stg, prd, internal-sales"
    print_error "Actions: plan, apply, destroy, init"
    exit 1
fi

ENVIRONMENT=$1
ACTION=$2

# Validate environment
VALID_ENVIRONMENTS=("dev" "qa" "stg" "prd" "internal-sales")
if [[ ! " ${VALID_ENVIRONMENTS[*]} " =~  ${ENVIRONMENT}  ]]; then
    print_error "Invalid environment: $ENVIRONMENT"
    print_error "Valid environments: ${VALID_ENVIRONMENTS[*]}"
    exit 1
fi

# Validate action
VALID_ACTIONS=("plan" "apply" "destroy" "init")
if [[ ! " ${VALID_ACTIONS[*]} " =~  ${ACTION}  ]]; then
    print_error "Invalid action: $ACTION"
    print_error "Valid actions: ${VALID_ACTIONS[*]}"
    exit 1
fi

# Set AWS region
export AWS_REGION="us-west-2"
print_status "Using AWS region: $AWS_REGION"

# Check if tfvars file exists for the environment
TFVARS_FILE="environments/${ENVIRONMENT}.tfvars"
if [ ! -f "$TFVARS_FILE" ]; then
    print_warning "No tfvars file found for environment: $ENVIRONMENT"
    print_warning "Using default values from variables.tf"
fi

# Initialize Terraform if needed
if [ "$ACTION" = "init" ] || [ ! -d ".terraform" ]; then
    print_status "Initializing Terraform..."
    terraform init
fi

# Set workspace name
WORKSPACE_NAME="fivetran-hybrid-agent-${ENVIRONMENT}"
print_status "Using workspace: $WORKSPACE_NAME"

# Create workspace if it doesn't exist
terraform workspace select "${WORKSPACE_NAME}" 2>/dev/null || terraform workspace new "${WORKSPACE_NAME}"

# Execute the specified action
case $ACTION in
    "plan")
        print_status "Planning Terraform deployment for environment: $ENVIRONMENT"
        if [ -f "$TFVARS_FILE" ]; then
            terraform plan -var-file="$TFVARS_FILE" -out="${ENVIRONMENT}.tfplan"
        else
            terraform plan -var="environment=$ENVIRONMENT" -out="${ENVIRONMENT}.tfplan"
        fi
        ;;
    "apply")
        print_status "Applying Terraform deployment for environment: $ENVIRONMENT"
        if [ -f "$TFVARS_FILE" ]; then
            terraform apply -var-file="$TFVARS_FILE"
        else
            terraform apply -var="environment=$ENVIRONMENT"
        fi
        ;;
    "destroy")
        print_warning "Destroying infrastructure for environment: $ENVIRONMENT"
        read -p "Are you sure you want to destroy the infrastructure? (yes/no): " confirm
        if [ "$confirm" = "yes" ]; then
            if [ -f "$TFVARS_FILE" ]; then
                terraform destroy -var-file="$TFVARS_FILE"
            else
                terraform destroy -var="environment=$ENVIRONMENT"
            fi
        else
            print_status "Destroy cancelled"
        fi
        ;;
    "init")
        print_status "Terraform initialization completed"
        ;;
    *)
        print_error "Unknown action: $ACTION"
        exit 1
        ;;
esac

print_status "Deployment script completed for environment: $ENVIRONMENT"
