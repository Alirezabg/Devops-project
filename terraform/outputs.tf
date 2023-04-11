
output "endpoint" {
  value       = google_cloud_run_service.fe.status[0].url
  description = "The url of the front end which we want to surface to the user"
}

output "sqlservername" {
  value       = google_sql_database_instance.main.name
  description = "The name of the database that we randomly generated."
}

output "api" {
  value       = google_cloud_run_service.api.status[0].url
  description = "The url of the front end which we want to surface to the user"
}
