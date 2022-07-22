data "aws_caller_identity" "current"{}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

resource "aws_launch_template" "nodes_launch_template" {
  name = "${var.cluster_name}-nodes-template"
  default_version = "1"

  network_interfaces {
    associate_public_ip_address = false
    security_groups = [ aws_security_group.nodes_sg.id ]
  }
}

module "eks" {
    source = "terraform-aws-modules/eks/aws"
    cluster_name = var.cluster_name
    cluster_version = var.cluster_version
    cluster_endpoint_private_access = true 
    cluster_endpoint_public_access = false 
    cluster_additional_security_group_ids = [ "${aws_security_group.controlplane_sg.id}" ]
    create_cluster_security_group = true 
    create_node_security_group = false 
    node_security_group_id = aws_security_group.nodes_sg.id
    node_security_group_tags = merge(local.default_node_sg_tags, var.node_security_group_tags)
    manage_aws_auth_configmap = true

    cluster_addons = {
        coredns = {
            resolve_conflicts = "OVERWRITE"
        }

        vpc-cni = {
            resolve_conflicts = "OVERWRITE"
        }

        kube-proxy = {}
    }

    aws_auth_users = [
        {
            userarn = data.aws_iam_user.orchestrator_user.arn
            username = "orchestrator"
            groups = ["system:masters"]
        }
    ]

    vpc_id = var.network.vpc_id
    subnet_ids = var.network.subnets.private
    eks_managed_node_group_defaults = {
        ami_type               = "AL2_x86_64"
        disk_size              = 50
    }

    eks_managed_node_groups = {
        for index, workload in var.workloads:
        "${var.cluster_name}-${workload.type}-${workload.lifecycle}" => {
            create_launch_template = false
            launch_template_name   = aws_launch_template.nodes_launch_template.name
            launch_template_version = aws_launch_template.nodes_launch_template.default_version
            min_size = workload.min_size
            max_size = workload.max_size
            desired_size = workload.desired_size
            iam_role_name = "${var.cluster_name}-${workload.type}-${workload.lifecycle}-role"
            iam_role_prefix = false 
            create_iam_role = true 
            capacity_type = upper(workload.lifecycle)
            instance_types = lookup(lookup(var.workload_types, workload.type), lower(workload.lifecycle))
            subnet_ids = var.network.subnets.private
            iam_role_additional_policies = [
                "arn:aws:iam::${local.account_id}:policy/eks.additional.nodes.temporary", 
                "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
                "arn:aws:iam::aws:policy/AmazonSSMPatchAssociation", 
            ]
            labels = merge({
              "kaas.olxbr.io/workload" = lookup(var.workload_types, workload.type).label_name == "" ? workload.type : lookup(var.workload_types, workload.type).label_name
            }, workload.labels)
        }
    }

    tags = merge({
        Terraform   = "true"
    }, var.tags)
}
