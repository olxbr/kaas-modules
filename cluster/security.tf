resource "aws_security_group" "admin_control_sg" {
  name = "${var.cluster_name}-admin-control-sg"
  description = "security group for control admins"
  vpc_id = var.network.vpc_id

  ingress {
    description = "orchestrator vpc connection"
    from_port =  443 
    to_port = 443
    cidr_blocks = [ "192.168.0.0/16" ]
    protocol = "tcp"
  }

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