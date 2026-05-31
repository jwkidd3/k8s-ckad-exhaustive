# Lab 7


<details>
<summary><b>Quick Reference</b></summary>
<p>

* Namespace: `default`<br>
* Documentation: [Init Containers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/), [Pods](https://kubernetes.io/docs/concepts/workloads/pods/), [Volumes](https://kubernetes.io/docs/concepts/storage/volumes/)

</p>
</details>

Kubernetes runs an init container before the main container. In this lab, the init container retrieves configuration files from a remote location and makes it available to the application running in the main container. The configuration files are shared through a volume mounted by both containers. The running application consumes the configuration files and can render its values.

> **_NOTE:_** If you do not already have a cluster, you can create one by using minikube or you can use the Katacoda lab ["Creating an init container"](https://learning.oreilly.com/scenarios/ckad-multi-container-creating/9781098104986/).

1. Create a new Pod in a YAML file named `business-app.yaml`. The Pod should define two containers, one init container and one main application container. Name the init container `configurer` and the main container `web`. The init container uses the image `busybox`, the main container uses the image `bmuschko/nodejs-read-config:1.0.0`. Expose the main container on port 8080.
2. Edit the YAML file by adding a new volume of type `emptyDir` that is mounted at `/usr/shared/app` for both containers.
3. Edit the YAML file by providing the command for the init container. The init container should run a `wget` command for downloading the file `https://raw.githubusercontent.com/bmuschko/ckad-crash-course/master/exercises/07-init-container/app/config/config.json` into the directory `/usr/shared/app`.
4. Start the Pod and ensure that it is up and running.
5. Run the command `curl localhost:8080` from the main application container. The response should render a database URL derived off the information in the configuration file.
6. (Optional) Discuss: How would you approach a debugging a failing command inside of the init container?

---

## Walkthrough


Start by generating the basic skeleton of the Pod.

```
$ kubectl run business-app --image=bmuschko/nodejs-read-config:1.0.0 --port=8080 -o yaml --dry-run=client --restart=Never > business-app.yaml
```

You should end up with the following configuration:

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: business-app
  name: business-app
spec:
  containers:
  - image: bmuschko/nodejs-read-config:1.0.0
    name: business-app
    ports:
    - containerPort: 8080
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}
```

Edit the file to change the main application container. Moreover, add the init container section.

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  name: business-app
spec:
  initContainers:
  - name: configurer
    image: busybox
  containers:
  - image: bmuschko/nodejs-read-config:1.0.0
    name: web
    ports:
    - containerPort: 8080
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}
```

Add the volume and mount it to the path `/usr/shared/app` for each container.

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  name: business-app
spec:
  initContainers:
  - name: configurer
    image: busybox
    volumeMounts:
    - name: configdir
      mountPath: "/usr/shared/app"
  containers:
  - image: bmuschko/nodejs-read-config:1.0.0
    name: web
    ports:
    - containerPort: 8080
    volumeMounts:
    - name: configdir
      mountPath: "/usr/shared/app"
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Never
  volumes:
  - name: configdir
    emptyDir: {}
status: {}
```

Define the command for init container for downloading the `config.json` file. The final YAML configuration should look similar to the one below.

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  name: business-app
spec:
  initContainers:
  - name: configurer
    image: busybox
    command:
    - wget
    - "-O"
    - "/usr/shared/app/config.json"
    - https://raw.githubusercontent.com/bmuschko/ckad-crash-course/master/exercises/07-init-container/app/config/config.json
    volumeMounts:
    - name: configdir
      mountPath: "/usr/shared/app"
  containers:
  - image: bmuschko/nodejs-read-config:1.0.0
    name: web
    ports:
    - containerPort: 8080
    volumeMounts:
    - name: configdir
      mountPath: "/usr/shared/app"
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Never
  volumes:
  - name: configdir
    emptyDir: {}
status: {}
```

Create the Pod from the YAML file. During the creation of the Pod you can follow the creation of individual containers.

```
$ kubectl apply -f business-app.yaml
pod/business-app created

$ kubectl get pods
NAME           READY   STATUS            RESTARTS   AGE
business-app   0/1     PodInitializing   0          4s

$ kubectl get pods
NAME           READY   STATUS    RESTARTS   AGE
business-app   1/1     Running   0          37m
```

Once the application is running, shell into the container. The mounted volume path contains the downloaded configuration file. The `curl` command renders the values from the configuration file.

```
$ kubectl exec business-app -it -- /bin/sh
# ls /usr/shared/app
config.json
# curl localhost:8080
Database URL: localhost:5432/customers
```

## Optional

> How would you approach a debugging a failing command inside of the init container?

Adding a temporary `sleep` command to the init container help with reserving time for debugging the data available on the mounted volume. You simply `kubectl exec` into the container and inspect the contents.
