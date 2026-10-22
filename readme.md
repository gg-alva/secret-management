# AGE and SOPs
- <b>Encryption</b>: The action of transforming readable information into a secret code.
- <b>Decryption</b>: The inverse action (requires the private key).
- <b>Public Key</b>: A string of characters starting with age1.... You can give it to everyone. It is only used to close the vault (encrypt).
- <b>Private Key / Identity</b>: Ultra-sensitive information stored in your keys.txt file. Only it can open the vault (decrypt).
<hr>

# AGE 
### Age is file encryption too that can be used to encrypt and decrypt the file (here whole file gets encrypted )

- Downloaded the AGE - a file encryption tool
```
sudo apt install age
```
- Check the Version
```
age --version

age-keygen --version
```
- To create the Key
```
age-keygen
```
This will get the output in the terminal and can store it as a secret
```
# created: 2026-10-22T14:14:37+05:30
# public key: age1aa<yourpublic key>
AGE-SECRET-KEY-<59alphabet+number combination>
```
- To Store it in the file
```
age-keygen --output=keys.txt
cat keys.txt
```
- This is a demo secret.yaml file to experiment on.
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-dummy-secret
  namespace: default
type: Opaque
data:
  username: my-username
  password: my-super-secret-password
```
- To ENCRYPT the yaml file using the AGE
```
age --encrypt --recipient=<public-key> --output=secret.age secret.yaml
```
The above command will create a secret.age file that is encrypted and is in binary 
```
age-encryption.org/v1
-> X25519 EZpdyzxmQxnh3Ex0GXPESUjdYgSJYMQadb/47SBunX8
WefJY8RbP6m9adzVgUe0eaaxIXb/yXihUZAsAkgtSOA
--- QrTM/N/Y4+0yO00WhHXw/l+rX8GXnbmOyzakV+MSD/8
?�y�rZL�r&LS��E�
Qx��"}�&�����R]����7D��Ugg�e�RYj4�ft�^lELa�3�������xZ�w�K�"����^�Uu���wG�����j�,$
����RZ�l��W͐Q�LF�2B4�lV]k���\���M�w[y����a��;���	��j�)k0gM�Gz�Y�N����ݺ̠�%uo�ǽ�':����Ґ�	�B}����9��
```
so to keep this in a readable format SOPS is used

- To DECRYPT the secret.age
```
age --decrypt --identity=keys.txt secret.age > secret-decrypted.yaml
```
- Check the difference 
```
diff secret.yam secret-decrypted.yaml
```
<hr>

# SOPS
### SOPS is used to make sure that the given file is in the readable format and encrypts the only required parts or key-value pairs and rest of them will remain as it is.

- To ENCRYPT the secret.yaml
```yaml
sops --encrypt secret.yaml #this will give the encrypted file in the terminal
# or
sops --encrypt=encrypted.yaml secret.yaml
# or
sops --encrypt secret.yaml > secret-encryptsops.yaml
```

secret-encryptsops.yaml
```yaml
apiVersion: v1
kind: Secret
metadata:
    name: my-dummy-secret
    namespace: default
type: Opaque
data:
    # Values must be base64 encoded strings
    username: ENC[AES256_GCM,data:4dpZzWnHXWqe/ds=,iv:5UwDrwLRbmhzz+NkdVD/ABlXdAevLNJm3H6m3lZ+DcQ=,tag:SdAs1afvA0gnEmsGH2C9fg==,type:str]
    password: ENC[AES256_GCM,data:8ng7RnMN68uhkO556/ZQJ86DSINfPePO,iv:pB/YG2I2fZZ6xMmMPe4x+E0yGgO40Rg/DrWb5fQ5XdA=,tag:QX46WlosDhwSf0wfXcizWw==,type:str]
sops:
    age:
        - enc: |
            -----BEGIN AGE ENCRYPTED FILE-----
            YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0+IFgyNTUxOSA0c3hJQ3pRZnk4ZXpMUkNx
            a2FQYUNSeEVJazdraE5GMm9Vdi9NOVllS1dnCmN2TWljT2cvc0hMc2xrdHlKVGQv
            MFZQdzljMllUN0VWWHhBMEt3S1dVaVUKLS0tIHgxbjRycllLZ1F3ZEFCeWZjZ240
            QWUvK2hUaFVVUXFlNTdzY0tSOW93dm8KN/u8XAh4Oa/LQA22sR2CIYK45+2eYeor
            Mh59WlRq2QYgpxfFgPO9qGzfO8YFbuXcS2PQawNuGerqzwbsLBSkVA==
            -----END AGE ENCRYPTED FILE-----
          recipient: age1w9rlzskzz0pp46p2ncehswd7q24wqv8ak634g7zdc75e4zp4kyysnn3y4l
    encrypted_regex: ^(username|password)$
    lastmodified: "2026-10-22T10:27:31Z"
    mac: ENC[AES256_GCM,data:YaRvB0r1pndMo2X+dyWsIDJ3bb0umIlAGrKdxaPTw+aPTJ+vS8rQgrCkbMhfCOZXnK/k9I3xhiNCpjKeY3Yb5iSa6aBKqMt6TdyscYiLHf2ILqFgRiiYV0tT7NRfE+VRvk7hRjwAi91+CdIXGHhHybUx2oOcbkHhL+g0vAHlBPY=,iv:bf+J8OvvXyl7nqNdP9auXX9wLCiDMJMUZF56nCuDKIA=,tag:u7X5BLCtU+zQ3X4RKm1X4A==,type:str]
    version: 3.13.3

```

- The .sops.yaml file provides the regex to encrypt the files fields.
```
creation_rules:
  - path_regex: /*secret(\.encrypted)?.yaml$
    encrypted_regex: "^(username|password)$"
    age: <public-key>
```
Here the username and password will be encryptesd and at the end the file will have the sops with the code required to decrypt the username  and password

- To DECRYPT the secret

```
export SOPS_AGE_KEY_FILE="$(pwd)/keys.txt"
```
```
sops --decrypt secret-encryptsops.yaml
```
while decryption there might be changes in the indentation but it works perfectly

- Move the Keys.txt to the config file so that it can look for keys easily
```
mv keys.txt ~/.config/sops/age/keys.txt
```
