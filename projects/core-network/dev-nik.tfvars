#project_id = "core-automation-0001"
project_id = "bopper-core-0002"
#project_id = "bopper-apps-0003"

subnets = [
    // core
    {
        subnet_name           = "core-ue4-dev-nik"
        subnet_ip             = "10.117.0.0/21"
        subnet_region         = "us-east4"
        subnet_private_access = "true"
        subnet_flow_logs      = "true"
        description           = "This subnet has a description"            
    },
    {
        subnet_name           = "core-uc1-dev-nik"
        subnet_ip             = "10.117.64.0/21"
        subnet_region         = "us-central1"
        subnet_private_access = "true"
        subnet_flow_logs      = "true"
        description           = "This subnet has a description"
    },
    // gke-1
    {
        subnet_name           = "gke-1-ue4-dev-nik"
        subnet_ip             = "10.117.60.0/22"
        subnet_region         = "us-east4"
        subnet_private_access = "true"
        subnet_flow_logs      = "true"
        description           = "This subnet has a description"            
    },
    {
        subnet_name           = "gke-1-uc1-dev-nik"
        subnet_ip             = "10.117.124.0/22"
        subnet_region         = "us-central1"
        subnet_private_access = "true"
        subnet_flow_logs      = "true"
        description           = "This subnet has a description"
    },
  
]

secondary_ranges = {
    gke-1-ue4-dev-nik = [
        {
            range_name    = "gke-1-ue4-pods"
            ip_cidr_range = "10.118.0.0/20"
        },
        {
            range_name    = "gke-1-ue4-svc"
            ip_cidr_range = "10.118.124.0/22"
        },
    ],
    core-uc1-dev-nik = []
}

firewall_rules_custom = {
  allow-gcp-hc-in = {
        description     = ""
        name            = "allow-gcp-hc-in"
        direction       = "INGRESS"
        action          = "allow"
        enabled         = true
        priority        = 1001
        ranges   = [
            "209.85.152.0/22",
            "209.85.204.0/22",
            "35.191.0.0/16",
            "130.211.0.0/22"        
        ]
        sources         = []
        targets         = ["compute"]
        rules = [
            {
                protocol = "tcp"
                ports    = ["10256", "30000-32767"]
            }
        ]
    extra_attributes = {
        priority = 1001
    }
        use_service_accounts = false            
  }
}

shared_vpc_service_projects = {
    bopper-apps-0003 = { 
        "project_id" = "bopper-apps-0003",
        "project_number" = "147624161125"
    }
}
