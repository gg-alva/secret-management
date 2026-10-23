
output "resource_group_name" {
  description = "Terraform-managed resource group"
  value       = azurerm_resource_group.demo.name
}

output "key_vault_name" {
  description = "Azure Key Vault name"
  value       = azurerm_key_vault.demo.name
}

output "key_vault_uri" {
  description = "Base URI of Azure Key Vault"
  value       = azurerm_key_vault.demo.vault_uri
}

output "sops_key_url" {
  description = "Versioned Key Vault key URI"
  value       = azurerm_key_vault_key.sops.id
}

output "sops_key_versionless_url" {
  description = "Key URI without the version component"
  value       = azurerm_key_vault_key.sops.resource_versionless_id
}
