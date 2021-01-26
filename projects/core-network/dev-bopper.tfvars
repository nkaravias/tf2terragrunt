project_id = "bopper-core-0002"

subnets = [
    // core
    {
        subnet_name           = "core-ue4"
        subnet_ip             = "10.117.0.0/21"
        subnet_region         = "us-east4"
        subnet_private_access = "true"
        subnet_flow_logs      = "true"
        description           = "This subnet has a description"            
    },
    {
        subnet_name           = "core-uc1"
        subnet_ip             = "10.117.64.0/21"
        subnet_region         = "us-central1"
        subnet_private_access = "true"
        subnet_flow_logs      = "true"
        description           = "This subnet has a description"
]

shared_vpc_service_projects = {
    bopper-apps-0003 = { 
        "project_id" = "bopper-apps-0003",
        "project_number" = "147624161125"
    }
}
