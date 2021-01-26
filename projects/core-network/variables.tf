variable "project_id" {
  description = "project id"
}

variable "shared_vpc_service_projects" {
  default = {}
}

variable "subnets" {
  default = []
}

variable "secondary_ranges" {
  default = []
  description = "Secondary CIDR ranges for each subnet - max 5 per subnet"
}

variable "firewall_rules_custom" {
  default = {}
}
