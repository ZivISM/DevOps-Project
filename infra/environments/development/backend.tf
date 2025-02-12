terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-habitspace"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock-habitspace"
  }
}

# resource "aws_dynamodb_table" "terraform_state_lock" {
#   name           = "terraform-state-lock-habitspace"
#   billing_mode   = "PAY_PER_REQUEST"
#   hash_key       = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }

#   tags = {
#     Environment = "development"
#     Purpose     = "Terraform State Lock"
#   }
# }