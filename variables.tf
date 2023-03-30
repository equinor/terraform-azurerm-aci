variable "instance_name" {
  description = "The name of this Container Instance."
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
  description = "A list of containers to create for this Container Instance."

  # WARNING: It's not yet possible to mark individual object properties as sensitive (hashicorp/terraform#32414).
  #
  # The following properties should've been marked as sensitive:
  # - secure_environment_variables
  # - volumes[*].secret
  # - volumes[*].storage_account_key
  #
  # As a result, the value of these properties could be exposed if used as the value of a non-sensitive
  # argument for a resource inside this module. Use these properties at your own risk!
  #
  # An option would be to use the "sensitive()" function to force the values to be sensitive before passing them to this
  # module. If you're passing a sensitive attribute from another resource, it will most likely already be marked as
  # sensitive by that resource.
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
    })))
  }))
}

variable "os_type" {
  description = "The OS type of this Container Instance."
  type        = string
  default     = "Linux"
}

variable "restart_policy" {
  description = "The restart policy of this Container Instance."
  type        = string
  default     = "Always"
}

variable "ip_address_type" {
  description = "The IP address type of this Container Instance."
  type        = string
  default     = "None"
}

variable "dns_name_label" {
  description = "A DNS name label for this Container Instance."
  type        = string
  default     = null
}

variable "dns_name_label_reuse_policy" {
  description = "The reuse policy to use for the DNS name label."
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "A list of subnet IDs to be assigned to this Container Instance."
  type        = list(string)
  default     = null
}

variable "dns_config" {
  description = "The DNS configuration of this Container Instance."

  type = object({
    nameservers = list(string)
  })

  default = null
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}
