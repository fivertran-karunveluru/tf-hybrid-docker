# EC2 Instance
resource "aws_instance" "hybrid_agent_instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name              = var.key_name
  subnet_id             = local.environment_config[var.environment].subnet_id1
  vpc_security_group_ids = [aws_security_group.agent_security_group.id]
  iam_instance_profile   = aws_iam_instance_profile.ft_agent_ec2_instance_profile.name
  monitoring             = true

  root_block_device {
    volume_size = 60
    volume_type = "gp3"
  }

  user_data = templatefile("${path.module}/user_data.sh", {
    agent_token = var.agent_token
  })

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-ec2"
  })

  # Ensure the instance is replaced if the user data changes
  user_data_replace_on_change = true

  depends_on = [
    aws_iam_role_policy_attachment.ssm_managed_instance_core,
    aws_iam_role_policy_attachment.cloudwatch_full_access,
    aws_iam_role_policy_attachment.rds_readonly_access,
    aws_iam_role_policy_attachment.ecs_for_ec2_role,
    aws_iam_role_policy_attachment.agent_ec2_read_metadata,
    aws_iam_role_policy_attachment.ft_agent_ec2_s3_policy,
    aws_iam_role_policy_attachment.ft_agent_dynamo_policy
  ]
}
