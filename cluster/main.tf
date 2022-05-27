data "aws_caller_identity" "current" {}

locals {
  default_node_sg_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    Name                                        = "${var.cluster_name}-nodes-sg"
  }
  account_id = data.aws_caller_identity.current.account_id
}

module "eks" {
  source                                = "terraform-aws-modules/eks/aws"
  cluster_name                          = var.cluster_name
  cluster_version                       = var.cluster_version
  cluster_endpoint_private_access       = true
  cluster_endpoint_public_access        = false
  cluster_additional_security_group_ids = ["${aws_security_group.admin_control_sg.id}"]
  create_cluster_security_group         = true
  create_node_security_group            = true
  node_security_group_additional_rules  = merge(local.node_sg_default_rules, var.node_security_group_additional_rules)
  node_security_group_tags              = merge(local.default_node_sg_tags, var.node_security_group_tags)
  manage_aws_auth_configmap             = true

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
      userarn  = data.aws_iam_user.orchestrator_user.arn
      username = "orchestrator"
      groups   = ["system:masters"]
    }
  ]

  vpc_id     = var.network.vpc_id
  subnet_ids = var.network.subnets.private
  eks_managed_node_group_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = 50
  }

  eks_managed_node_groups = {
    for index, workload in var.workloads :
    "${var.cluster_name}-${workload.type}-${workload.lifecycle}" => {
      min_size     = workload.min_size
      max_size     = workload.max_size
      desired_size = workload.desired_size

      create_iam_role = true
      iam_role_name   = "${var.cluster_name}-${workload.type}-${workload.lifecycle}-role"
      iam_role_prefix = false
      iam_role_additional_policies = [
        "arn:aws:iam::${local.account_id}:policy/eks.additional.nodes.temporary",
        "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
        "arn:aws:iam::aws:policy/AmazonSSMPatchAssociation",
      ]

      capacity_type  = upper(workload.lifecycle)
      instance_types = lookup(lookup(var.workload_types, workload.type), lower(workload.lifecycle))

      subnet_ids = var.network.subnets.private

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 50
            volume_type           = "gp2"
            encrypted             = true
            kms_key_id            = aws_kms_key.ebs.arn
            delete_on_termination = true
          }
        }
      }

      labels = merge({
        "cops.olxbr.io/workload" = workload.type
      }, workload.labels)
    }
  }

  tags = merge({
    Terraform = "true"
  }, var.tags)
}
