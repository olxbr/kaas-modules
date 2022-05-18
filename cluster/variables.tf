variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type = string 
}

variable "network" {
  type = object({
    vpc_id = string 
    subnets = object({
      private = list(string)
      public = list(string)
    })
  })
}

variable "cluster_additional_security_group_ids" {
  type = list(string)
  default = []
}

variable "node_security_group_additional_rules" {
  type = map(any)
  default = {}
}

variable "node_security_group_tags" {
  type = map(string)
  default = {}
}

variable "join_orchestrator" {
  type = bool
  default = false
}

variable "workload_types" {
  type = map(object({
    on_demand = list(string)
    spot = list(string)
  }))
}

variable "workloads" {
  type = list(object({
    min_size = number
    max_size = number 
    desired_size = number 
    lifecycle = string 
    type = string
    labels = map(string) 
  }))
}

variable "tags" {
  type = map(string)
  default = {}
}
