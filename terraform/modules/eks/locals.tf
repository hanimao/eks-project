# defining environment variable as a prefix for objects such as IAM roles, policies since there is multiple environments 

locals {
  env  = "staging"
  eks_name = "eks-2048"
  domain = "eks.hanimao.com"
  region = "eu-west-2" # London region
}
