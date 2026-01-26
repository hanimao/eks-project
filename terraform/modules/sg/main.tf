# The Security Group for the EKS Control Plane
resource "aws_security_group" "eks_cluster" {
  name        = "eks-cluster-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id 
  tags = { Name = "eks-cluster-sg" }
}

# The Security Group for all Worker Nodes
resource "aws_security_group" "eks_nodes" {
  name        = "eks-node-sg"
  description = "Security group for all nodes in the cluster"
  vpc_id      = var.vpc_id 
  tags = { Name = "eks-node-sg" }
}
