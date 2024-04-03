variable "project" {
  description = "The GCP project ID"
  type = string
  default = "csye-6225-terraform-packer"
}

variable "region" {
  description = "The GCP region"
  type = string
  default = "us-central1"
}

variable "zone" {
    description = "The GCP zone"
    type = string
    default = "us-central1-a"
}

variable "vpc_names" {
  description = "Names of the VPCs to create"
  type        = list(string)
  default     = ["vpc1", "vpc2"]
}

variable "network_routing_mode" {
  description = "routing mode for VPC"
  type = string
  default = "REGIONAL"
}

variable "next_hop_gateway" {
  description = "gateway for webapp"
  type = string
  default = "default-internet-gateway"
}

variable "vpcs" {
  description = "Map of VPC configurations"
  type = map(object({
    region                 = string
    webapp_subnet_cidr     = string
    db_subnet_cidr         = string
  }))
}

variable "webapp_subnet_cidr" {
    description = "web_subnet description"
    type = string
    default = "10.0.1.0/24"
}

variable "dbapp_subnet_cidr" {
    description = "db_subnet description"
    type = string
    default = "10.0.2.0/24"
}
variable "instance_vpc_name" {
  description = "Name of the VPC for the custom instance"
  type        = string
  default     = "vpc1"
}
variable "machine_type" {
  description = "Machine type"
  type = string
  default = "e2-medium"
}

variable "size" {
  description = "Disk size"
  default = "100"
}

variable "type" {
  description = "Boot disk type"
  default = "pd-standard"
}

variable "image" {
  description = "Disk image"
  default = "centos-stream-8"
}

variable "protocol" {
  description = "protocol type"
  default = "tcp"
}

variable "httpport" {
  description = "http ports allowed"
  default = "8080"
}

variable "sshport" {
  description = "http ports denied"
  default = "22"
}

variable "source_ranges" {
  type        = string
  default     = "0.0.0.0/0"
  description = "Entire source range"
}

variable "dest_range" {
  description = "dest_range"
  default = "0.0.0.0/0"
}

variable "database_version" {
  type        = string
  default     = "POSTGRES_15"
  description = "Database version for DB instance"
}

variable "pass_Len" {
  type        = number
  default     = 16
  description = "Database random password length"
}

variable "webapp_name" {
  type        = string
  default     = "webapp"
  description = "Application all constant"
}

variable "db_tier" {
  type        = string
  default     = "db-custom-1-3840"
  description = "Database vm instance tier"
}

variable "db_availability_type" {
  type        = string
  default     = "REGIONAL"
  description = "Database availability type"
}

variable "db_disk_size" {
  type        = number
  default     = 100
  description = "Database disk size"
}

variable "db_disk_type" {
  type        = string
  default     = "PD_SSD"
  description = "Database disk type - hdd/ssd"
}

variable "db_address_purpose" {
  type        = string
  default     = "VPC_PEERING"
  description = "Database global compute address purpose"
}

variable "db_address_prefix" {
  type        = number
  default     = 24
  description = "Database global compute address cidr prefix"
}

variable "db_address_type" {
  type        = string
  default     = "INTERNAL"
  description = "Database global compute address type"
}

variable "service_network" {
  type        = string
  default     = "servicenetworking.googleapis.com"
  description = "Private network access"
}

variable "ingress" {
  type        = string
  default     = "INGRESS"
  description = "Firewall incoming requests"
}

variable "firewall_allow_priority" {
  type        = number
  default     = 1000
  description = "Priority for allowing app port firewall"
}

variable "db_port" {
  type        = string
  default     = "5432"
  description = "Cloud PostgreSQL port"
}

variable "firewall_deny_priority" {
  type        = number
  default     = 1001
  description = "Priority for denying app port firewall"
}

variable "dns_zone_name" {
  type        = string
  default     = "webapp"
  description = "DNS zone for Cloud DNS"
}

variable "dns_name" {
  type        = string
  default     = "babuaravind-gururaj.me."
  description = "Website DNS"
}

variable "mailgun_api_key" {
  type = string
  default = "68cce657fa6d365a396c07445aaf856f-f68a26c9-fb58f577"
  description = "mailgun api key to send email"
}

variable "sender_domain" {
  type = string
  default = "babuaravind-gururaj.me"
  description = "my registered domain"
}

variable "function_entry" {
  type = string
  default = "SendVerificationEmail"
  description = "entry point for the cloud function"
}

variable "go_runtime" {
  type = string
  default = "go121"
  description = "runtime go environment"
}

variable "cloud_func_topic" {
  type = string
  default = "verify_email"
  description = "cloud function topic"
}

variable "cloud_func_memory" {
  type  = string
  default = "256M"
  description = "cloud function available memory"  
}

variable "cloud_func_timeout" {
  type  =  number
  default = 60
  description = "cloud function timeout value"
}

variable "cloud_func_ingress" {
  type  = string
  default = "ALLOW_INTERNAL_ONLY"
  description = "ingress for cloud function"
}

variable "cloud_func_role" {
  type  = string
  default = "roles/cloudfunctions.invoker"
  description = "cloud function role"
}

# variable "cloud_func_event_type" {
#   type  =  string
#   default = "google.cloud.pubsub.topic.v1.messagePublished"
#   description = "Event type for cloud function event trigger"
# }

variable "instance_group_manager" {
  type = string
  default = "app-instance-group-manager"
  description = "Group manager for instance"
}

variable "named_port_type" {
  type = string
  default = "http"
  description = "Request type in named port"
}

variable "cpu_utlization" {
  type = number
  default = 0.05
  description = "CPU utilization percentage"
}

variable "max_replicas" {
  type = number
  default = 2
  description = "Replicas max"
}

variable "min_replicas" {
  type = number
  default = 1
  description = "Replicas min"
}

variable "https_protocol" {
  type = string
  default = "https"
  description = "Request type"
}

variable "region_instance_name" {
  type = string
  default = "l7-xlb-backend-template"
  description = "Region instance name"
}

variable "lb_machine_type" {
  type = string
  default = "n1-standard-1"
  description = "Region machine type"
}

variable "lb_proxy" {
  type = string
  default = "projects/csye-6225-terraform-packer/global/sslCertificates/webapp-certificate"
  description = "lb proxy"
}

# variable "lb_firewall_source_range" {
#   type =  list(string)
#   default = ["130.211.0.0/22", "35.191.0.0/16"]
#   description = "firewall source range"
# }

variable "google_compute_firewall_name" {
  type = string
  default = "fw-allow-health-check"
  description = "firewall name"
}

variable "health_check_name" {
  type = string
  default = "l7-xlb-basic-check"
  description = "health check name"
}

variable "backend_service_name" {
  type = string
  default = "l7-xlb-backend-service"
  description = "health check name"
}

variable "url_map_name" {
  type = string
  default = "regional-l7-xlb-map"
  description = "url map name"
}

variable "forwarding_rule_name" {
  type = string
  default = "l7-xlb-forwarding-rule"
  description = "forwarding rule name"
}