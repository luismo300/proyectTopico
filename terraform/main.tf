resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "aci-delegation"

    service_delegation {
      name = "Microsoft.ContainerInstance/containerGroups"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action"
      ]
    }
  }
}

resource "azurerm_container_registry" "acr" {
  name                = var.acr_name # Debe ser un nombre único globalmente
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku           = "Basic"
  admin_enabled = false
}

resource "azurerm_container_group" "aci" {
  name                = var.container_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_address_type = "Private"
  os_type         = "Linux"

  subnet_ids = [
    azurerm_subnet.subnet.id
  ]

  identity {
  type = "SystemAssigned"
  }

  image_registry_credential {
  server   = azurerm_container_registry.acr.login_server
  identity = "System"
  }

  container {
    name   = "nginx"
    image = "${azurerm_container_registry.acr.login_server}/nginx:latest"
    cpu    = "1"
    memory = "1"

    ports {
      port     = 80
      protocol = "TCP"
    }
  }
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_container_group.aci.identity[0].principal_id
  
  depends_on = [
    azurerm_container_group.aci
  ]
}