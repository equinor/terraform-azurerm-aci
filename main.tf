resource "azurerm_container_group" "this" {
  name                = var.instance_name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = var.os_type

  ip_address_type = "None"

  dynamic "container" {
    for_each = var.containers

    content {
      name   = container.value["name"]
      image  = container.value["image"]
      cpu    = container.value["cpu"]
      memory = container.value["memory"]
    }
  }

  tags = var.tags
}
