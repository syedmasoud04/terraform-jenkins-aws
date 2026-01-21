# React App EC2 Instance

resource "aws_instance" "app" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.app_instance_type
  key_name               = aws_key_pair.jenkins_key.key_name
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.app.id]

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  user_data = <<-EOF
    #!/bin/bash
    set -e
    
    # Update system
    dnf update -y
    
    # Install Docker
    dnf install -y docker
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ec2-user
    
    # Install Git
    dnf install -y git
    
    echo "App server setup complete!" > /tmp/app-install-complete.txt
  EOF

  tags = {
    Name = "${var.project_name}-app"
  }
}
