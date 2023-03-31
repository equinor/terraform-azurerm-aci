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

module "storage" {
  source = "github.com/equinor/terraform-azurerm-storage?ref=v10.2.0"

  account_name                 = "st${random_id.example.hex}"
  resource_group_name          = azurerm_resource_group.example.name
  location                     = azurerm_resource_group.example.location
  log_analytics_workspace_id   = module.log_analytics.workspace_id
  shared_access_key_enabled    = true
  network_rules_default_action = "Allow"
}

resource "azurerm_storage_share" "example" {
  name                 = "tools"
  storage_account_name = module.storage.account_name
  quota                = 5
}

module "container" {
  # source = "github.com/equinor/terraform-azurerm-container?ref=v0.0.0"
  source = "../.."

  instance_name               = "ci-${random_id.example.hex}"
  resource_group_name         = azurerm_resource_group.example.name
  location                    = azurerm_resource_group.example.location
  log_analytics_workspace_id  = module.log_analytics.workspace_customer_id
  log_analytics_workspace_key = module.log_analytics.primary_shared_key
  os_type                     = "Linux"
  restart_policy              = "Always"

  ip_address_type             = "None"
  dns_name_label              = null
  dns_name_label_reuse_policy = null
  subnet_ids                  = null

  containers = [
    {
      name   = "hello-world"
      image  = "mcr.microsoft.com/azuredocs/aci-helloworld:latest"
      cpu    = 1
      memory = 1

      ports = [{
        port     = 8080
        protocol = "TCP"
      }]

      environment_variables = {
        "MY_VARIABLE" = "value"
      }

      secure_environment_variables = {
        "SECURE_VARIABLE" = "secure_value"
      }

      volumes = [
        {
          name       = "tools-volume"
          mount_path = "/aci/tools"

          storage_account_name = module.storage.account_name
          storage_account_key  = module.storage.primary_access_key
          share_name           = azurerm_storage_share.example.name
        },
        {
          name       = "secret-volume"
          mount_path = "/aci/secrets"

          secret = {
            "secret.txt" = base64encode(file("${module.path}/secret.txt}"))
          }
        }
      ]
    }
  ]

  dns_config = null # Only supported when "ip_address_type" is "Private"
}
