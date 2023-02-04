# # Handle Database

# Creates a new Google SQL Database Instance.

#  On newer versions of the provider, you must explicitly set deletion_protection=false (and run terraform apply to write the field to state) in order to destroy an instance.
#  It is recommended to not set this field (or set it to true) until you're ready to destroy the instance and its databases.

# Second-generation instances include a default 'root'@'%' user with no password. This user will be deleted by Terraform on instance creation.
#  You should use google_sql_user to define a custom user with a restricted host and strong password.

# settings - (Optional) The settings to use for the database. The configuration is detailed below. Required if clone is not set.

# root_password - (Optional) Initial root password. Required for MS SQL Server.

# encryption_key_name - (Optional) The full path to the encryption key used for the CMEK disk encryption.
#  Setting up disk encryption currently requires manual steps outside of Terraform.
#  The provided key must be in the same region as the SQL instance. In order to use this feature, a special kind of service account must be created and granted permission on this key.
#  This step can currently only be done manually, please see this step.
#  That service account needs the Cloud KMS > Cloud KMS CryptoKey Encrypter/Decrypter role on your key.
resource "google_sql_database_instance" "main" {
  name             = "${var.basename}-db-${random_id.id.hex}"
  database_version = "MYSQL_5_7"
  region           = var.region
  project          = var.project_id
  settings {
    tier                  = "db-f1-micro"
    disk_autoresize       = true
    #disk_autoresize_limit - (Optional) The maximum size to which storage capacity can be automatically increased.
    # The default value is 0, which specifies that there is no limit.
    disk_autoresize_limit = 0
    #disk_size - (Optional) The size of data disk, in GB. Size of a running instance cannot be reduced but can be increased. The minimum value is 10GB.
    disk_size             = 10
    disk_type             = "PD_SSD"
    ip_configuration {
      #ipv4_enabled - (Optional) Whether this Cloud SQL instance should be assigned a public IPV4 address.
      # At least ipv4_enabled must be enabled or a private_network must be configured.
      ipv4_enabled    = false
      #private_network - (Optional) The VPC network from which the Cloud SQL instance is accessible for private IP. For example, projects/myProject/global/networks/default. Specifying a network enables private IP.
      # At least ipv4_enabled must be enabled or a private_network must be configured.
      # This setting can be updated, but it cannot be removed after it is set.
      private_network = google_compute_network.main.id
    }
    location_preference {
      zone = var.zone
    }
  }
  deletion_protection = false
  depends_on = [
    google_project_service.all,
    google_service_networking_connection.main
  ]
#The local-exec provisioner invokes a local executable after a resource is created. This invokes a process on the machine running Terraform, not on the resource.

# working_dir - (Optional) If provided, specifies the working directory where command will be executed.
#  It can be provided as a relative path to the current working directory or as an absolute path. The directory must exist.
# command - (Required) This is the command to execute. It can be provided as a relative path to the current working directory or as an absolute path.
#  It is evaluated in a shell, and can use environment variables or Terraform variables.
# environment - (Optional) block of key value pairs representing the environment of the executed command.
#  inherits the current process environment.
#  environment = {
#       FOO = "bar"
#       BAR = 1
#       BAZ = "true"
#     }
# when - (Optional) If provided, specifies when Terraform will execute the command. For example, when = destroy specifies that the provisioner will run when the associated resource is destroyed.
  provisioner "local-exec" {
    working_dir = "${path.module}/../code/database"
    command     = "./load_schema.sh ${var.project_id} ${google_sql_database_instance.main.name}"
  }
}

# # Handle redis instance

# A Google Cloud Redis instance.
#name - (Required) The ID of the instance or a fully qualified identifier for the instance.
# memory_size_gb - (Required) Redis memory size in GiB.
#authorized_network - (Optional) The full name of the Google Compute Engine network to which the instance is connected.
#  If left unspecified, the default network will be used.
#connect_mode - (Optional) The connection mode of the Redis instance. Default value is DIRECT_PEERING.
#  Possible values are DIRECT_PEERING and PRIVATE_SERVICE_ACCESS.
#reserved_ip_range - (Optional) The CIDR range of internal addresses that are reserved for this instance.
#  If not provided, the service will choose an unused /29 block, for example, 10.0.0.0/29 or 192.168.0.0/29.
#  Ranges must be unique and non-overlapping with existing subnets in an authorized network.
# tier - (Optional) The service tier of the instance. Must be one of these values:
#   BASIC: standalone instance
#   STANDARD_HA: highly available primary/replica instances Default value is BASIC. Possible values are BASIC and STANDARD_HA.
#   transit_encryption_mode - (Optional) The TLS mode of the Redis instance, If not provided, TLS is disabled for the instance.
resource "google_redis_instance" "main" {
  authorized_network      = google_compute_network.main.id
  connect_mode            = "DIRECT_PEERING"
  location_id             = var.zone
  memory_size_gb          = 1
  name                    = "${var.basename}-cache"
  project                 = var.project_id
  redis_version           = "REDIS_6_X"
  region                  = var.region
  reserved_ip_range       = "10.137.125.88/29"
  tier                    = "BASIC"
  transit_encryption_mode = "DISABLED"
  depends_on              = [google_project_service.all]
}
