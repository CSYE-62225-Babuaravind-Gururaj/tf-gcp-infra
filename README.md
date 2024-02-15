# tf-gcp-infra

## Version 1:
### Infrastructure as a Code setup

- **VPC Configuration**:
  - Create a project in GCloud
  - Setup GCloud CLI
  - Installed Terraform
- **Terraform setup**:
  - Disabled auto-creation of subnets
  - Deleted default routes on creation using 
  - Created two subnets for the VPC (webapp and db)
  - Configured a route for one of the subnets within the VPC (0.0.0.0/0)