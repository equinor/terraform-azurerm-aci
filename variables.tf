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
  }))
}

variable "os_type" {
  description = "The OS type of this Container Instance."
  type        = string
  default     = "Linux"
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}
