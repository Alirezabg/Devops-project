
# # Handle artifact registry
# A repository for storing artifacts
# repository_id - (Required) The last part of the repository name, for example: "repo1"
# format - (Required) The format of packages that are stored in the repository.
resource "google_artifact_registry_repository" "todo_app" {
  format        = "DOCKER"
  location      = var.region
  project       = var.project_id
  repository_id = "${var.basename}-app"
  depends_on    = [google_project_service.all]
}

