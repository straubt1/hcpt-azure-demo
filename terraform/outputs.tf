output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "vm_name" {
  description = "Name of the RHEL 9 VM"
  value       = azurerm_linux_virtual_machine.rhel9.*.name
}

output "vm_public_ip" {
  description = "Public IP address of the RHEL 9 VM"
  value       = [for ip in azurerm_public_ip.vm : "http://${ip.ip_address}"]
}

output "vm_private_ip" {
  description = "Private IP address of the RHEL 9 VM"
  value       = azurerm_linux_virtual_machine.rhel9.*.private_ip_address
}
