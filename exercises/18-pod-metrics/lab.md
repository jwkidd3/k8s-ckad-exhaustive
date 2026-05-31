# Lab 18


<details>
<summary><b>Quick Reference</b></summary>
<p>

* Namespace: `stress-test`<br>
* Documentation: [Metrics Server](https://github.com/kubernetes-sigs/metrics-server)

</p>
</details>

> **_NOTE:_** You will need to install the metrics server if you want to be able to inspect actual resource metrics. You can find [installation instructions](https://github.com/kubernetes-sigs/metrics-server#installation) on the project's GitHub page.

1. Create the namespace `stress-test`.
2. The current directory contains the YAML manifests for three Pods, [`stress-1-pod.yaml`](./stress-1-pod.yaml), [`stress-2-pod.yaml`](./stress-2-pod.yaml), and [`stress-3-pod.yaml`](./stress-3-pod.yaml). Create all of them.
3. Use the data available through the metrics server to identify which of the Pods consumes the most memory.
---

## Walkthrough


Create the namespace with the imperative command.

```
$ kubectl create ns stress-test
namespace/stress-test created
```

Create all Pods by pointing the `apply` command to the current directory.

```
$ kubectl apply -f ./
pod/stress-1 created
pod/stress-2 created
pod/stress-3 created
```

Retrieve the metrics for the Pods from the metrics server using the `top` command.

```
$ kubectl top pods -n stress-test
NAME       CPU(cores)   MEMORY(bytes)
stress-1   50m          77Mi
stress-2   74m          138Mi
stress-3   58m          94Mi
```

The Pod with the highest amount of memory consumption is Pod named `stress-2`. The metrics will look different on your machine given that the amount of consumed memory is randomized in the command executed per container.