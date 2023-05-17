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
Now we are going to install the Jenkins and for that, we are going to create jenkins-deployment.yaml
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










    
