# Lab 13


<details>
<summary><b>Quick Reference</b></summary>
<p>

* Namespace: `default`<br>
* Documentation: [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/), [Horizontal Pod Autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)

</p>
</details>

> **_NOTE:_** You will need to install the metrics server if you want actual resource metrics to be collected and displayed by the HorizontalPodAutoscaler. You can find [installation instructions](https://github.com/kubernetes-sigs/metrics-server#installation) on the project's GitHub page.

1. Create a Deployment named `nginx` with 1 replica. The Pod template of the Deployment should use container image `nginx:1.23.4`, set the CPU resource request to 0.5, and the memory resource request/limit to 500Mi.
2. Create a HorizontalPodAutoscaler for the Deployment named `nginx-hpa` that scales to a minimum of 3 and a maximum of 8 replicas. Scaling should happen based on an average CPU utilization of 75%, and an average memory utilization of 60%.
3. Inspect the HorizontalPodAutoscaler object and identify the currently-utilized resources. How many replicas do you expect to exist?
---

## Walkthrough


Define the Deployment in the file `nginx-deployment.yaml`, as shown below.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx:1.23.4
        name: nginx
        resources:
          requests:
            cpu: "0.5"
            memory: "500Mi"
          limits:
            memory: "500Mi"
```

Create the Deployment object from the manifest file.

```
$ kubectl apply -f nginx-deployment.yaml
deployment.apps/nginx created
```

Ensure that all Pods controlled by the Deployment transition into the "Running" status.

```
$ kubectl get deploy
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
nginx   1/1     1            1           49s

$ kubectl get pods
NAME                    READY   STATUS    RESTARTS   AGE
nginx-5bbd9746c-9b4np   1/1     Running   0          24s
```

Next up, define the HorizontalPodAutoscaler with the given resource thresholds in the file `nginx-hpa.yaml`. The final manifest is show below.

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx
  minReplicas: 3
  maxReplicas: 8
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 75
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 60
```

Create the HorizontalPodAutoscaler object from the manifest file.

```
$ kubectl apply -f nginx-hpa.yaml
horizontalpodautoscaler.autoscaling/nginx-hpa created
```

Upon inspection of the HorizontalPodAutoscaler object, you will find that the the number of replicas will be scaled up to the minimum number 3 even though the Deployment only defines a single replica. At the time of running the command below, Pods are not using a significant amount of CPU and memory. That's why the current metrics show 0%.

```
$ kubectl get hpa nginx-hpa
NAME        REFERENCE          TARGETS          MINPODS   MAXPODS   REPLICAS   AGE
nginx-hpa   Deployment/nginx   0%/60%, 0%/75%   3         8         3          2m19s
```
