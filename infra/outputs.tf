output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "public_ip_address1" {
  value = azurerm_linux_virtual_machine.my_terraform_vm.public_ip_address
}

output "public_ip_address2" {
  value = azurerm_linux_virtual_machine.my_terraform_vm2.public_ip_address
}

output "public_ip_address3" {
  value = azurerm_linux_virtual_machine.my_terraform_vm3.public_ip_address
}

output "tls_private_key" {
  value     = tls_private_key.example_ssh.private_key_pem
  sensitive = true
}