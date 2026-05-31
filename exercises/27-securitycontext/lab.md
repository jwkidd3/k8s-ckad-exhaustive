# Lab 27


<details>
<summary><b>Quick Reference</b></summary>
<p>

* Namespace: `default`<br>
* Documentation: [Configure a Security Context for a Pod or Container](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)

</p>
</details>

In this exercise, you will create a Pod that defines a security context with different options.

> **_NOTE:_** If you do not already have a cluster, you can create one by using minikube or you can use the Katacoda lab ["Defining a security context"](https://learning.oreilly.com/scenarios/ckad-security-defining/9781098104948/).

1. Define a Pod named `busybox-security-context` that uses the image `busybox:1.36` for a single container running the command `sh -c sleep 1h`.
2. Add an ephemeral Volume of type `emptyDir`. Mount the Volume to the container at `/data/test`.
3. Define a security context that runs the container with user ID 1000, with group ID 3000, and the file system group ID 2000. Ensure that the container should not allow privilege escalation.
4. Create the Pod object and ensure that it transitions into the "Running" status.
5. Open a shell to the running container and create a new file named `logs.txt` in the directory `/data/test`. What's the file's user ID and group ID?

---

## Walkthrough


Start by creating the Pod definition as YAML file in `pod.yaml`. Initially, you will only define the container with its command.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: busybox-security-context
spec:
  containers:
  - name: busybox
    image: busybox:1.36
    command: ["sh", "-c", "sleep 1h"]
```

Enhance the Pod definition by adding the Volume.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: busybox-security-context
spec:
  containers:
  - name: busybox
    image: busybox:1.36
    command: ["sh", "-c", "sleep 1h"]
    volumeMounts:
    - name: vol
      mountPath: /data/test
  volumes:
  - name: vol
    emptyDir: {}
```

Finally, define the security context. Some of the security context attribute can only be set on the Pod-level, some others can only be defined on the container-level.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: busybox-security-context
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 3000
    fsGroup: 2000
  containers:
  - name: busybox
    image: busybox:1.36
    command: ["sh", "-c", "sleep 1h"]
    volumeMounts:
    - name: vol
      mountPath: /data/test
    securityContext:
      allowPrivilegeEscalation: false
  volumes:
  - name: vol
    emptyDir: {}
```

Create the Pod with the following command.

```
$ kubectl apply -f pod.yaml
pod/busybox-security-context created
```

Open an interactive shell to the container. Create the file in the directory of the volume mount. The file user ID should be 1000, the group ID should be 2000, as defined by the security context.

```
$ kubectl exec -it busybox-security-context -- sh
/ $ cd /data/test
/data/test $ touch logs.txt
/data/test $ ls -l
total 0
-rw-r--r--    1 1000     2000             0 May 23 01:10 logs.txt
/data/test $ exit
command terminated with exit code 1
```
