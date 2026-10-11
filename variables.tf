variable "location" {
  description = "Azure region"
  type        = string
  default     = "northeurope"
}

variable "resource_group_name" {
  description = "Resource name"
  type        = string
  default     = "rg-terraform-lab"
}
