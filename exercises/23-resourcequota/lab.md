# Lab 23


<details>
<summary><b>Quick Reference</b></summary>
<p>

* Namespace: `rq-demo`<br>
* Documentation: [Resource Quotas](https://kubernetes.io/docs/concepts/policy/resource-quotas/)

</p>
</details>

In this exercise, you will create a ResourceQuota with specific CPU and memory limits for a new namespace. Pods created in the namespace will have to adhere to those limits.

> **_NOTE:_** If you do not already have a cluster, you can create one by using minikube or you can use the Katacoda lab ["Creating a resource quota for a number of Secrets"](https://learning.oreilly.com/scenarios/ckad-security-creating/9781098104955/).

Create a resource quota named `app` under the namespace `rq-demo` using the following YAML definition in the file [`resourcequota.yaml`](./resourcequota.yaml).

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: app
spec:
  hard:
    pods: "2"
    requests.cpu: "2"
    requests.memory: 500Mi
```

1. Create a new Pod that exceeds the limits of the resource quota requirements e.g. by defining 1Gi of memory but stays below the CPU e.g. 0.5. Write down the error message.
2. Change the request limits to fulfill the requirements to ensure that the Pod could be created successfully. Write down the output of the command that renders the used amount of resources for the namespace.

---

## Walkthrough


Start by creating the Pod definition as YAML file.

First create the namespace and the resource quota in the namespace.

```
$ kubectl create namespace rq-demo
namespace/rq-demo created

$ kubectl apply -f resourcequota.yaml --namespace=rq-demo
resourcequota/app created

$ kubectl describe quota --namespace=rq-demo
Name:            app
Namespace:       rq-demo
Resource         Used  Hard
--------         ----  ----
pods             0     2
requests.cpu     0     2
requests.memory  0     500Mi
```

Next, create the YAML file named `pod.yaml` with more requested memory than available in the quota. You can start by running the command `kubectl run mypod --image=nginx -o yaml --dry-run=client --restart=Never > pod.yaml` and then edit the produced YAML file. Remember to _replace_ the `resources` attribute that has been created automatically.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - image: nginx
    name: mypod
    resources:
      requests:
        cpu: "0.5"
        memory: "1Gi"
  restartPolicy: Never
```

Create the Pod and observe the error message.

```
$ kubectl apply -f pod.yaml --namespace=rq-demo
Error from server (Forbidden): error when creating "pod.yaml": pods "mypod" is forbidden: exceeded quota: app, requested: requests.memory=1Gi, used: requests.memory=0, limited: requests.memory=500Mi
```

Lower the memory settings to less than `500Mi` (e.g. `255Mi`) and create the Pod.

```
$ kubectl apply -f pod.yaml --namespace=rq-demo
pod/mypod created

$ kubectl describe quota --namespace=rq-demo
Name:            app
Namespace:       rq-demo
Resource         Used   Hard
--------         ----   ----
pods             1      2
requests.cpu     500m   2
requests.memory  255Mi  500Mi
```
