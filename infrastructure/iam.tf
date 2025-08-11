# IAM Role for EC2 Instance
resource "aws_iam_role" "ft_agent_ec2_role" {
  name = "Role-${var.environment}-${var.project_name}"
  description = "Role for Fivetran Agent EC2"

  assume_role_policy = templatefile("${path.module}/files/assume_role_policy.json", {
    external_id = var.external_id
  })

  path = "/"
  tags = local.common_tags
}

# Attach managed policies to the role
resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.ft_agent_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_full_access" {
  role       = aws_iam_role.ft_agent_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_role_policy_attachment" "rds_readonly_access" {
  role       = aws_iam_role.ft_agent_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_for_ec2_role" {
  role       = aws_iam_role.ft_agent_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# Custom policy for reading metadata
resource "aws_iam_policy" "agent_ec2_read_metadata" {
  name = "ReadMetadata-${var.environment}-${var.project_name}"
  description = "Policy for EC2 instance to read metadata"

  policy = file("${path.module}/files/agent_ec2_read_metadata_policy.json")
}

resource "aws_iam_role_policy_attachment" "agent_ec2_read_metadata" {
  role       = aws_iam_role.ft_agent_ec2_role.name
  policy_arn = aws_iam_policy.agent_ec2_read_metadata.arn
}

# Custom policy for S3 permissions
resource "aws_iam_policy" "ft_agent_ec2_s3_policy" {
  name = "S3Permissions-${var.environment}-${var.project_name}"
  description = "S3 permissions for Fivetran Agent EC2"

  policy = file("${path.module}/files/ft_agent_ec2_s3_policy.json")
}

resource "aws_iam_role_policy_attachment" "ft_agent_ec2_s3_policy" {
  role       = aws_iam_role.ft_agent_ec2_role.name
  policy_arn = aws_iam_policy.ft_agent_ec2_s3_policy.arn
}

# Custom policy for DynamoDB permissions
resource "aws_iam_policy" "ft_agent_dynamo_policy" {
  name = "DynamoPermissions-${var.environment}-${var.project_name}"
  description = "DynamoDB permissions for Fivetran Agent EC2"

  policy = file("${path.module}/files/ft_agent_dynamo_policy.json")
}

resource "aws_iam_role_policy_attachment" "ft_agent_dynamo_policy" {
  role       = aws_iam_role.ft_agent_ec2_role.name
  policy_arn = aws_iam_policy.ft_agent_dynamo_policy.arn
}

# Instance Profile
resource "aws_iam_instance_profile" "ft_agent_ec2_instance_profile" {
  name = "EC2-IP-${var.environment}-${var.project_name}"
  path = "/"
  role = aws_iam_role.ft_agent_ec2_role.name
}
