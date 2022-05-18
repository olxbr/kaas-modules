output "vpc_id" {
  value = data.aws_vpc.downstream_clusters_vpc.id
}

output "private_subnets_ids" {
  value = data.aws_subnets.downstream_clusters_subnets_private.ids
}

output "public_subnets_ids" {
  value = data.aws_subnets.downstream_clusters_subnets_public.ids
}

output "info" {
  value = {
    alias = var.alias
    vpc_id = data.aws_vpc.downstream_clusters_vpc.id
    subnets = {
      private = data.aws_subnets.downstream_clusters_subnets_private.ids
      public = data.aws_subnets.downstream_clusters_subnets_public.ids
    }
  }
}