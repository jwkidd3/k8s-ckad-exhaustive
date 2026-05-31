# Lab 20


<details>
<summary><b>Quick Reference</b></summary>
<p>

* Namespace: `default`<br>
* Documentation: [Custom Resources](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)

</p>
</details>

As an application developer, you may want to install Kubernetes functionality that exends the platform using the Kubernetes operator pattern. The objective of this exercise is to familiarize yourself with creating and managing CRDs. You will not need to write a controller.

1. Create a CRD resource named `backup.example.com` with the following specification:

    - Group: `example.com`
    - Version: `v1`
    - Kind: `Backup`
    - Singular: `backup`
    - Plural: `backups`
    - Properties of type `string`: `cronExpression`, `podName`, `path`

2. Retrieve the details for the `Backup` custom resource created in the previous step.

3. Create a custom object named `nginx-backup` for the CRD. Provide the following property values:

    - `cronExpression`: `0 0 * * *`
    - `podName`: `nginx`
    - `path`: `/usr/local/nginx`

4. Retrieve the details for the `nginx-backup` object created in the previous step.
---

## Walkthrough


Create the definition of the CRD. The resulting YAML manifest stored in the file `backup-resource.yaml` looks as shown below.

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: backups.example.com
spec:
  group: example.com
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              cronExpression:
                type: string
              podName:
                type: string
              path:
                type: string
  scope: Namespaced
  names:
    kind: Backup
    singular: backup
    plural: backups
    shortNames:
    - bu
```

Create the object from the YAML manifest file.

```
$ kubectl apply -f backup-resource.yaml
customresourcedefinition.apiextensions.k8s.io/backups.example.com created
```

You can interact with CRD using the following command. Make sure to spell out the full name of the CRD, `backups.example.com`.

```
$ kubectl get crd backups.example.com
NAME                  CREATED AT
backups.example.com   2023-05-24T15:11:15Z

$ kubectl describe crd backups.example.com
...
```

Create the YAML manifest in file `backup.yaml` that uses the CRD kind `Backup`.

```yaml
apiVersion: example.com/v1
kind: Backup
metadata:
  name: nginx-backup
spec:
  cronExpression: "0 0 * * *"
  podName: nginx
  path: /usr/local/nginx
```

Create the object from the YAML manifest file.

```
$ kubectl apply -f backup.yaml
backup.example.com/nginx-backup created
```

You can interact with the object using the built-in `kubectl` commands for any other Kubernetes API primitive.

```
$ kubectl get backups
NAME           AGE
nginx-backup   24s

$ kubectl describe backup nginx-backup
...
```
