output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.lab.id
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.lab.name
}
