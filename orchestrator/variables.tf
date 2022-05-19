variable "credential_secret" {
  type = string 
  default = "cattle-global-data:cc-4s5wt"
}

variable "badges" {
  type = map(string)
}

variable "labels" {
  type = map(string)
}

variable "region" {
  type = string 
}

variable "cluster_name" {
  type = string 
}

variable "enable_cluster_monitoring" {
  type = bool 
  default = false 
}

variable "enable_network_policy" {
  type = bool 
  default = false 
}



