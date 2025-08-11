# Security Group for the Hybrid Agent Instance
resource "aws_security_group" "agent_security_group" {
  name        = "${var.project_name}-${var.environment}-fivetran-agent-sg"
  description = "Hybrid Agent Instance Security Group for ${var.environment} - ${var.project_name}"
  vpc_id      = local.environment_config[var.environment].vpc_id

  # SSH access from home
  ingress {
    description = "Allow SSH from home"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # Access to Github repo
  ingress {
    description = "Allow access to Github repo"
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["185.0.0.0/8"]
  }

  # Fivetran API
  ingress {
    description = "Fivetran API"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["35.236.237.87/32"]
  }

  # Fivetran IdP
  ingress {
    description = "Fivetran IdP"
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["35.188.225.82/32"]
  }

  # Google Artifactory
  ingress {
    description = "Google Artifactory"
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["142.0.0.0/8"]
  }

  # Agent health check
  ingress {
    description = "Agent health check"
    from_port   = var.health_check_port
    to_port     = var.health_check_port
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # All outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-ec2"
  })
}
