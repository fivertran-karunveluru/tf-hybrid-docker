output "agent_instance_id" {
  description = "Hybrid Agent Instance Id"
  value       = aws_instance.hybrid_agent_instance.id
}

output "agent_instance_public_ip" {
  description = "Public IP address of the Hybrid Agent Instance"
  value       = aws_instance.hybrid_agent_instance.public_ip
}

output "agent_instance_private_ip" {
  description = "Private IP address of the Hybrid Agent Instance"
  value       = aws_instance.hybrid_agent_instance.private_ip
}

output "security_group_id" {
  description = "Security Group ID for the Hybrid Agent"
  value       = aws_security_group.agent_security_group.id
}

output "iam_role_arn" {
  description = "IAM Role ARN for the Hybrid Agent"
  value       = aws_iam_role.ft_agent_ec2_role.arn
}

output "instance_profile_arn" {
  description = "Instance Profile ARN for the Hybrid Agent"
  value       = aws_iam_instance_profile.ft_agent_ec2_instance_profile.arn
}

output "stack_name" {
  description = "Name of the Terraform stack"
  value       = local.stack_name
}
