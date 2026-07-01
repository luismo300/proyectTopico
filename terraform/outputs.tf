output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}

output "subnet_name" {
  value = azurerm_subnet.subnet.name
}

output "container_name" {
  value = azurerm_container_group.aci.name
}

output "private_ip" {
  value = azurerm_container_group.aci.ip_address
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}