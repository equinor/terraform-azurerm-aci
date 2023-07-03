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

module "aci" {
  # source = "github.com/equinor/terraform-azurerm-aci?ref=v0.0.0"
  source = "../.."

  container_group_name        = "ci-${random_id.example.hex}"
  resource_group_name         = azurerm_resource_group.example.name
  location                    = azurerm_resource_group.example.location
  log_analytics_workspace_id  = module.log_analytics.workspace_customer_id
  log_analytics_workspace_key = module.log_analytics.primary_shared_key

  ip_address_type             = "Public"
  dns_name_label              = "aci-label-${random_id.example.hex}"
  dns_name_label_reuse_policy = "TenantReuse"

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
