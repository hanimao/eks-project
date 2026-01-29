terraform {
  required_version = ">= 1.3.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.4.1"
    }
     kubernetes = {
       source  = "hashicorp/kubernetes"
       version = "~> 2.31"
      }
  }
}

provider "aws" {
  region = "eu-west-2"
}

provider "helm" {
  kubernetes = {
    config_path = "${path.module}/kube_config"
  }
}


provider "kubernetes" {
  config_path = "${path.module}/kube_config"
}


    
  
