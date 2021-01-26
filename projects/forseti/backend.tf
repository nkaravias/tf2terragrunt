terraform {
  backend "gcs" {
    bucket = "nik-core-automation-state"
    prefix = "terraform/state/forseti-bopper-sandbox"
  }
}
