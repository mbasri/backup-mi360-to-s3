variable "region" {
  type        = string
  description = "Region to use for create the bastion (default: Paris)"
  default     = "eu-west-3"
}

variable "tags" {
  type        = map
  description = "Default tags to be applied on 'Xiaomi Mi Home Security Camera 360 Backup' infrastructure"
  default     = {
    "Billing:Organisation"     = "Kibadex"
    "Billing:OrganisationUnit" = "Kibadex Labs"
    "Billing:Application"      = "Xiaomi Mi Home Security Camera 360 Backup"
    "Billing:Environment"      = "Prod"
    "Technical:Terraform"      = "True"
    "Technical:Version"        = "1.0.0"
    #"Technical:Comment"        = "Managed by Terraform"
    #"Security:Compliance"      = "HIPAA"
    #"Security:DataSensitity"   = "1"
    "Security:Encryption"      = "False"
  }
}

variable "name" {
  type        = map
  description = "Default tags name to be applied on the infrastructure for the resources names"
  default     = {
    Application      = "mic"
    Environment      = "prd"
    Organisation     = "kbd"
    OrganisationUnit = "lab"
  }
}
