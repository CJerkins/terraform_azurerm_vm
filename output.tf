# Virtal Machine Details
output "virtual_machine_id" {
  value = azurerm_linux_virtual_machine.linux.*.id
}

output "virtual_machine_name" {
  value = azurerm_linux_virtual_machine.linux.*.name
}

output "virtual_machine_private_ip" {
  value = azurerm_network_interface.dynamic.*.private_ip_address
}

output "virtual_machine_public_ip" {
  value = azurerm_public_ip.primary.*.ip_address
}

# Credentials
// output "admin_password" {
//   value     = local.admin_password
//   sensitive = true
// }

// output "automation_account_ssh_private" {
//   value     = tls_private_key.automation_account.private_key_pem
//   sensitive = true
// }

// output "automation_account_ssh_public" {
//   value = local.admin_ssh_key
// }

