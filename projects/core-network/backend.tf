terraform {
  backend "gcs" {
    bucket  = "nik-core-automation-state"
    prefix  = "terraform/state/core-network"
  }
}