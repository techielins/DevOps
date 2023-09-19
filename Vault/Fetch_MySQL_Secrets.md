## Deploy MySQL
To deploy a MySQL pod in a Minikube cluster, you need to create a Kubernetes manifest file describing the MySQL deployment and service. Here are the steps to deploy MySQL on Minikube:

1. **Start Minikube**:

   Make sure you have Minikube installed and running. If not, you can start Minikube with the following command:

   ```
   minikube start
   ```

2. **Create a MySQL Kubernetes Manifest**:

   Create a Kubernetes manifest file, e.g., `mysql-deployment.yaml`, with the following content:

   ```yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: mysql-deployment
   spec:
     replicas: 1
     selector:
       matchLabels:
         app: mysql
     template:
       metadata:
         labels:
           app: mysql
       spec:
         containers:
           - name: mysql
             image: mysql:5.7
             env:
               - name: MYSQL_ROOT_PASSWORD
                 value: your-root-password
             ports:
               - containerPort: 3306
   ---
   apiVersion: v1
   kind: Service
   metadata:
     name: mysql-service
   spec:
     selector:
       app: mysql
     ports:
       - protocol: TCP
         port: 3306```

3. **Apply the Manifest**:

   Apply the Kubernetes manifest to create the MySQL deployment and service:

   ```
   kubectl apply -f mysql-deployment.yaml
   ```

4. **Check Deployment Status**:

   You can check the status of the deployment and wait for it to become available:

   ```
   kubectl get pods
   ```

   Wait for the `mysql-deployment-xxx` pod's STATUS to become "Running."

5. **Access MySQL**:

   You can access the MySQL instance from your local machine using port forwarding. Run the following command:

   ```
   kubectl port-forward svc/mysql-service 3306:3306
   ```
## Login to MySQL

To log in to the MySQL console for the MySQL pod you deployed in your Minikube cluster, you can use the `kubectl exec` command to execute a shell within the pod and then access the MySQL command-line client. Here are the steps:

1. First, make sure your MySQL pod is running. You can check the pod's status using the following command:

   ```
   kubectl get pods
   ```

   Wait for the pod to show a status of "Running."

2. Next, log in to the MySQL pod using the `kubectl exec` command. Replace `mysql-deployment-xxx` with the actual name of your MySQL pod:

   ```
   kubectl exec -it <pod-name> -- /bin/bash
   ```

   For example:

   ```
   kubectl exec -it mysql-deployment-xxx -- /bin/bash
   ```

   This command opens a shell within the pod.

3. Once you're inside the pod, you can access the MySQL command-line client using the following command. Replace `<username>` and `<password>` with your MySQL username and password:

   ```
   mysql -u <username> -p
   ```

   If you used the default MySQL image and provided a root password during deployment, you can log in as the root user:

   ```
   mysql -u root -p
   ```

   You'll be prompted to enter the password you specified in the Kubernetes manifest.

4. After entering the correct password, you should be logged in to the MySQL console. You can now run SQL commands and interact with the MySQL database.

5. When you're finished with the MySQL console, you can exit the pod by typing `exit`.
6. Create a Kubernetes Service Account
Create a Kubernetes service account by creating a YAML file (e.g., service-account.yaml) with the following content:
```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-service-account
```
This YAML defines a service account named my-service-account.

Apply the service account configuration to your Minikube cluster:
```
kubectl apply -f service-account.yaml
```

   

## Configure HashiCorp Vault:
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
4. Create a secret at path secrets/mysql/config with a root password.
```
vault secrets enable -version=2 kv
vault kv put secrets/mysql/config root_password='MySQL#400'
```
5. Verify that the secret is stored at the path secrets/mysql/config.
```
vault kv get -format=json secrets/mysql/config | jq ".data.data"
```
6. The Vault server, with secret, is ready to be addressed by a Kubernetes cluster and the pods deployed in it.

7. Grant Access to Kubernetes Service Account:

In order to allow your Kubernetes pods to access Vault and retrieve the MySQL root password, you need to configure Vault policies and roles for Kubernetes service accounts.

Create a Vault policy that allows read access to the MySQL secret path.
Example policy (mysql-policy.hcl):
```
path "secrets/mysql/*" {
  capabilities = ["read"]
}
```
This policy grants read access to all secrets under the secrets/mysql path. You can customize this policy according to your specific needs, allowing read or write access to different paths as required.
8. Write the Policy to Vault
Use the vault policy write command to create the policy in Vault. Replace <policy-name> with your desired policy name, and specify the path to the policy file you created:
```
vault policy write mysql-read-policy mysql-policy.hcl
```

8. Create a Vault role that associates the Kubernetes Service Account with the policy.
Example role (mysql-role.hcl):

```
path "auth/kubernetes/login" {
  capabilities = ["create", "read"]
}

path "secrets/data/mysql/*" {
  capabilities = ["read"]
}

bound_service_account_names = ["my-service-account"]
bound_service_account_namespaces = ["default"]
```
9. Write the role to Vault:
```
vault write auth/kubernetes/role/mysql-role @vault-role.hcl
```

10. 


