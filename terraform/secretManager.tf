# # Handle secrets

# A Secret is a logical secret whose value and versions can be accessed.
#secret_id - (Required) This must be unique within the project.
#replication - (Required) The replication policy of the secret data attached to the Secret.
# It cannot be changed after the Secret has been created. 
#   automatic - (Optional) The Secret will automatically be replicated without any restrictions.
#   user_managed - (Optional) The Secret will automatically be replicated without any restrictions. 
resource "google_secret_manager_secret" "redishost" {
  project = var.project_id
  replication {
    automatic = true
  }
  secret_id  = "redishost"
  depends_on = [google_project_service.all]
}
#All arguments including payload.secret_data will be stored in the raw state as plain-text.
#secret_data - (Required) The secret data. Must be no larger than 64KiB.
# Note: This property is sensitive and will not be displayed in the plan.
#secret - (Required) Secret Manager secret resource
#enabled - (Optional) The current state of the SecretVersion.

resource "google_secret_manager_secret_version" "redishost" {
  enabled     = true
  secret      = "projects/${var.project_id}/secrets/redishost"
  secret_data = google_redis_instance.main.host
  depends_on  = [google_project_service.all, google_redis_instance.main, google_secret_manager_secret.redishost]
}
#A Secret is a logical secret whose value and versions can be accessed.
resource "google_secret_manager_secret" "sqlhost" {
  project = var.project_id
  replication {
    automatic = true
  }
  secret_id  = "sqlhost"
  depends_on = [google_project_service.all]
}

resource "google_secret_manager_secret_version" "sqlhost" {
  enabled     = true
  secret      = "projects/${var.project_id}/secrets/sqlhost"
  secret_data = google_sql_database_instance.main.private_ip_address
  depends_on  = [google_project_service.all, google_sql_database_instance.main, google_secret_manager_secret.sqlhost]
}
