# Lab 24


<details>
<summary><b>Quick Reference</b></summary>
<p>

* Namespace: `d92`<br>
* Documentation: [Limit Ranges](https://kubernetes.io/docs/concepts/policy/limit-range/), [Resource Management for Pods and Containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)

</p>
</details>

A LimitRange can restrict resource consumption for Pods in a namespace, and assign default computing resource if no resource requirements have been defined. You will practice the effects of a LimitRange on the creation of a Pod in different scenarios.

1. Inspect the YAML manifest definition in the file [`setup.yaml`](./setup.yaml).
2. Create the objects from the YAML manifest file.
3. Create a new Pod named `pod-without-resource-requirements` in the namespace `d92` that uses the container image `bmuschko/nodejs-hello-world:1.0.0` without any resource requirements. Inspect the Pod details. What resource definitions do you expect to be assigned?
4. Create a new Pod named `pod-with-more-cpu-resource-requirements` in the namespace `d92` that uses the container image `bmuschko/nodejs-hello-world:1.0.0` with a CPU resource request of 400m and limits of 1.5. What runtime behavior do you expect to see?
5. Create a new Pod named `pod-with-less-cpu-resource-requirements` in the namespace `d92` that uses the container image `bmuschko/nodejs-hello-world:1.0.0` with a CPU resource request of 350m and limits of 400m. What runtime behavior do you expect to see?
---

## Walkthrough


Create the objects from the given YAML manifest. The file defines a namespace and a LimitRange object.

```
$ kubectl apply -f setup.yaml
namespace/d92 created
limitrange/cpu-limit-range created
```

Describing the LimitRange object gives away its container configuration details.

```
$ kubectl describe limitrange cpu-limit-range -n d92
Name:       cpu-limit-range
Namespace:  d92
Type        Resource  Min   Max   Default Request  Default Limit  Max Limit/Request Ratio
----        --------  ---   ---   ---------------  -------------  -----------------------
Container   cpu       200m  500m  500m             500m           -
```

Define a Pod in the file `pod-without-resource-requirements.yaml` without any resource requirements.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-without-resource-requirements
  namespace: d92
spec:
  containers:
  - image: bmuschko/nodejs-hello-world:1.0.0
    name: hello-world
```

Create the Pod object using the `apply` command.

```
$ kubectl apply -f pod-without-resource-requirements.yaml
pod/pod-without-resource-requirements created
```

A Pod without specifying resource requirements will use the default request and limit defined by LimitRange, in this case 500m.

```
$ kubectl describe pod pod-without-resource-requirements -n d92
...
Containers:
  hello-world:
    Limits:
      cpu:  500m
    Requests:
      cpu:        500m
```

The Pod defined in the file `pod-with-more-cpu-resource-requirements.yaml` specifies a higher CPU resource limit than allowed by the LimitRange.

```
apiVersion: v1
kind: Pod
metadata:
  name: pod-with-more-cpu-resource-requirements
  namespace: d92
spec:
  containers:
  - image: bmuschko/nodejs-hello-world:1.0.0
    name: hello-world
    resources:
      requests:
        cpu: 400m
      limits:
        cpu: 1.5
```

As a result, the Pod will not be allowed to be scheduled.

```
$ kubectl apply -f pod-with-more-cpu-resource-requirements.yaml
Error from server (Forbidden): error when creating "pod-with-more-cpu-resource-requirements.yaml": pods "pod-with-more-cpu-resource-requirements" is forbidden: maximum cpu usage per Container is 500m, but limit is 1500m
```

Lastly, define a Pod in the file `pod-with-less-cpu-resource-requirements.yaml`. The CPU resource request and limit fits within the boundaries of the LimitRange.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-with-less-cpu-resource-requirements
  namespace: d92
spec:
  containers:
  - image: bmuschko/nodejs-hello-world:1.0.0
    name: hello-world
    resources:
      requests:
        cpu: 350m
      limits:
        cpu: 400m
```

Create the Pod object using the `apply` command.

```
$ kubectl apply -f pod-with-less-cpu-resource-requirements.yaml
pod/pod-with-less-cpu-resource-requirements created
```

The Pod uses the provided CPU resource request and limit.

```
$ kubectl describe pod pod-with-less-cpu-resource-requirements -n d92
...
Containers:
  hello-world:
    Limits:
      cpu:  400m
    Requests:
      cpu:        350m
```
