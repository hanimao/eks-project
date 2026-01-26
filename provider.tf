terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.16.0"
    }
    helm    = {source = "hashicorp/helm"
    version = "3.0.2"
  }
}
}


terraform {
  backend "s3" {
    bucket       = "terraform-state-eks-2048"
    key          = "terraform/terraform.tfstate"
    region       = "eu-west-2"
    use_lockfile = true
  }
}


data "aws_eks_cluster" "main" {
  name = aws_eks_cluser.main.name
}

data "aws_eks_cluster_auth" "main" {
  name = aws_eks_cluser.main.name
}

# An authentication token to communicate with an EKS cluster.

provider "helm" {
  kubernetes = {
  host                   = data.aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.main.token

exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
      command     = "aws"
    }
  }
}
  







