resource "azurerm_container_group" "this" {
  name                = var.container_group_name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = var.os_type
  restart_policy      = var.restart_policy

  ip_address_type             = var.ip_address_type
  dns_name_label              = var.dns_name_label
  dns_name_label_reuse_policy = var.dns_name_label_reuse_policy
  subnet_ids                  = var.subnet_ids
  exposed_port                = null # Automatically set based on containers[*].ports

  dynamic "container" {
    for_each = var.containers

    content {
      name   = container.value["name"]
      image  = container.value["image"]
      cpu    = container.value["cpu"]
      memory = container.value["memory"]

      environment_variables        = container.value["environment_variables"]
      secure_environment_variables = container.value["secure_environment_variables"]

      dynamic "ports" {
        for_each = container.value["ports"]

        content {
          port     = ports.value["port"]
          protocol = ports.value["protocol"]
        }
      }

      dynamic "volume" {
        for_each = container.value["volumes"]

        content {
          name       = volume.value["name"]
          mount_path = volume.value["mount_path"]

          secret = volume.value["secret"]

          storage_account_name = volume.value["storage_account_name"]
          storage_account_key  = volume.value["storage_account_key"]
          share_name           = volume.value["share_name"]
        }
      }
    }
  }

  dynamic "dns_config" {
    for_each = var.dns_config != null ? [var.dns_config] : []

    content {
      nameservers = dns_config.value["nameservers"]
    }
  }

  dynamic "image_registry_credential" {
    for_each = var.image_registry_credentials

    content {
      server                    = image_registry_credential.value["server"]
      username                  = image_registry_credential.value["username"]
      password                  = image_registry_credential.value["password"]
      user_assigned_identity_id = image_registry_credential.value["user_assigned_identity_id"]
    }
  }

  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []

    content {
      type         = identity.value["type"]
      identity_ids = identity.value["identity_ids"]
    }
  }

  diagnostics {
    log_analytics {
      workspace_id  = var.log_analytics_workspace_id
      workspace_key = var.log_analytics_workspace_key
    }
  }

  tags = var.tags
}
