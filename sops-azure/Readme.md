### Login to Azure 
```
az login
az account list --output table
az account set --subscription "<YOUR_SUBSCRIPTION_ID>"

az account show --output table

```
### Set the variables 
```
export LOCATION="centralindia"
export RG="rg-sops-keyvault-demo"
export KV_NAME="sopsdemo-$(openssl rand -hex 4)"
export KEY_NAME="sops-encryption-key"

echo "$KV_NAME"
```
### create the resource grp and vault
```
az group create \
  --name "$RG" \
  --location "$LOCATION"

az keyvault create \
  --name "$KV_NAME" \
  --resource-group "$RG" \
  --location "$LOCATION" \
  --enable-rbac-authorization true \
  --enable-purge-protection true
```
### Verify the vault
```
az keyvault show \
  --name "$KV_NAME" \
  --query "{name:name, uri:properties.vaultUri, location:location}" \
  --output table
```
### Create an RSA key
```
az keyvault key create \
  --vault-name "$KV_NAME" \
  --name "$KEY_NAME" \
  --kty RSA \
  --size 2048 \
  --ops encrypt decrypt wrapKey unwrapKey
```
### If you face ForbiddenByRbac error then use the below command to get a the rbac permission
- With RBAC enabled, the identity you're using needs suitable permissions to create and use keys. a vault-scoped Key Vault Crypto Officer role can manage cryptographic keys, while Key Vault Crypto User is appropriate for cryptographic use. Use the least privilege needed for your specific operations.
```
az role assignment create \
  --role "Key Vault Crypto Officer" \
  --assignee-object-id "<OBJECT ID>" \
  --assignee-principal-type "User" \
  --scope "/subscriptions/<SUBSCRIPTION ID>/resourcegroups/<RESOURCE GROUP>/providers/microsoft.keyvault/vaults/<KEY VAULT NAME>"
```
- The error ForbiddenByRbac means your Azure identity (Object ID) does not have the required Azure RBAC role permissions to create a key inside the Key Vault, even if you are an Owner or Contributor of the Subscription/Resource Group.
- Azure Key Vault data-plane actions (like creating keys, secrets, or certificates) require specific Key Vault roles.
- need to assign yourself the Key Vault Crypto Officer role (which grants the Microsoft.KeyVault/vaults/keys/create/action permission)

### Retrieve the key URL:
```
export KEY_URL="$(
  az keyvault key show \
    --vault-name "$KV_NAME" \
    --name "$KEY_NAME" \
    --query key.kid \
    --output tsv
)"

echo "$KEY_URL"
```
### It will resemble this format:
https://your-vault-name.vault.azure.net/keys/sops-encryption-key/<key-version>

<hr>

### Create secret.yaml:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: demo-app-secret
  namespace: default
type: Opaque
stringData:
  username: my-username
  password: my-super-secret-password
data:
  username: bXktdXNlcm5hbWUK
  password: bXktc3VwZXItc2VjcmV0LXBhc3N3b3JkCg==
```
### Create a .sops.yaml file in the root of your demo directory:
```yaml
creation_rules:
  - path_regex: /*secret(\.encrypted)?.yaml$
    encrypted_regex: "^(username|password)$"
    azure_keyvault: https://YOUR-VAULT-NAME.vault.azure.net/keys/sops-encryption-key
```

### Encrypt and decrypt the file
- Encrypt the YAML
```
sops --encrypt secret.yaml > secret.enc.yaml
```

- Inspect the encrypted result:
```
cat secret.enc.yaml
```
- Decrypt the file
```
sops --decrypt secret.enc.yaml > secret.decrypt.yaml
```

### makesure to add the secrets files to gitignore and only commit the encrypted file
```
# Plaintext and decrypted secrets
secret.yaml
secret.decrypted.yaml
keys.txt

```