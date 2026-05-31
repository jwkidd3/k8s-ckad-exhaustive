# Lab 5


<details>
<summary><b>Quick Reference</b></summary>
<p>

* Namespace: `h92`<br>
* Documentation: [Ephemeral Volumes](https://kubernetes.io/docs/concepts/storage/ephemeral-volumes/)

</p>
</details>

In this exercise, you will create a Pod that runs the web server [nginx](https://docs.nginx.com/nginx/admin-guide/web-server/). Nginx requires certain directory paths to be writable. We'll mount ephemeral Volumes to make those paths available to the container.

1. Create a Pod named `nginx` in the namespace `h92`. Its container should run the container image `nginx:1.21.6`.
2. Define a Volume of type `emptyDir` named `nginx-run` which mounts the path `/var/run` to the container.
3. Define a Volume of type `emptyDir` named `nginx-cache` which mounts the path `/var/cache/nginx` to the container.
4. Define a Volume of type `emptyDir` named `nginx-data` which mounts the path `/usr/local/nginx` to the container.
5. (Optional) Say you would want to ensure the nginx can only write to those Volume mount paths but not the container's temporary file system. How do you prevent this from being allowed?
---

## Walkthrough


Create the namespace `h92` using an imperative command.

```
$ kubectl create ns h92
namespace/h92 created
```

Start by creating a YAML manifest file, e.g. in the file named `nginx-pod.yaml`. Add the basic definition for the nginx web server. The initial file contents could look as follows:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  namespace: h92
spec:
  containers:
  - name: nginx
    image: nginx:1.21.6
```

Add the Volumes with their corresponding mount paths. The modified YAML manifest could look as shown below.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  namespace: h92
spec:
  containers:
  - name: nginx
    image: nginx:1.21.6
    volumeMounts:
    - name: nginx-run
      mountPath: /var/run
    - name: nginx-cache
      mountPath: /var/cache/nginx
    - name: nginx-data
      mountPath: /usr/local/nginx
  volumes:
  - name: nginx-run
    emptyDir: {}
  - name: nginx-data
    emptyDir: {}
  - name: nginx-cache
    emptyDir: {}
```

For security reasons, it's advisable to make the [container's temporary file system read-only](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/). You can do so by setting `spec.securityContext.readOnlyRootFilesystem` to `true`.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  namespace: h92
spec:
  containers:
  - name: nginx
    image: nginx:1.21.6
    securityContext:
      readOnlyRootFilesystem: true
    volumeMounts:
    - name: nginx-run
      mountPath: /var/run
    - name: nginx-cache
      mountPath: /var/cache/nginx
    - name: nginx-data
      mountPath: /usr/local/nginx
  volumes:
  - name: nginx-run
    emptyDir: {}
  - name: nginx-data
    emptyDir: {}
  - name: nginx-cache
    emptyDir: {}
```

Create the Pod object and ensure that its status transitions into "Running".

```
$ kubectl apply -f nginx-pod.yaml
pod/nginx created
$ kubectl get pod nginx -n h92
NAME    READY   STATUS    RESTARTS   AGE
nginx   1/1     Running   0          36s
```
