variable "container_group_name" {
  description = "The name of this Container Group."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group to create the resources in."
  type        = string
}

variable "location" {
  description = "The location to create the resources in."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "The workspace (customer) ID of the Log Analytics workspace to send diagnostics to."
  type        = string
}

variable "log_analytics_workspace_key" {
  description = "The shared key of the Log Analytics workspace to send diagnostics to."
  type        = string
  sensitive   = true
}

variable "containers" {
  description = "A list of containers to create for this Container Group."

  type = list(object({
    name   = string
    image  = string
    cpu    = string
    memory = string

    ports = optional(list(object({
      port     = number
      protocol = optional(string, "TCP")
    })), [])

    environment_variables        = optional(map(string), {})
    secure_environment_variables = optional(map(string), {}) # TODO: mark as sensitive (hashicorp/terraform#32414)

    volumes = optional(list(object({
      name       = string
      mount_path = string

      secret = optional(map(string)) # TODO: mark as sensitive (hashicorp/terraform#32414)

      storage_account_name = optional(string)
      storage_account_key  = optional(string) # TODO: mark as sensitive (hashicorp/terraform#32414)
      share_name           = optional(string)
    })), [])
  }))
}

variable "os_type" {
  description = "The OS type of this Container Group."
  type        = string
  default     = "Linux"
}

variable "restart_policy" {
  description = "The restart policy of this Container Group."
  type        = string
  default     = "Always"
}

variable "ip_address_type" {
  description = "The IP address type of this Container Group."
  type        = string
  default     = "None"
}

variable "dns_name_label" {
  description = "A DNS name label for this Container Group."
  type        = string
  default     = null
}

variable "dns_name_label_reuse_policy" {
  description = "The reuse policy to use for the DNS name label."
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "A list of subnet IDs to be assigned to this Container Group."
  type        = list(string)
  default     = null
}

variable "dns_config" {
  description = "The DNS configuration of this Container Group."

  type = object({
    nameservers = list(string)
  })

  default = null
}

variable "image_registry_credentials" {
  description = "A list of image registry credentials to configure for this Container Group."

  type = list(object({
    server                    = string
    username                  = optional(string)
    password                  = optional(string) # TODO: mark as sensitive (hashicorp/terraform#32414)
    user_assigned_identity_id = optional(string)
  }))

  default = []
}

variable "identity" {
  description = "The identity or identities to configure for this Container Group."

  type = object({
    type         = optional(string, "SystemAssigned")
    identity_ids = optional(list(string), [])
  })

  default = null
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}
