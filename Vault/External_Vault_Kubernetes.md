## Integrate a Kubernetes cluster with an external Vault
In this doc, you will run Vault locally, and start a Kubernetes cluster with minikube. You will deploy an application that retrieves secrets directly from Vault via a Kubernetes service and secret injection via Vault Agent Injector.

1. Make sure vault is running
```
systemctl status vault
```
2. Export an environment variable for the vault CLI to address the Vault server.
```
 export VAULT_ADDR='http://127.0.0.1:8200'
```
3. Login with the root token.
```
vault operator unseal
vault login
```
4. Create a secret at path secret/devwebapp/config with a username and password.
```
vault kv put secret/devwebapp/config username='techielins' password='DevOps#400'
```
5. 

6. 

7. 
