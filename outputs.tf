# Output Values

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "jenkins_public_ip" {
  description = "Public IP of Jenkins server"
  value       = aws_instance.jenkins.public_ip
}

output "jenkins_url" {
  description = "URL to access Jenkins"
  value       = "http://${aws_instance.jenkins.public_ip}:8080"
}

output "app_public_ip" {
  description = "Public IP of React app server"
  value       = aws_instance.app.public_ip
}

output "app_url" {
  description = "URL to access React app"
  value       = "http://${aws_instance.app.public_ip}:3000"
}

output "ssh_command_jenkins" {
  description = "SSH command to connect to Jenkins server"
  value       = "ssh -i ${var.key_name}.pem ec2-user@${aws_instance.jenkins.public_ip}"
}

output "ssh_command_app" {
  description = "SSH command to connect to App server"
  value       = "ssh -i ${var.key_name}.pem ec2-user@${aws_instance.app.public_ip}"
}

output "private_key_path" {
  description = "Path to the SSH private key"
  value       = local_file.private_key.filename
}
