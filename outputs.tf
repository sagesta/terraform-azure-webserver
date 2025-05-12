output "public_ip_address" {
  description = "The public IP address of the web server"
  value       = azurerm_public_ip.web_ip.ip_address
  depends_on  = [azurerm_linux_virtual_machine.web_vm]
}

output "website_url" {
  description = "URL to access the web server"
  value       = "http://${azurerm_public_ip.web_ip.ip_address}"
  depends_on  = [azurerm_linux_virtual_machine.web_vm]
}