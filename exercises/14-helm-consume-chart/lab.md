# Lab 14


<details>
<summary><b>Quick Reference</b></summary>
<p>

* Namespace: `default`<br>
* Documentation: [Helm](https://helm.sh/)

</p>
</details>

In this exercise, you use Helm to install Kubernetes objects needed for the open-source monitoring system [Prometheus](https://prometheus.io/). The easiest way to install Prometheus on top of Kubernetes is with the help of the [prometheus-operator](https://prometheus-operator.dev/) Helm chart.

> **_NOTE:_** You will need to have Helm installed on your machine. The Helm documentation page provides detailed, OS-specific [installation instructions](https://helm.sh/docs/intro/install/).

1. The Prometheus Helm charts reside in the [artifact repository](https://prometheus-community.github.io/helm-charts). Add the repository to the list of known repositories accessible by Helm with the name `prometheus-community`.
2. Update to the latest information about charts from the respective chart repository.
3. Run the Helm command for listing available Helm charts and their versions. Identify the latest chart version for `kube-prometheus-stack`.
4. Install the chart `kube-prometheus-stack` with the release name `prometheus`.
5. List the installed Helm chart.
6. List the Service named `prometheus-operated` created by the Helm chart. The object resides in the `default` namespace.
7. Use the kubectl `port-forward` command to forward the local port 8080 to the port 9090 of the Service.
8. Verify Prometheus is reachable. On Cloud9 you can run `curl -s localhost:8080/graph | head` from a second terminal, or use the Cloud9 **Preview Running Application** menu pointed at port 8080.
9. Stop port forwarding and uninstall the Helm chart.

---

## Walkthrough


```
$ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
"prometheus-community" has been added to your repositories
```

Update the chart information with the following command.

```
$ helm repo update prometheus-community
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "prometheus-community" chart repository
Update Complete. ⎈Happy Helming!⎈
```

You can search published chart versions in the the repository named `prometheus-community`.

```
$ helm search hub prometheus-community
URL                                               	CHART VERSION	APP VERSION	DESCRIPTION
https://artifacthub.io/packages/helm/prometheus...	45.28.1      	v0.65.1    	kube-prometheus-stack collects Kubernetes manif...
...
```

Install the latest version of the chart `kube-prometheus-stack`.

```
$ helm install prometheus prometheus-community/kube-prometheus-stack
NAME: prometheus
LAST DEPLOYED: Thu May 18 11:32:31 2023
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
kube-prometheus-stack has been installed. Check its status by running:
  kubectl --namespace default get pods -l "release=prometheus"

Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator.
```

The installed charts can be listed with the following command.

```
$ helm list
NAME      	NAMESPACE	REVISION	UPDATED                             	STATUS  	CHART                        	APP VERSION
prometheus	default  	1       	2023-05-18 11:32:31.958955 -0600 MDT	deployed	kube-prometheus-stack-45.28.1	v0.65.1
```

One of the objects created by the chart is the Service named `prometheus-operated`. This Service exposes the Prometheus dashboard on port 9090.

```
$ kubectl get service prometheus-operated
NAME                  TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
prometheus-operated   ClusterIP   None         <none>        9090/TCP   114s
```

Set up port forwarding from port 8080 to port 9090.

```
$ kubectl port-forward service/prometheus-operated 8080:9090
Forwarding from 127.0.0.1:8080 -> 9090
Forwarding from [::1]:8080 -> 9090
```

Open a browser and enter the URL http://localhost:8080/. You will be presented with the Prometheus dashboard.

![prometheus-dashboard](./imgs/prometheus-dashboard.png)

Uninstall the chart with the following command.

```
$ helm uninstall prometheus
release "prometheus" uninstalled
```
