
resource "azurerm_resource_group" "demo" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    project     = "sops-azure-demo"
    environment = "learning"
    managed_by  = "terraform"
  }
}

resource "azurerm_key_vault" "demo" {
  name                = var.key_vault_name
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  rbac_authorization_enabled = true
  soft_delete_retention_days = 7
  purge_protection_enabled   = true

  tags = {
    project    = "sops-azure-demo"
    managed_by = "terraform"
  }
}

# Allows the current identity to create and manage keys.
# Creating this assignment requires separate Azure RBAC
# permissions to create role assignments.
resource "azurerm_role_assignment" "crypto_officer" {
  scope                = azurerm_key_vault.demo.id
  role_definition_name = "Key Vault Crypto Officer"
  principal_id         = data.azurerm_client_config.current.object_id
  principal_type       = "User"
}

resource "azurerm_key_vault_key" "sops" {
  name         = var.key_name
  key_vault_id = azurerm_key_vault.demo.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "encrypt",
    "decrypt",
    "wrapKey",
    "unwrapKey"
  ]

  depends_on = [
    azurerm_role_assignment.crypto_officer
  ]
}
