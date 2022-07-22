locals {
  default_node_sg_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    Name = "${var.cluster_name}-nodes-sg"
  }
}

resource "aws_security_group" "nodes_sg" {
  name = "${var.cluster_name}-nodes-sg"
  description = "security group for control orchestrator"
  vpc_id = var.network.vpc_id

  ingress {
    description = "controlplane to node"
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = [ aws.aws_security_group.controlplane_sg.id ]
  }

  ingress {
    description = "orchestrator network connection"
    from_port = 0
    to_port = 0 
    cidr_blocks = [ "10.200.0.0/16", "10.201.0.0/16" ]
    protocol = "-1"
  }

  ingress {
    description = "node to node"
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true 
  }

  egress {
    description = "enable all traffic"
    from_port = 0 
    to_port = 0 
    cidr_blocks = [ "0.0.0.0/0" ]
    protocol = "-1"
  }

  tags = merge(local.default_node_sg_tags, var.node_security_group_tags)
}

resource "aws_security_group" "controlplane_sg" {
  name = "${var.cluster_name}-controlplane-sg"
  description = "security group for control plane"
  vpc_id = var.network.vpc_id

  ingress {
    description = "olx network connection"
    from_port =  443 
    to_port = 443
    cidr_blocks = [ "10.0.0.0/8" ]
    protocol = "tcp"
  }

  tags = {
    Name = "${var.cluster_name}-orchestrator-sg"
  }
}