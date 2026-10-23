
variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "location" {
  description = "Azure region for the demo"
  type        = string
  default     = "centralindia"
}

variable "resource_group_name" {
  description = "Resource group for the SOPS demo"
  type        = string
  default     = "rg-sops-terraform-demo"
}

variable "key_vault_name" {
  description = "Globally unique Azure Key Vault name"
  type        = string

  validation {
    condition = (
      length(var.key_vault_name) >= 3 &&
      length(var.key_vault_name) <= 24 &&
      can(regex("^[a-zA-Z][a-zA-Z0-9-]*[a-zA-Z0-9]$", var.key_vault_name))
    )
    error_message = "Use a 3-24 character vault name starting with a letter and ending with a letter or digit."
  }
}

variable "key_name" {
  description = "Name of the SOPS encryption key"
  type        = string
  default     = "sops-encryption-key"
}
