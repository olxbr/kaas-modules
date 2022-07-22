resource "aws_security_group" "nodes_sg" {
  name = "${var.cluster_name}-nodes-sg"
  description = "security group for control orchestrator"
  vpc_id = var.network.vpc_id

  ingress {
    description = "orchestrator network connection"
    from_port = 0
    to_port = 0 
    cidr_blocks = [ "10.200.0.0/16" ]
    protocol = "tcp"
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
}

resource "aws_security_group" "admin_control_sg" {
  name = "${var.cluster_name}-admin-control-sg"
  description = "security group for control admins"
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