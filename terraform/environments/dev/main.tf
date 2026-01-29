terraform {
  backend "s3" {
    bucket       = "terraform-state-eks-2048"
    key          = "terraform/terraform.tfstate"
    region       = "eu-west-2"
    use_lockfile = true
  }
}

module "eks" {
    source = "../../modules/eks"
    private_subnet  = module.vpc.private_subnets
    security_group_id = module.sg.security_group_id
}

module "vpc" {
    source = "../../modules/vpc"
}

module "sg" {
source = "../../modules/sg"
vpc_id = module.vpc.vpc_id
}

module "pod-identity" {
    source = "../../modules/pod-identity"
  depends_on = [module.eks]
}

module "helm" {
    source = "../../modules/helm"
    depends_on = [module.eks]
}