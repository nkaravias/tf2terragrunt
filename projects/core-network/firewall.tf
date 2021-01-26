module "net-firewall" {
  source                  = "terraform-google-modules/network/google//modules/fabric-net-firewall"
  project_id              = var.project_id
  network                 = "core-${terraform.workspace}"
  internal_ranges_enabled = false
  ssh_source_ranges = []
  ssh_target_tags =[]
  https_target_tags = []
  https_source_ranges = []
  http_target_tags = []
  http_source_ranges = []
  custom_rules = var.firewall_rules_custom

  depends_on = [
    module.vpc
  ]
}
