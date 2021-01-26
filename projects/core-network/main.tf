provider "google" {
  alias   = "tokengen"
}

data "google_service_account_access_token" "sa" {
  provider               = google.tokengen
  target_service_account = var.core_automation_sa
  lifetime               = "600s"
scopes = [
    "https://www.googleapis.com/auth/cloud-platform",
  ]
}

provider "google" {
  access_token = data.google_service_account_access_token.sa.access_token
  project      = var.project_id
}

locals {
  subnet_names = [for d in var.subnets: d.subnet_name]
  subnet_iam = { for s in local.subnet_names: s => "serviceAccount:147624161125-compute@developer.gserviceaccount.com,serviceAccount:147624161125@cloudservices.gserviceaccount.com,serviceAccount:service-147624161125@container-engine-robot.iam.gserviceaccount.com"}
}

module "vpc" {
    source  = "terraform-google-modules/network/google"

    project_id   = var.project_id
    network_name = "core-${terraform.workspace}"
    routing_mode = "GLOBAL"
    subnets = var.subnets
    secondary_ranges = var.secondary_ranges
    shared_vpc_host  = true
}

module "net-svpc-access" {
  source              = "terraform-google-modules/network/google//modules/fabric-net-svpc-access"
  host_project_id     = module.vpc.project_id
  service_project_num = 1
  service_project_ids = ["bopper-apps-0003", "bopper-forsetimirror-0005"]
  host_subnets        = [for s in var.subnets: s.subnet_name]
  host_subnet_regions = ["us-east4", "us-central1"]
  host_subnet_users = local.subnet_iam

  depends_on = [
    module.vpc
  ]
}

output "vpc" { 
  value = module.vpc
}
