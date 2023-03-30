resource "azurerm_container_group" "this" {
  name                = var.instance_name
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
    }
  }

  dynamic "dns_config" {
    for_each = var.dns_config != null ? [var.dns_config] : []

    content {
      nameservers = dns_config.value["nameservers"]
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
