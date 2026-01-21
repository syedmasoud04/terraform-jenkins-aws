# Jenkins EC2 Instance

# Get latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# IAM Role for Jenkins EC2 (to access S3, DynamoDB for Terraform)
resource "aws_iam_role" "jenkins_role" {
  name = "${var.project_name}-jenkins-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-jenkins-role"
  }
}

# Attach policies to Jenkins role
resource "aws_iam_role_policy_attachment" "jenkins_ec2_full" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "jenkins_s3_full" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "jenkins_dynamodb_full" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role_policy_attachment" "jenkins_vpc_full" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}

resource "aws_iam_role_policy_attachment" "jenkins_iam_read" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/IAMReadOnlyAccess"
}

# Instance Profile for Jenkins
resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "${var.project_name}-jenkins-profile"
  role = aws_iam_role.jenkins_role.name
}

# Jenkins EC2 Instance
resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.jenkins_instance_type
  key_name               = aws_key_pair.jenkins_key.key_name
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.jenkins.id]
  iam_instance_profile   = aws_iam_instance_profile.jenkins_profile.name

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
  }

  user_data = <<-EOF
    #!/bin/bash
    set -e
    
    # Update system
    dnf update -y
    
    # Install Java 17 (required for Jenkins)
    dnf install -y java-17-amazon-corretto-headless
    
    # Add Jenkins repo and install
    wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
    dnf install -y jenkins
    
    # Install Docker
    dnf install -y docker
    systemctl start docker
    systemctl enable docker
    usermod -aG docker jenkins
    usermod -aG docker ec2-user
    
    # Install Git
    dnf install -y git
    
    # Install Terraform
    dnf install -y yum-utils
    yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
    dnf install -y terraform
    
    # Start Jenkins
    systemctl start jenkins
    systemctl enable jenkins
    
    echo "Jenkins installation complete!" > /tmp/jenkins-install-complete.txt
  EOF

  tags = {
    Name = "${var.project_name}-jenkins"
  }
}
