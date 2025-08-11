locals {
  # Environment mappings
  environment_config = {
    internal-sales = {
      vpc_id     = "vpc-0559852c7bdd6f4b7"
      subnet_id1 = "subnet-0f768037aa7bebf93" # technical-sales-subnet-public2
      subnet_id2 = "subnet-0ebf54d0f15f4de5b" # technical-sales-subnet-public3
      az1        = "us-west-2b"
      az2        = "us-west-2c"
    }
    dev = {
      vpc_id     = "vpc-0559852c7bdd6f4b7"
      subnet_id1 = "subnet-0f768037aa7bebf93" # technical-sales-subnet-public2
      subnet_id2 = "subnet-0ebf54d0f15f4de5b" # technical-sales-subnet-public3
      az1        = "us-west-2b"
      az2        = "us-west-2c"
    }
    qa = {
      vpc_id     = "vpc-xxxxxxxxxxxxxxxxx"
      subnet_id1 = "subnet-xxxxxxxxxxxxxxxxx"
      subnet_id2 = "subnet-xxxxxxxxxxxxxxxxx"
      az1        = "us-west-2a"
      az2        = "us-west-2b"
    }
    stg = {
      vpc_id     = "vpc-xxxxxxxxxxxxxxxxx"
      subnet_id1 = "subnet-xxxxxxxxxxxxxxxxx"
      subnet_id2 = "subnet-xxxxxxxxxxxxxxxxx"
      az1        = "us-west-2b"
      az2        = "us-west-2c"
    }
    prd = {
      vpc_id     = "vpc-xxxxxxxxxxxxxxxxx"
      subnet_id1 = "subnet-xxxxxxxxxxxxxxxxx"
      subnet_id2 = "subnet-xxxxxxxxxxxxxxxxx"
      az1        = "us-west-2b"
      az2        = "us-west-2c"
    }
  }

  # Common tags (excluding environment and managed_by which are set by provider default_tags)
  common_tags = {
    owner        = var.owner_name
    team         = var.team_name
    expires_on   = var.expires_on
    department   = var.department_name
  }

  # Stack name
  stack_name = "${var.project_name}-${var.environment}-stack"
}
