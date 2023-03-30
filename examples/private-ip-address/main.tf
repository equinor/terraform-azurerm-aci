provider "azurerm" {
  features {}
}

resource "random_id" "example" {
  byte_length = 8
}

resource "azurerm_resource_group" "example" {
  name     = "rg-${random_id.example.hex}"
  location = var.location
}

module "log_analytics" {
  source = "github.com/equinor/terraform-azurerm-log-analytics?ref=v1.4.0"

  workspace_name      = "log-${random_id.example.hex}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
}

module "network" {
  source = "github.com/equinor/terraform-azurerm-network?ref=v1.7.0"

  vnet_name           = "vnet-${random_id.example.hex}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_spaces      = ["10.0.0.0/16"]

  subnets = {
    "aci" = {
      name             = "snet-aci-${random_id.example.hex}"
      address_prefixes = ["10.0.1.0/24"]

      delegation = [{
        name                       = "aci-delegation"
        service_delegation_name    = "Microsoft.ContainerInstance/containerGroups"
        service_delegation_actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }]
    }
  }
}

module "container" {
  # source = "github.com/equinor/terraform-azurerm-container?ref=v0.0.0"
  source = "../.."

  instance_name               = "ci-${random_id.example.hex}"
  resource_group_name         = azurerm_resource_group.example.name
  location                    = azurerm_resource_group.example.location
  log_analytics_workspace_id  = module.log_analytics.workspace_customer_id
  log_analytics_workspace_key = module.log_analytics.primary_shared_key

  ip_address_type = "Private"
  subnet_ids      = [module.network.subnet_ids["aci"]]

  containers = [{
    name   = "hello-world"
    image  = "mcr.microsoft.com/azuredocs/aci-helloworld:latest"
    cpu    = 1
    memory = 1

    ports = [{
      port = 443
    }]
  }]
}
