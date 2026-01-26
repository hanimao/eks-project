
resource "aws_eks_cluster" "main" {
  name = "${local.env}-${local.eks_name}"


  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true 
  }

  role_arn = aws_iam_role.eks-cluster.arn 
  version  = "1.34"

  vpc_config {
    subnet_ids = var.private_subnet

  
    endpoint_private_access = false
    endpoint_public_access = true
    
  }

  depends_on = [aws_iam_role_policy_attachment.eks]
}


resource "aws_iam_role" "eks-cluster" {
  name = "${local.env}-${local.eks_name}-eks-cluster"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster.name
}



resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name 
  node_group_name = "node_group"
  node_role_arn   = aws_iam_role.eks_node_group.arn 
  subnet_ids      = var.private_subnet


  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 1
  }

  launch_template {
    id      = aws_launch_template.eks_nodes.id
    version = "1"
  }


  update_config {
    max_unavailable = 1
  }
lifecycle {
  ignore_changes = [ scaling_config[0].desired_size ]
}
  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]
}


resource "aws_launch_template" "eks_nodes" {
  name_prefix            = "eks-nodes"
  vpc_security_group_ids = [var.security_group_id]


  block_device_mappings {
    device_name = "/dev/sdf"
    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }
}


resource "aws_iam_role" "eks_node_group" {
  name = "${local.env}-${local.eks_name}-nodes-group"
  

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}


resource "aws_iam_role_policy_attachment" "example-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group.name 
}

# Manage secondary ips for the pods 

resource "aws_iam_role_policy_attachment" "example-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group.name 
}

# Pull private images from ECR from nodes 

resource "aws_iam_role_policy_attachment" "example-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       =aws_iam_role.eks_node_group.name 
}

resource "aws_eks_addon" "main" {
  for_each = toset(["kube-proxy", "vpc-cni", "eks-pod-identity-agent"])

  cluster_name = aws_eks_cluster.main.name 
  addon_name   = each.value
}

resource "aws_iam_role" "cluster" {
  name = "cluster_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "pod_identity_agent" {
  name = "AmazonEKS_PodIdentityAgentPolicy"
  role = aws_iam_role.eks_node_group.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "eks-auth:AssumePodIdentityRole",
          "eks-auth:AuthenticatePodIdentity"
        ],
        Resource = "*"
      }
    ]
  })
}