# Steps:

* Login to your Kubernetes Cluster

# Setup jenkins cluster role

* Create a file **jenkins-cluster-role.yaml** and copy the following contents.

```
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: default
  name: service-reader
rules:
  - apiGroups: [""] # "" indicates the core API group
    resources: ["services"]
    verbs: ["get", "watch", "list"]
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
```

* Apply the manifest using following command

```
$ kubectl apply -f jenkins-cluster-role.yaml
```
* Now we need to create cluster role binding named "service reader pod" . Use the following command for this.

```
$ kubectl create clusterrolebinding service-reader-pod --clusterrole=service-reader  --serviceaccount=default:default
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
jenkins-pv   5Gi        RWO            Retain           Bound    default/jenkins-pvclaim   local-storage            4m30s
```
```
$ kubectl get pvc
NAME              STATUS   VOLUME       CAPACITY   ACCESS MODES   STORAGECLASS    AGE
jenkins-pvclaim   Bound    jenkins-pv   5Gi        RWO            local-storage   2m39s
```
# Jenkins deployment 
Now we are going to install the Jenkins and for that, we are going to create jenkins-deployment.yaml
```
apiVersion: "v1"
kind: "List"
items:
- apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: "jenkins-master-deployment"
    labels:
      app: "jenkins-master"
      version: "latest"
      group: "jenkins"
  spec:
    replicas: 1
    selector:
        matchLabels:
          app: "jenkins-master"
          version: "latest"
          group: "jenkins"
    template:
      metadata:
        labels:
          app: "jenkins-master"
          version: "latest"
          group: "jenkins"
      spec:
        serviceAccountName: default # The name of the service account is default
        containers:
          - name: "jenkins-master"
            image: "techielins/jenkins-master:v1"
            imagePullPolicy: "IfNotPresent"
            env:
              - name: JAVA_OPTS
                value: -Djenkins.install.runSetupWizard=false
            ports:
              - name: http-port
                containerPort: 8080
              - name: jnlp-port
                containerPort: 50000
            volumeMounts:
              - name: jenkins-persistent-storage
                mountPath: "/var/jenkins_home"
        volumes:
          - name: jenkins-persistent-storage
            persistentVolumeClaim:
              claimName: "jenkins-pvclaim"
              readOnly: false
             
```
* Apply the configuration using following command

```
$ kubectl apply -f jenkins-deployment.yaml
```
* You can verify your jenkins deployment using the following command 
```
$ kubectl get deployment
```
It should return you with something similar
```
$ kubectl get deployment,po
NAME                                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/jenkins-master-deployment   1/1     1            1           21m

NAME                                             READY   STATUS    RESTARTS   AGE
pod/jenkins-master-deployment-55f98d94bc-xhrp2   1/1     Running   0          6m50s

```










    
