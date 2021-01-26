provider "google" {
  alias = "tokengen"
}

data "google_service_account_access_token" "sa" {
  provider               = google.tokengen
  target_service_account = var.automation_sa
  lifetime               = "600s"
  scopes = [
    "https://www.googleapis.com/auth/cloud-platform",
  ]
}

provider "google" {
  access_token = data.google_service_account_access_token.sa.access_token
  project = var.project_id
}
# Enable APIS

resource "google_project_service" "project_apis" {
  for_each = toset(var.enabled_apis)
  service  = each.value

  disable_dependent_services = true
}

# Service accounts
resource "google_service_account" "forseti_server_dev" {
  account_id   = "infosec-forseti-server-dev"
  display_name = "Service account for the forseti-server GKE workload"
}

resource "google_service_account" "forseti_validator_dev" {
  account_id   = "infosec-forseti-validator-dev"
  display_name = "Service account for the forseti config-validator GKE workload"
}

# SA permissions
resource "google_project_iam_member" "forseti-server" {
  for_each = toset(var.forseti_server_permissions)
  role     = each.value
  member   = "serviceAccount:${google_service_account.forseti_server_dev.email}"
}

# Source repo
resource "google_sourcerepo_repository" "gcp_policy_library_mirror" {
  name = "gcp-policy-library"
}

resource "google_sourcerepo_repository_iam_binding" "gcp_policy_library_reader" {
  project    = google_sourcerepo_repository.gcp_policy_library_mirror.project
  repository = google_sourcerepo_repository.gcp_policy_library_mirror.name
  role       = "roles/source.reader"

  members = [
    "serviceAccount:${google_service_account.forseti_validator_dev.email}",
    "user:${var.sourced_group}"
  ]
}

resource "google_sourcerepo_repository_iam_binding" "gcp_policy_library_writer" {
  project    = google_sourcerepo_repository.gcp_policy_library_mirror.project
  repository = google_sourcerepo_repository.gcp_policy_library_mirror.name
  role       = "roles/source.writer"

  members = [
    "serviceAccount:${google_service_account.forseti_validator_dev.email}",
    "user:${var.sourced_group}"
  ]
}

# GCS buckets
resource "google_storage_bucket" "infosec-bucket" {
  for_each = var.forseti_buckets
  name     = each.key
  location = "US"

  labels = {
    contact     = var.contact
    team        = var.team
    created_via = var.global_created_via
    purpose     = "infosec-forseti"
  }
}

# GCS bopper-infosec-cai bindings
resource "google_storage_bucket_iam_binding" "cai-writer" {
  bucket = google_storage_bucket.infosec-bucket["bopper-infosec-cai"].name
  role   = "roles/storage.objectCreator"
  members = [
    "serviceAccount:${google_service_account.forseti_server_dev.email}"
  ]
}
resource "google_storage_bucket_iam_binding" "cai-reader" {
  bucket = google_storage_bucket.infosec-bucket["bopper-infosec-cai"].name
  role   = "roles/storage.objectViewer"
  members = [
    "serviceAccount:${google_service_account.forseti_server_dev.email}",
    "user:${var.sourced_group}"
  ]
}

# GCS bopper-infosec-forseti-rules bindings
resource "google_storage_bucket_iam_binding" "forseti-rules-writer" {
  bucket = google_storage_bucket.infosec-bucket["bopper-infosec-forseti-rules"].name
  role   = "roles/storage.objectCreator"
  # Temporary access in dev - In the production build a CI/CD identity should have write, not user groups
  members = [
    "user:${var.sourced_group}"
  ]
}
resource "google_storage_bucket_iam_binding" "forseti-rules-reader" {
  bucket = google_storage_bucket.infosec-bucket["bopper-infosec-forseti-rules"].name
  role   = "roles/storage.objectViewer"
  members = [
    "serviceAccount:${google_service_account.forseti_server_dev.email}",
    "user:${var.sourced_group}"
  ]
}

# GCS bopper-infosec-forseti-output bindings
resource "google_storage_bucket_iam_binding" "forseti-output-writer" {
  bucket = google_storage_bucket.infosec-bucket["bopper-infosec-forseti-output"].name
  role   = "roles/storage.objectCreator"
  members = [
    "serviceAccount:${google_service_account.forseti_server_dev.email}"
  ]
}
resource "google_storage_bucket_iam_binding" "forseti-output-reader" {
  bucket = google_storage_bucket.infosec-bucket["bopper-infosec-forseti-output"].name
  role   = "roles/storage.objectViewer"
  members = [
    "serviceAccount:${google_service_account.forseti_server_dev.email}",
    "user:${var.sourced_group}"
  ]
}

# Workload identity configuration
resource "google_service_account_iam_binding" "forseti_server_dev_workload_identity" {
  service_account_id = google_service_account.forseti_server_dev.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${google_service_account.forseti_server_dev.project}.svc.id.goog[${var.gke_bindings["server"]["namespace"]}/${var.gke_bindings["server"]["sa"]}]",
  ]
}

resource "google_service_account_iam_binding" "forseti_validator_dev_workload_identity" {
  service_account_id = google_service_account.forseti_validator_dev.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${google_service_account.forseti_validator_dev.project}.svc.id.goog[${var.gke_bindings["validator"]["namespace"]}/${var.gke_bindings["validator"]["sa"]}]",
  ]
}

# Grant reader Folder permissions to forseti (dev)
# nik-sandbox 818436369387  /
# nonp / 11972899589
resource "google_folder_iam_member" "folder_nonp_iam" {
  count  = length(var.forseti_server_roles["reader"])
  role   = var.forseti_server_roles["reader"][count.index]
  folder = "folders/11972899589"
  #member = "serviceAccount:${data.terraform_remote_state.bopper_app_development.forseti_server_account.email}"
  member = "serviceAccount:${google_service_account.forseti_server_dev.email}"
}

# Grant reader Org IAM permissions to forseti (dev)
resource "google_organization_iam_member" "forseti_server_org_iam_reader_dev" {
  count  = length(var.forseti_server_roles["reader"])
  role   = var.forseti_server_roles["reader"][count.index]
  org_id = "670891908486"
  #member = "serviceAccount:${data.terraform_remote_state.bopper_app_development.forseti_server_account.email}"
  member = "serviceAccount:${google_service_account.forseti_server_dev.email}"
}


resource "google_pubsub_topic" "cscc_notification_default" {
  name    = "cscc_notifications"
}

resource "google_pubsub_subscription" "cscc_default" {
  name  = "cscc_default"
  topic = google_pubsub_topic.cscc_notification_default.name

  ack_deadline_seconds = 20

}

resource "google_pubsub_topic" "cscc_notification_forseti" {
  name    = "cscc_notification_forseti"
}
#
resource "google_pubsub_subscription" "cscc_forseti" {
  name  = "cscc_forseti"
  topic = google_pubsub_topic.cscc_notification_forseti.name

  ack_deadline_seconds = 20

}
