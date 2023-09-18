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
vault secrets enable -version=2 kv
vault kv put secrets/devwebapp/config username='techielins' password='DevOps#400'
```
5. Verify that the secret is stored at the path secret/devwebapp/config.
```
vault kv get -format=json secrets/devwebapp/config | jq ".data.data"
```
6. The Vault server, with secret, is ready to be addressed by a Kubernetes cluster and the pods deployed in it.

## Start Minikube
1. Start minikube
```
minikube start --memory 3560
```
2. Verify the status of the minikube cluster.
```
minikube status
```
## Determine the Vault address
1. Start a minikube SSH session.
```
minikube ssh
```
2. Within this SSH session, Retrieve the status of the Vault server to verify network connectivity.
```
dig +short ciserver.local | xargs -I{} curl -s http://{}:8200/v1/sys/seal-status
```
The output displays that Vault is initialized and unsealed. This confirms that pods in the cluster are able to reach Vault
3. Exit the minikube SSH session.
4. Create a variable named EXTERNAL_VAULT_ADDR to capture the vault address.
```
EXTERNAL_VAULT_ADDR=$(minikube ssh "dig +short ciserver.local" | tr -d '\r')
```
5. Verify that the variable has an ip address.
```
echo $EXTERNAL_VAULT_ADDR
```
## Deploy application with hard-coded Vault address
1. Create a Kubernetes service account named internal-app.
```
kubectl create sa internal-app
```
2. Define a pod named devwebapp with the web application that sets the VAULT_ADDR to EXTERNAL_VAULT_ADDR.
```
cat > devwebapp.yaml <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: devwebapp
  labels:
    app: devwebapp
spec:
  serviceAccountName: internal-app
  containers:
    - name: app
      image: burtlo/devwebapp-ruby:k8s
      env:
      - name: VAULT_ADDR
        value: "http://$EXTERNAL_VAULT_ADDR:8200"
      - name: VAULT_TOKEN
        value: root
EOF
```
3. Create the devwebapp pod.
```
kubectl apply -f devwebapp.yaml
```
4. Get all the pods in the default namespace.
```
kubectl get pods
```
Wait until the devwebapp pod reports that is running and ready (1/1).
5. Request content served at localhost:8080 from within the devwebapp pod
```

   




