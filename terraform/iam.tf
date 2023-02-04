# Allows management of a single API service for a Google Cloud Platform project.
# For a list of services available, visit the API library page or run gcloud services list --available
##"The list of apis necessary for the project"
resource "google_project_service" "all" {
  for_each           = toset(var.gcp_service_list)
  project            = var.project_id
  # service - (Required) The service to enable.
  service            = each.key
  # If true, disable the service when the Terraform resource is destroyed. Defaults to true. 
  # May be useful in the event that a project is long-lived but the infrastructure running in that project changes frequently.
  disable_on_destroy = false
}




# Updates the IAM policy to grant a role to a new member. Other members for the role for the project are preserved.
# Example :
#     resource "google_project_iam_member" "project" {
#       project = "your-project-id"
#       role    = "roles/firebase.admin"
#       member  = "user:jane@example.com"

#       condition {
#         title       = "expires_after_2019_12_31"
#         description = "Expiring at midnight of 2019-12-31"
#         expression  = "request.time < timestamp(\"2020-01-01T00:00:00Z\")"
#       }
#     }
resource "google_project_iam_member" "allrun" {
  project    = var.project_id
  # Secret Manager Secret Accessor  Allows accessing the payload of secrets.
  role       = "roles/secretmanager.secretAccessor"
  member     = "serviceAccount:${google_service_account.runsa.email}"
  depends_on = [google_project_service.all]
}

# "The list of roles that build needs for"
resource "google_project_iam_member" "allbuild" {
  for_each   = toset(var.build_roles_list)
  project    = var.project_id
  role       = each.key
  member     = "serviceAccount:${local.sabuild}"
  depends_on = [google_project_service.all]
}


#Allows management of a Google Cloud service account.
#If you delete and recreate a service account, you must reapply any IAM roles that it had before.
# Argument Reference : 
#         account_id - (Required) The account id that is used to generate the service account email address and a stable unique id.
#         display_name - (Optional) The display name for the service account. Can be updated without creating a new resource.
#         project - (Optional) The ID of the project that the service account will be created in. Defaults to the provider project configuration.
# Attributes Reference
#         id - an identifier for the resource with format projects/{{project}}/serviceAccounts/{{email}}
#         email - The e-mail address of the service account. This value should be referenced from any google_iam_policy data sources that would grant the service account privileges.
resource "google_service_account" "runsa" {
  project      = var.project_id
  account_id   = "${var.basename}-run-sa"
  display_name = "Service Account Three Tier App on Cloud Run"
}
