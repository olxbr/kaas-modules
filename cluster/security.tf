locals {
    node_sg_default_rules = {
      ingress_self_all = {
        description = "Node to node all ports/protocols"
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        type        = "ingress"
        self        = true
      }

      egress_olx_all = {
        description = "Allows output to all OLX networks"
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        type        = "egress"
        cidr_blocks = ["10.0.0.0/8"]
      }

      egress_nexus = {
        description = "Nexus registry 5000/tcp"
        protocol = "tcp"
        from_port = 5000
        to_port = 5000
        type = "egress"
        cidr_blocks = ["0.0.0.0/0"]
      }

      ingress_metrics_server = {
        description = "Control Plane metrics server communication"
        protocol = "tcp"
        from_port = 4443
        to_port = 4443
        type = "ingress"
        source_cluster_security_group = true
      }
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