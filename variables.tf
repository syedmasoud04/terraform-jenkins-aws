# Input Variables

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "react-jenkins"
}

# VPC Variables
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

# EC2 Variables
variable "jenkins_instance_type" {
  description = "Instance type for Jenkins server"
  type        = string
  default     = "t2.medium" # Jenkins needs decent resources
}

variable "app_instance_type" {
  description = "Instance type for React app server"
  type        = string
  default     = "t2.micro" # Free tier eligible
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "jenkins-key"
}
