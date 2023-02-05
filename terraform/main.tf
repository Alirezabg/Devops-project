
terraform {
  required_providers {
    google = {
    source = "hashicorp/google" }
  }
  # gcloud auth application-default login
  # https://developer.hashicorp.com/terraform/language/settings/backends/gcs
  backend "gcs" {
    bucket = "alirezaxbg-terraform-bucket-tfstate"
    prefix = "terraform/state"
  }
}


provider "google" {
  project     = var.project_id
  region      = "us-central1"
  zone        = "us-central1-c"
  # credentials = file("terra.json")
}
#Use this data source to get project details.
output "project_number" {
  value = data.google_project.project.number
}
# arguments : project_id - (Optional) The project ID. If it is not provided, the provider project is used.
data "google_project" "project" {
  project_id = var.project_id
}



# The resource random_id generates random numbers that are intended to be used as unique identifiers for other resources.

resource "random_id" "id" {
  byte_length = 2
}

