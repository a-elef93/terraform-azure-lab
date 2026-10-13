variable "location" {
  description = "Azure region"
  type        = string
  default     = "swedencentral"
}

variable "resource_group_name" {
  description = "Resource name"
  type        = string
  default     = "rg-terraform-lab"
}

variable "vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_D2als_v6"
}

variable "db_password" {
  type      = string
  sensitive = true
}
