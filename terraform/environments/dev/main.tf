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
  
}

module "helm" {
    source = "../../modules/helm"
}