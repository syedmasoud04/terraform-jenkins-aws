# Backend Configuration - S3 + DynamoDB for state management
# NOTE: Update the bucket name to your actual S3 bucket name

terraform {
  backend "s3" {
    bucket         = "terraform-state-38hf0q31" # UPDATE THIS to your bucket name
    key            = "terraform-aws/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
