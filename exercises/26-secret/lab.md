# Lab 26


<details>
<summary><b>Quick Reference</b></summary>
<p>

* Namespace: `default`<br>
* Documentation: [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)

</p>
</details>

In this exercise, you will first create a Secret from literal values. Next, you'll create a Pod and consume the Secret as environment variables. Finally, you'll print out its values from within the container.

> **_NOTE:_** If you do not already have a cluster, you can create one by using minikube or you can use the Katacoda lab ["Creating a Secret and consuming it as environment variables"](https://learning.oreilly.com/scenarios/ckad-configuration-creating/9781098104894/).

1. Create a new Secret named `db-credentials` with the key/value pair `db-password=passwd`.
2. Create a Pod named `backend` that uses the Secret as environment variable named `DB_PASSWORD` and runs the container with the image `nginx:1.23.4-alpine`.
3. Shell into the Pod and print out the created environment variables. You should find `DB_PASSWORD` variable.
4. (Optional) Discuss: What is one of the benefit of using a Secret over a ConfigMap?

---

## Walkthrough


It's easy to create the secret from the command line.

```
$ kubectl create secret generic db-credentials --from-literal=db-password=passwd
secret/db-credentials created
```

The imperative command automatically base64-encodes the provided value of the literal. You can render the details of the Scret object from the command line. The assigned value to the key `db-password` is `cGFzc3dk`.

```
$ kubectl get secret db-credentials -o yaml
apiVersion: v1
data:
  db-password: cGFzc3dk
kind: Secret
metadata:
  creationTimestamp: "2023-05-22T16:47:33Z"
  name: db-credentials
  namespace: default
  resourceVersion: "7557"
  uid: 2daf580a-b672-40dd-8c37-a4adb57a8c6c
type: Opaque
```

Execute the `run` command in combination with the `--dry-run` flag to generate the YAML file for the Pod.

```
$ kubectl run backend --image=nginx:1.23.4-alpine -o yaml --dry-run=client --restart=Never > pod.yaml
```

Edit the YAML file and create an environment that reads the key from the secret while assigning a new same for it.

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
    env:
      - name: DB_PASSWORD
        valueFrom:
          secretKeyRef:
            name: db-credentials
            key: db-password
```

Create the Pod by pointing the `apply` command to the YAML file.

```
$ kubectl apply -f pod.yaml
pod/backend created
```

You can find the environment variable in base64-decoded form by shelling into the container and running the `env` command. 

```
$ kubectl exec -it backend -- env
DB_PASSWORD=passwd
```

## Optional

>  What is one of the benefit of using a Secret over a ConfigMap?

A Secret is distributed only to the nodes running Pods that actually require access to it. Moreover, Secrets are stored in memory and are never written to a physical storage.
