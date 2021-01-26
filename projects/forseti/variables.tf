# variables specific to the project being used
variable "project_id" {
  description = "project id"
}

variable "automation_sa" {
  description = "Core automation SA email"
}

variable "enabled_apis" {
  default = [
    "cloudbilling.googleapis.com",
    "cloudasset.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com",
    "pubsub.googleapis.com",
    "serviceusage.googleapis.com",
    "sourcerepo.googleapis.com",
    "storage.googleapis.com",
"admin.googleapis.com",
"appengine.googleapis.com",
"bigquery.googleapis.com",
"cloudasset.googleapis.com",
"cloudbilling.googleapis.com",
"cloudresourcemanager.googleapis.com",
"compute.googleapis.com",
"container.googleapis.com",
"containerregistry.googleapis.com",
"groupssettings.googleapis.com",
"iam.googleapis.com",
"logging.googleapis.com",
"servicemanagement.googleapis.com",
"sql-component.googleapis.com",
"sqladmin.googleapis.com",
"storage-api.googleapis.com"
  ]
}


# contact and owner for the Project
variable "contact" {
  default = "cloudops"
}

# team using the Project
variable "team" {
  default = "cloudops"
}

variable "global_created_via" {
  default = "terraform"
}

variable "hop_gcp_priv_domain" {
}

variable "engineering_all_group" {
}

variable "platform_telepresence_group" {
}

variable "sourced_group" {
}

# Forseti sandbox

variable "forseti_server_permissions" {
  description = "Permissions for the forseti-server sa"
  default = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/cloudsql.client"
  ]
}

variable "forseti_buckets" {
  description = "GCS bucket configuration for forseti"
  default = {
    "bopper-infosec-cai"            = {},
    "bopper-infosec-forseti-rules"  = {},
    "bopper-infosec-forseti-output" = {}
  }
}

variable "gke_bindings" {
  default = {
    server = {
      namespace = "forseti"
      sa        = "forseti-server"
    },
    validator = {
      namespace = "forseti"
      sa        = "config-validator"
    }
  }
}

variable "forseti_server_roles" {
  default = {
    reader = [
      "roles/appengine.appViewer",
      "roles/bigquery.metadataViewer",
      "roles/browser",
      "roles/cloudasset.viewer",
      "roles/cloudsql.viewer",
      "roles/compute.networkViewer",
      "roles/iam.securityReviewer",
      "roles/orgpolicy.policyViewer",
      "roles/servicemanagement.quotaViewer",
      "roles/serviceusage.serviceUsageConsumer",
    ]
    writer = [
      "roles/compute.securityAdmin",
    ]
    cscc = [
      "roles/securitycenter.findingsEditor",
    ]
    profiler = [
      "roles/cloudprofiler.agent",
    ]
  }
}
