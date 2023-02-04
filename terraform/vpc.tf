# Manages a VPC network or legacy network resource on GCP.
#  auto_create_subnetworks - (Optional) When set to true,
#    the network is created in "auto subnet mode" and it will create a subnet for each region automatically across the 10.128.0.0/9 address range.
#  When set to false, the network is created in "custom subnet mode" so the user can explicitly connect subnetwork resources.

resource "google_compute_network" "main" {
  name                    = "${var.basename}-private-network"
  auto_create_subnetworks = true
  project                 = var.project_id
  description             = "Final Project private network"
}

# Represents a Global Address resource. Global addresses are used for HTTP(S) load balancing.
# purpose - (Optional) The purpose of the resource. Possible values include:
#       VPC_PEERING - for peer networks
#       PRIVATE_SERVICE_CONNECT - for (Beta only) Private Service Connect networks

#  address_type - (Optional) The type of the address to reserve.
#       EXTERNAL indicates public/external single IP address.
#       INTERNAL indicates internal IP ranges belonging to some network. Default value is EXTERNAL. Possible values are EXTERNAL and INTERNAL.     

# network - (Optional) The URL of the network in which to reserve the IP range.
#      The IP range must be in RFC1918 space. The network cannot be deleted if there are any reserved IP ranges referring to it.
#      This should only be set when using an Internal address.

# prefix_length - (Optional) The prefix length of the IP range.
#     If not present, it means the address field is a single IP address.
#     This field is not applicable to addresses with addressType=EXTERNAL, or addressType=INTERNAL when purpose=PRIVATE_SERVICE_CONNECT
resource "google_compute_global_address" "main" {
  name          = "${var.basename}-vpc-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.main.id
  project       = var.project_id
  depends_on    = [google_project_service.all]
}
# Manages a private VPC connection with a GCP service provider.

# network - (Required) Name of VPC network connected with service producers using VPC peering.

# service - (Required) Provider peering service that is managing peering connectivity for a service provider organization.
#  For Google services that support this functionality it is 'servicenetworking.googleapis.com'.

# reserved_peering_ranges - (Required) Named IP address range(s) of PEERING type reserved for this service provider.
#  Note that invoking this method with a different range when connection is already established will not reallocate already provisioned service producer subnetworks.
resource "google_service_networking_connection" "main" {
  network                 = google_compute_network.main.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.main.name]
  depends_on              = [google_project_service.all]
}
# Serverless VPC Access connector resource.
# You can use a Serverless VPC Access connector to connect your serverless environment directly to your Virtual Private Cloud (VPC) network, allowing access to Compute Engine virtual machine (VM) instances, Memorystore instances, and any other resources with an internal IP address.

# name - (Required) The name of the resource (Max 25 characters).
# ip_cidr_range - (Optional) The range of internal addresses that follows RFC 4632 notation. Example: 10.132.0.0/28.
# network - (Optional) Name or self_link of the VPC network. Required if ip_cidr_range is set.
# region - (Optional) Region where the VPC Access connector resides. If it is not provided, the provider region is used.
# max_throughput - (Optional) Maximum throughput of the connector in Mbps, must be greater than min_throughput. Default is 300.
# machine_type - (Optional) Machine type of VM Instance underlying connector. Default is e2-micro
# max_instances - (Optional) Maximum value of instances in autoscaling group underlying the connector.
resource "google_vpc_access_connector" "main" {
  project        = var.project_id
  name           = "${var.basename}-vpc-cx"
  ip_cidr_range  = "10.8.0.0/28"
  network        = google_compute_network.main.id
  region         = var.region
  max_throughput = 300
  depends_on     = [google_compute_global_address.main, google_project_service.all]
}
