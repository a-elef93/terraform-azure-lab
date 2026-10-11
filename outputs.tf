output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.lab.id
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.lab.name
}

output "vm_public_ip" {
  description = "Public IP address for VM"
  value       = azurerm_public_ip.vm.ip_address
}
