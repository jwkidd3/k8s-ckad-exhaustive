# Lab 22


<details>
<summary><b>Quick Reference</b></summary>
<p>

* Namespace: `default`<br>
* Documentation: [Resource Management for Pods and Containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/), [Volumes](https://kubernetes.io/docs/concepts/storage/volumes/)

</p>
</details>

You are tasked with creating a Pod for running an application in container. During application development, you ran a load test for figuring out the minimum amount of resources needed and the maximum amount of resources the application is allowed to grow to. Define those resource requests and limits for the Pod.

1. Define a Pod named `hello-world` running the container image `bmuschko/nodejs-hello-world:1.0.0`. The container exposes the port 3000.
2. Add a Volume of type `emptyDir` and mount it the container path `/var/log`.
3. For the container, specify the following minimum number of resources as follows:

    - CPU: 100m
    - Memory: 500Mi
    - Ephemeral storage: 1Gi

4. For the container, specify the following maximum number of resources as follows:

    - Memory: 500Mi
    - Ephemeral storage: 2Gi

5. Create the Pod from the YAML manifest.
6. Inspect the Pod details. Which node does the Pod run on?
---

## Walkthrough


Start by creating a basic definition of a Pod. The following YAML manifest defines the Pod named `hello-world` with a single container running the image `bmuschko/nodejs-hello-world:1.0.0`.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hello-world
spec:
  containers:
  - image: bmuschko/nodejs-hello-world:1.0.0
    name: hello-world
    ports:
    - name: nodejs-port
      containerPort: 3000
```

Add a Volume to the Pod and mount it in the container.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hello-world
spec:
  containers:
  - image: bmuschko/nodejs-hello-world:1.0.0
    name: hello-world
    ports:
    - name: nodejs-port
      containerPort: 3000
    volumeMounts:
    - name: log-volume
      mountPath: "/var/log"
  volumes:
  - name: log-volume
    emptyDir: {}
```

Lastly, define the resource requirements for the container.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hello-world
spec:
  containers:
  - image: bmuschko/nodejs-hello-world:1.0.0
    name: hello-world
    ports:
    - name: nodejs-port
      containerPort: 3000
    volumeMounts:
    - name: log-volume
      mountPath: "/var/log"
    resources:
      requests:
        cpu: 100m
        memory: 500Mi
        ephemeral-storage: 1Gi
      limits:
        memory: 500Mi
        ephemeral-storage: 2Gi
  volumes:
  - name: log-volume
    emptyDir: {}
```

Create the Pod object with the following command:

```
$ kubectl apply -f pod.yaml
pod/hello-world created
```

The cluster in this scenario consists of three nodes, one control-plane node and two worker nodes. Be aware that your setup will likely look different.

```
$ kubectl get nodes
NAME           STATUS   ROLES           AGE   VERSION
minikube       Ready    control-plane   65s   v1.26.3
minikube-m02   Ready    <none>          44s   v1.26.3
minikube-m03   Ready    <none>          26s   v1.26.3
```

The `-o wide` flag renders the node the Pod is running on, in this case the node named `minikube-m03`.

```
$ kubectl get pod hello-world -o wide
NAME          READY   STATUS    RESTARTS   AGE   IP           NODE           NOMINATED NODE   READINESS GATES
hello-world   1/1     Running   0          25s   10.244.2.2   minikube-m03   <none>           <none>
```

The details of the Pod provide information about the container's resource requirements.

```
$ kubectl describe pod hello-world
...
Containers:
  hello-world:
    ...
    Limits:
      ephemeral-storage:  2Gi
      memory:             500Mi
    Requests:
      cpu:                100m
      ephemeral-storage:  1Gi
      memory:             500Mi
...
```
