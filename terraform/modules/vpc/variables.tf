variable "subnets" {
  type = map(object({
    cidr = string
    az   = string
    type = string # "public" or "private"
  }))

  default = {
    public-1 = {
      cidr = "10.0.1.0/24"
      az   = "eu-west-2a"
      type = "public"
    }
    public-2 = {
      cidr = "10.0.2.0/24"
      az   = "eu-west-2b"
      type = "public"
    }
    private-1 = {
      cidr = "10.0.3.0/24"
      az   = "eu-west-2a"
      type = "private"
    }
    private-2 = {
      cidr = "10.0.4.0/24"
      az   = "eu-west-2b"
      type = "private"
    }
  }
}


variable "public_subnet_tags" {
  type = map(string)
  default = {
    "kubernetes.io/cluster/eks-2048" = "shared"
    "kubernetes.io/role/elb"         = 1
  }
}

variable "private_subnet_tags" {
  type = map(string)
  default = {
    "kubernetes.io/cluster/eks-2048"  = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}