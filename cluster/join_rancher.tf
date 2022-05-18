data "aws_caller_identity" "current"{}
data "aws_region" "current" {}

locals{
    rancher_api_path = "/v3/clusters"
    credential_secret = var.orchestrator_credential_secret
    account_id = data.aws_caller_identity.current.account_id
}

resource "restapi_object" "join_rancher" {
  count = var.join_orchestrator ? 1 : 0
  path = local.rancher_api_path
  data = jsonencode({
    dockerRootDir = "/var/lib/docker"
    enableClusterMonitoring = false 
    enableNetworkPolicy = false 
    windowsPreferedCluster = false 
    type = "cluster"
    name = var.cluster_name
    labels = merge({awsAccountID = local.account_id, clusterName = var.cluster_name}, var.tags)
    annotations = var.orchestrator_badges
    eksConfig = {
      imported = true 
      displayName = var.cluster_name
      region = data.aws_region.current.name
      type = "eksclusterconfigspec"
      amazonCredentialSecret = local.credential_secret
      nodeGroups = null 
      privateAccess = true 
      publicAccess = false 
    }
  })

  depends_on = [
    module.eks
  ]
} 