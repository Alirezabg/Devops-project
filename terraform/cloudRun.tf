
#The null_resource resource implements the standard resource lifecycle but takes no further action.
#The triggers argument allows specifying an arbitrary set of values that, when changed, will cause the resource to be replaced.
resource "null_resource" "cloudbuild_api" {
  provisioner "local-exec" {
    working_dir = "${path.module}/../code/middleware"
    #gcloud builds - create and manage builds for Google Cloud Build
    #Build, test, and deploy on our serverless CI/CD platform.
    #gcloud builds submit - submit a build using Google Cloud Build
    command = "gcloud builds submit . --substitutions=_REGION=${var.region},_BASENAME=${var.basename} --project=${var.project_id}"
  }

  depends_on = [
    google_artifact_registry_repository.todo_app,
    google_secret_manager_secret_version.redishost,
    google_secret_manager_secret_version.sqlhost,
    google_project_service.all
  ]
}

resource "google_cloud_run_service" "api" {
  name     = "${var.basename}-api"
  location = var.region
  project  = var.project_id
  resource {
    limits = {
      # CPU usage limit
      # https://cloud.google.com/run/docs/configuring/cpu
      cpu = "1000m" # 1 vCPU

      # Memory usage limit (per container)
      # https://cloud.google.com/run/docs/configuring/memory-limits
      memory = "256Mi"
    }
  }
  template {
    spec {
      service_account_name = google_service_account.runsa.email
      containers {
        image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.basename}-app/api"
        env {
          name = "REDISHOST"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.redishost.secret_id
              key  = "latest"
            }
          }
        }
        env {
          name = "todo_host"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.sqlhost.secret_id
              key  = "latest"
            }
          }
        }
        env {
          name  = "todo_user"
          value = "todo_user"
        }
        env {
          name  = "todo_pass"
          value = "todo_pass"
        }
        env {
          name  = "todo_name"
          value = "todo"
        }

        env {
          name  = "REDISPORT"
          value = "6379"
        }

      }
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"        = "1000"
        "run.googleapis.com/cloudsql-instances"   = google_sql_database_instance.main.connection_name
        "run.googleapis.com/client-name"          = "terraform"
        "run.googleapis.com/vpc-access-egress"    = "all"
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.main.id
      }
    }
  }
  autogenerate_revision_name = true
  depends_on = [
    null_resource.cloudbuild_api,
  ]
}

resource "null_resource" "cloudbuild_fe" {

  provisioner "local-exec" {
    working_dir = "${path.module}/../code/frontend"
    command     = "gcloud builds submit . --substitutions=_REGION=${var.region},_BASENAME=${var.basename} --project=${var.project_id}"
  }

  depends_on = [
    google_artifact_registry_repository.todo_app,
    google_cloud_run_service.api
  ]
}

resource "google_cloud_run_service" "fe" {
  name     = "${var.basename}-fe"
  location = var.region
  project  = var.project_id
  resource {
    limits = {
      # CPU usage limit
      # https://cloud.google.com/run/docs/configuring/cpu
      cpu = "1000m" # 1 vCPU

      # Memory usage limit (per container)
      # https://cloud.google.com/run/docs/configuring/memory-limits
      memory = "256Mi"
    }
  }
  template {
    spec {
      service_account_name = google_service_account.runsa.email
      containers {
        image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.basename}-app/fe"
        ports {
          container_port = 80
        }
      }
    }
  }
  depends_on = [null_resource.cloudbuild_fe]
}

resource "google_cloud_run_service_iam_member" "noauth_api" {
  location = google_cloud_run_service.api.location
  project  = google_cloud_run_service.api.project
  service  = google_cloud_run_service.api.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_cloud_run_service_iam_member" "noauth_fe" {
  location = google_cloud_run_service.fe.location
  project  = google_cloud_run_service.fe.project
  service  = google_cloud_run_service.fe.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
