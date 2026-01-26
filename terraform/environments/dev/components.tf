
# allow nodes to talk to each other (internal cluster traffic)
resource "aws_security_group_rule" "nodes" {
  description              = "Allow nodes to communicate with each other"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = module.sg.security_group_id
  source_security_group_id = module.sg.security_group_id
}

# allow control plane to talk to nodes 
resource "aws_security_group_rule" "control_plane_to_nodes" {
  description              = "Allow Control Plane to talk to Kubelet"
  type                     = "ingress"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  security_group_id        = module.sg.security_group_id
  source_security_group_id = module.sg.security_group_cluster
}

# allow nodes to talk to control plane 
resource "aws_security_group_rule" "nodes_to_control_plane" {
  description              = "Allow nodes to reach Kubernetes API"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = module.sg.security_group_cluster
  source_security_group_id = module.sg.security_group_id
}

resource "aws_security_group_rule" "node_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.sg.security_group_id
}