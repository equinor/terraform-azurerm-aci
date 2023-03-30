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

module "container" {
  # source = "github.com/equinor/terraform-azurerm-container?ref=v0.0.0"
  source = "../.."

  instance_name       = "ci-${random_id.example.hex}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  ip_address_type             = "None"
  dns_name_label              = null
  dns_name_label_reuse_policy = null
  subnet_ids                  = []

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
}
