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

variable "containers" {
  description = "A list of containers to create for this Container Instance."

  type = list(object({
    name   = string
    image  = string
    cpu    = string
    memory = string

    ports = optional(list(object({
      port     = number
      protocol = optional(string, "TCP")
    })), [])
  }))
}

variable "os_type" {
  description = "The OS type of this Container Instance."
  type        = string
  default     = "Linux"
}

variable "ip_address_type" {
  description = "The IP address type of this Container Instance."
  type        = string
  default     = "None"
}

variable "dns_name_label" {
  description = "A DNS name label for this Container Instance."
  type        = string
  default     = ""
}

variable "dns_name_label_reuse_policy" {
  description = "The reuse policy to use for the DNS name label."
  type        = string
  default     = "Unsecure"
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}
