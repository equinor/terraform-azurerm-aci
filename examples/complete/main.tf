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

module "container" {
  # source = "github.com/equinor/terraform-azurerm-container?ref=v0.0.0"
  source = "../.."

  instance_name               = "ci-${random_id.example.hex}"
  resource_group_name         = azurerm_resource_group.example.name
  location                    = azurerm_resource_group.example.location
  log_analytics_workspace_id  = module.log_analytics.workspace_customer_id
  log_analytics_workspace_key = module.log_analytics.primary_shared_key

  ip_address_type             = "None"
  dns_name_label              = null
  dns_name_label_reuse_policy = null
  subnet_ids                  = null

  containers = [{
    name   = "hello-world"
    image  = "mcr.microsoft.com/azuredocs/aci-helloworld:latest"
    cpu    = 1
    memory = 1

    ports = [{
      port     = 443
      protocol = "TCP"
    }]
  }]

  dns_config = null # Only supported when "ip_address_type" is "Private"
}
