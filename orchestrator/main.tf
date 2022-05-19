locals{
    rancher_api_path = "/v3/clusters"
}

resource "restapi_object" "join_rancher" {
  path = local.rancher_api_path
  data = jsonencode({
    dockerRootDir = "/var/lib/docker"
    enableClusterMonitoring = var.enable_cluster_monitoring 
    enableNetworkPolicy = var.enable_network_policy 
    windowsPreferedCluster = false 
    type = "cluster"
    name = var.cluster_name
    labels = merge({clusterName = var.cluster_name}, var.labels)
    annotations = var.badges
    eksConfig = {
      imported = true 
      displayName = var.cluster_name
      region = var.region
      type = "eksclusterconfigspec"
      amazonCredentialSecret = "cattle-global-data:${var.credential_secret}"
      nodeGroups = null 
      privateAccess = true 
      publicAccess = false 
    }
  })
}