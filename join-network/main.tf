data "aws_availability_zones" "region_zones" {
    state = "available"
}

data "aws_vpc" "downstream_clusters_vpc"{
    tags = {
        Owner = "kaas"
    }
}

data "aws_subnets" "downstream_clusters_subnets_private"{
    filter {
        name = "vpc-id"
        values = [data.aws_vpc.downstream_clusters_vpc.id]
    }

    dynamic "filter" {
      for_each = length(var.availability_zones) > 0 ? zipmap(range(0, 
      length(var.availability_zones)), var.availability_zones) : {}
      
      content {
        name = "availability-zone"
        values = var.availability_zones
      }
    }

    tags = {
      Tier = "Private"
    }
}

data "aws_subnets" "downstream_clusters_subnets_public"{
    filter {
        name = "vpc-id"
        values = [data.aws_vpc.downstream_clusters_vpc.id]
    }

    filter {
      name = "availability-zone"
      values = var.availability_zones
    }

    tags = {
      Tier = "Public"
    }
}