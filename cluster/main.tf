locals {
  default_node_sg_tags = {
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
      Name = "${var.cluster_name}-nodes-sg"
  }

    adminstrator_access_role_preprod = "arn:aws:iam::375164415270:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSAdministratorAccess_ddb734d029aa8628"
    orchestrator_user_arn = "arn:aws:iam::375164415270:user/rancher-admin"
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

    aws_auth_roles = [
        {
            rolearn = local.adminstrator_access_role_preprod
            username = "administrator-preprod"
            groups = ["system:masters"]
        }
    ]

    aws_auth_users = [
        {
            userarn = local.orchestrator_user_arn
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