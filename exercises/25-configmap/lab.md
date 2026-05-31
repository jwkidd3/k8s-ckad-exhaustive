# Lab 25


<details>
<summary><b>Quick Reference</b></summary>
<p>

* Namespace: `default`<br>
* Documentation: [ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/), [Volumes](https://kubernetes.io/docs/concepts/storage/volumes/)

</p>
</details>

In this exercise, you will first create a ConfigMap from a YAML configuration file as a source. Later, you'll create a Pod, consume the ConfigMap as Volume and inspect the key-value pairs as files.

> **_NOTE:_** If you do not already have a cluster, you can create one by using minikube or you can use the Katacoda lab ["Creating a ConfigMap and consuming it as environment variables"](https://learning.oreilly.com/scenarios/ckad-configuration-creating/9781098104917/).

1. Inspect the YAML configuration file named [`application.yaml`](./application.yaml).
2. Create a new ConfigMap named `app-config` from that file.
3. Create a Pod named `backend` that consumes the ConfigMap as Volume at the mount path `/etc/config`. The container runs the image `nginx:1.23.4-alpine`.
4. Shell into the Pod and inspect the file at the mounted Volume path.
5. (Optional) Discuss: How would you approach hot reloading of values defined by a ConfigMap consumed by an application running in Pod?

---

## Walkthrough


Create the ConfigMap and point to the text file upon creation.

```
$ kubectl create configmap app-config --from-file=application.yaml
configmap/app-config created
```

The ConfigMap defines a single key-value pair. The key is the name of the YAML file, the value is the contents of the YAML file.

```
$ kubectl get configmap app-config -o yaml
apiVersion: v1
data:
  application.yaml: |-
    dev:
      url: http://dev.bar.com
      name: Developer Setup
    prod:
      url: http://foo.bar.com
      name: My Cool App
kind: ConfigMap
metadata:
  creationTimestamp: "2023-05-22T17:47:52Z"
  name: app-config
  namespace: default
  resourceVersion: "7971"
  uid: 00cf4ce2-ebec-48b5-a721-e1bde2aabd84
```

Execute the `run` command in combination with the `--dry-run` flag to generate the YAML file for the Pod.

```
$ kubectl run backend --image=nginx:1.23.4-alpine -o yaml --dry-run=client --restart=Never > pod.yaml
```

The final YAML file should look similar to the following code snippet.

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: backend
  name: backend
spec:
  containers:
  - image: nginx:1.23.4-alpine
    name: backend
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
  volumes:
  - name: config-volume
    configMap:
      name: app-config
```

Create the Pod by pointing the `apply` command to the YAML file.

```
$ kubectl apply -f pod.yaml
pod/backend created
```

Log into the Pod and navigate to the directory `/etc/config`. You will find the file `application.yaml` with the expected YAML content.

```
$ kubectl exec backend -it -- /bin/sh
/ # cd /etc/config
/etc/config # ls
application.yaml
/etc/config # cat application.yaml
dev:
  url: http://dev.bar.com
  name: Developer Setup
prod:
  url: http://foo.bar.com
  name: My Cool App
/etc/config # exit
```

## Optional

> How would you approach hot reloading of values defined by a ConfigMap consumed by an application running in Pod?

Changes to environment variables are only reflected if the Pod is restarted. Alternatively, you can mount a ConfigMap as file and poll changes from the mounted file periodically, however, it requires the application to build in the logic.
