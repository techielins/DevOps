# Steps:

* Login to your Kubernetes Cluster

# Create a namespace

Create a namespace called jenkins

$ kubectl create namespace jenkins

* Create a file **service-account.yaml** and copy the following contents to create a service account for Jenkins.

```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins-admin
  namespace: jenkins
```
* Apply the manifest using following command

```
$ kubectl apply -f service-account.yaml
```

# Setup jenkins cluster role

* Create a file **jenkins-cluster-role.yaml** and copy the following contents.

```
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: jenkins
  namespace: jenkins
  labels:
    "app.kubernetes.io/name": 'jenkins'
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["create","delete","get","list","patch","update","watch"]
- apiGroups: [""]
  resources: ["pods/exec"]
  verbs: ["create","delete","get","list","patch","update","watch"]
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["get","list","watch"]
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: jenkins-role-binding
  namespace: jenkins
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: jenkins
subjects:
- kind: ServiceAccount
  name: jenkins-admin
  namespace: jenkins
```

* Apply the manifest using following command

```
$ kubectl apply -f jenkins-cluster-role.yaml
```

# Create a persistent volume for storing Jenkins settings

Create a yaml - **jenkins-persistent-volume.yaml** and copy the following contents.

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: jenkins-pv
  labels:
    app: jenkins
spec:
  capacity:
    storage: 5Gi
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  hostPath:
    path: "/data/jenkins" #You have make sure that Jenkins ID has enough permission to perform writes on this folder. sudo chown -R 1000:1000 /data
 ```
 
* Use the following command to create PV.
```
$ kubectl apply -f jenkins-persistent-volume.yaml
```

# Create persistent volume claim for Jenkins

In this step, you need to define the persistent volume claim for your Jenkins. Create a yaml - **jenkins-pvc.yaml** and copy the following contents.
```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: jenkins-pvclaim
  namespace: jenkins
  labels:
    app: jenkins
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: local-storage
  resources:
    requests:
      storage: 5Gi
```

* Use the following command to create PV.

```
$ kubectl apply -f jenkins-pvc.yaml
```

Confirm PV and PVC status are showing as bound.

```
$ kubectl get pv
NAME         CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                     STORAGECLASS    REASON   AGE
jenkins-pv   5Gi        RWO            Retain           Bound    jenkins/jenkins-pvclaim   local-storage            4m30s
```
```
$ kubectl get pvc -n jenkins
NAME              STATUS   VOLUME       CAPACITY   ACCESS MODES   STORAGECLASS    AGE
jenkins-pvclaim   Bound    jenkins-pv   5Gi        RWO            local-storage   2m39s
```
# Jenkins deployment 
Now we are going to install the Jenkins and for that, we are going to create **jenkins-deployment.yaml**
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins-master-deployment
  namespace: jenkins
  labels:
    app: jenkins-master
    group: jenkins

spec:
  replicas: 1

  selector:
      matchLabels:
        app: jenkins-master
        version: latest
        group: jenkins

  template:
    metadata:
      labels:
        app: jenkins-master
        version: latest
        group: jenkins

    spec:
      serviceAccountName: jenkins-admin # The name of the service account is jenkins-admin
      securityContext:
          fsGroup: 1000
          runAsUser: 1000

      containers:
        - name: jenkins-master
          image: techielins/jenkins-master:v1
          imagePullPolicy: IfNotPresent

          env:
            - name: JAVA_OPTS
              value: -Djenkins.install.runSetupWizard=false

          ports:
            - name: http-port
              containerPort: 8080
            - name: jnlp-port
              containerPort: 50000

          livenessProbe:
            httpGet:
              path: "/login"
              port: 8080
            initialDelaySeconds: 90
            periodSeconds: 10
            timeoutSeconds: 5
            failureThreshold: 5

          readinessProbe:
            httpGet:
              path: "/login"
              port: 8080
            initialDelaySeconds: 60
            periodSeconds: 10
            timeoutSeconds: 5
            failureThreshold: 3

          volumeMounts:
            - name: jenkins-persistent-storage
              mountPath: /var/jenkins_home

      volumes:
        - name: jenkins-persistent-storage
          persistentVolumeClaim:
            claimName: jenkins-pvclaim
            readOnly: false           
```
* Apply the configuration using following command

```
$ kubectl apply -f jenkins-deployment.yaml
```
* You can verify your jenkins deployment using the following command 
```
$ kubectl get deployment -n jenkins
```
It should return you with something similar
```
$ $ kubectl get deployment,po -n jenkins
NAME                                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/jenkins-master-deployment   1/1     1            1           7m37s

NAME                                             READY   STATUS    RESTARTS   AGE
pod/jenkins-master-deployment-7595947c7b-7vrms   1/1     Running   0          115s

```
# Expose Jenkins deployment as Service - jenkins-service.yaml

Create a yaml - **jenkins-service.yaml** and copy the following contents.
```
apiVersion: v1
kind: Service
metadata:
  name: jenkins-service
  namespace: jenkins
  annotations:
      prometheus.io/scrape: 'true'
      prometheus.io/path:   /
      prometheus.io/port:   '8080'
spec:
  selector:
    app: jenkins-master
  type: NodePort
  ports:
    - name: http
      port: 8080
      targetPort: 8080
      protocol : TCP
      nodePort: 32000
    - name: jnlp
      port: 50000
      targetPort: 50000
      protocol: TCP
```     
* Apply the configuration using following command
```
$ kubectl apply -f jenkins-service.yaml
```
Note : Access Jenkins running on minikube and hosted on AWS, you the following command to access Jenkins interface using Public IP
```
kubectl -n jenkins port-forward --address 0.0.0.0 service/jenkins-service 32000:8080 > /dev/null &
```

# How to find Jenkins initial Administrator password

Now you need to find Jenkins initial admin password and for that first, you need to get your Kubernetes pod name
```
$ kubectl get po -n jenkins
```
Run the log command on the Kubernetes pod to find the Jenkins initial admin password

```
$ kubectl logs <jenkins-pod-name> -n jenkins
```
It should return the pods logs along with Jenkins initial admin password

```
Jenkins initial setup is required. An admin user has been created and a password generated.
Please use the following password to proceed to installation:

35d38845036a4b4caf16c79f80921f21

This may also be found at: /var/jenkins_home/secrets/initialAdminPassword

```
# Supply Jenkins Admin password

Give the admin password that you got from the log while accessing the Jenkins UI for the first time and go ahead creating a admin user.

# Create a Kubernetes Cloud Configuration

Once logged-in, go to - Manage Jenkins -> Manage Node and Clouds -> Click Configure Clouds -> Add a new Cloud” select Kubernetes -> Select Kubernetes Cloud Details > Provie Kubernetes namespace as jenkins.

Since we have Jenkins inside the Kubernetes cluster with a service account to deploy the agent pods, we don’t have to mention the Kubernetes URL or certificate key. However, to validate the connection using the service account, use the Test connection. It should show a connected message shown as below if the Jenkins pod can connect to the Kubernetes master API.

```
Connected to Kubernetes v1.26.1
```
# Configure the Jenkins URL Details

For Jenkins master running inside the cluster, you can use the Service endpoint of the Kubernetes cluster as the Jenkins URL because agents pods can connect to the cluster via internal service DNS. The service DNS will be,

http://jenkins-service.jenkins.svc.cluster.local:8080

Add the POD label that can be used for grouping the containers if required in terms for custom build dashboards.

![image](https://github.com/techielins/DevOps/assets/68058598/a3ed9efd-014b-4c62-871e-c222a7ba9f06)

# Create POD and Container Template

The label "**slave**" will be used in the job as an identifier to pick this pod as the build agent. Next, we need to add a container template with the Docker image details.

![image](https://github.com/techielins/DevOps/assets/68058598/a5e2c3c4-79db-4bfc-ae02-c68421f96503)

The next configuration is the container template. If you don’t add a container template, the Jenkins Kubernetes plugin will use the default JNLP image from the Docker hub to spin up the agents. ie, jenkins/inbound-agent. Otherwise use your custom image.

Ensure that you remove the sleep and 9999999 default argument from the container template.

![image](https://github.com/techielins/DevOps/assets/68058598/558101de-29fa-459b-a4ac-037866d0a2e7)

This is the base minimum configuration required for the agent to work. Save all the configurations and let’s test if we can build a job with a pod agent.

# Create Jenkins FreeStyle Job

Jenkins home –> New Item and create a freestyle project.

In the job description, add the label **slave** as shown below. It is the label we assigned to the pod template. This way, Jenkins knows which pod template to use for the agent container.

![image](https://github.com/techielins/DevOps/assets/68058598/725dee09-6a60-4822-8e76-07e3f2ff7d9f)

Add a shell build step with an echo command to validate the job as shown below.

![image](https://github.com/techielins/DevOps/assets/68058598/13c460d7-2a8f-420e-b304-56ab52c9edd8)

Save the job configuration and click “Build Now”. You should see a pending agent in the job build history as shown below.

![image](https://github.com/techielins/DevOps/assets/68058598/5468cee2-a4a9-4368-bc32-07dfa5e6ef26)

And you should see, slave pod is running in kubernetes cluster.

```
~$ kubectl get po
NAME                                         READY   STATUS    RESTARTS       AGE
jenkins-master-deployment-5bd45d65fd-rthts   1/1     Running   5 (120m ago)   14d
jenkins-slave-jf9qx                          1/1     Running   0              37s
```














    
