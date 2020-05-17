variable "region" {
  type        = string
  description = "Region to use for create the bastion (default: Paris)"
  default     = "eu-west-3"
}

variable "tags" {
  type        = map
  description = "Default tags to be applied on 'Xiaomi Mi Home Security Camera 360 Backup' infrastructure"
  default = {
    "Billing:Organisation"     = "Kibadex"
    "Billing:OrganisationUnit" = "Kibadex Labs"
    "Billing:Application"      = "Xiaomi"
    "Billing:Environment"      = "Prod"
    "Billing:Description"      = "Xiaomi Mi Home Security Camera 360 Backup"
    "Technical:Terraform"      = "True"
    "Technical:Version"        = "1.0.0"
    "Security:Compliance"      = "HIPAA"
    "Security:DataSensitity"   = "1"
    "Security:Encryption"      = "False"
  }
}
