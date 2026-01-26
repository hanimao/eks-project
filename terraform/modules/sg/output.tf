output "security_group_id" {
    value = aws_security_group.eks_nodes.id 
  
}

output "security_group_cluster" {
  value = aws_security_group.eks_cluster.id
}