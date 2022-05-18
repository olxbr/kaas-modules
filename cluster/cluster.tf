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

      egress_kaas_network = {
        description = "Egress for KaaS network"
        protocol = "-1"
        from_port = 0
        to_port = 0
        type = "egress"
        cidr_blocks = ["192.168.0.0/16"]
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

  default_node_sg_tags = {
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
      Name = "${var.cluster_name}-nodes-sg"
  }
}

module "eks" {
    source = "terraform-aws-modules/eks/aws"
    cluster_name = var.cluster_name
    cluster_version = var.cluster_version
    cluster_endpoint_private_access = true 
    cluster_endpoint_public_access = false 
    cluster_additional_security_group_ids = [ "${aws_security_group.admin_control_sg.id}" ]
    create_cluster_security_group = true 
    create_node_security_group = true 
    node_security_group_additional_rules = merge(local.node_sg_default_rules, var.node_security_group_additional_rules)
    node_security_group_tags = merge(local.default_node_sg_tags, var.node_security_group_tags)
  
    cluster_addons = {
        coredns = {
            resolve_conflicts = "OVERWRITE"
        }

        vpc-cni = {
            resolve_conflicts = "OVERWRITE"
        }

        kube-proxy = {}
    }
    vpc_id = var.network.vpc_id
    subnet_ids = var.network.subnets.private
    eks_managed_node_group_defaults = {
        ami_type               = "AL2_x86_64"
        disk_size              = 50
    }

    eks_managed_node_groups = {
        for index, workload in var.workloads:
        "${var.cluster_name}-${workload.type}-${workload.lifecycle}" => {
            min_size = workload.min_size
            max_size = workload.max_size
            desired_size = workload.desired_size
            iam_role_name = "${var.cluster_name}-${workload.type}-${workload.lifecycle}-role"
            iam_role_prefix = false 
            create_iam_role = true 
            capacity_type = upper(workload.lifecycle)
            instance_types = lookup(lookup(var.workload_types, workload.type), lower(workload.lifecycle))
            subnet_ids = var.network.subnets.private
            labels = merge({
              "cops.olxbr.io/workload" = workload.type
            }, workload.labels)
        }
    }

    tags = merge({
        Terraform   = "true"
    }, var.tags)
}