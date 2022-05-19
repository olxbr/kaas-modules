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
    annotations = var.orchestrator_badges
    eksConfig = {
      imported = true 
      displayName = var.cluster_name
      region = var.region
      type = "eksclusterconfigspec"
      amazonCredentialSecret = var.credential_secret
      nodeGroups = null 
      privateAccess = true 
      publicAccess = false 
    }
  })
}