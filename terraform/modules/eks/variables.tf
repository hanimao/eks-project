variable "private_subnet" {
  type        = list(string)
  description = "private Subnet IDs"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "hanimao/eks-project:ref:refs/heads/main"
}

variable "security_group_id" {
  type = string
  
}
