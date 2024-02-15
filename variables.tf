variable "project" {
  description = "The GCP project ID"
  type = string
  default = "csye-6225-terraform"
}

variable "region" {
  description = "The GCP region"
  type = string
  default = "us-central1"
}

variable "zone" {
    description = "The GCP zone"
    type = string
    default = "us-central1-c"
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