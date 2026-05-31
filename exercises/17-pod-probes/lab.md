# Lab 17


<details>
<summary><b>Quick Reference</b></summary>
<p>

* Namespace: `default`<br>
* Documentation: [Configure Liveness, Readiness and Startup Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)

</p>
</details>

In this exercise, you will create a Pod running a NodeJS application. The Pod will define readiness and liveness probes with different parameters.

> **_NOTE:_** If you do not already have a cluster, you can create one by using minikube or you can use the Katacoda lab ["Creating a Pod with a readiness Probe of type HTTP GET request"](https://learning.oreilly.com/scenarios/ckad-probing-creating/9781098105105/).

1. Create a new Pod named `hello` with the image `bmuschko/nodejs-hello-world:1.0.0` that exposes the port 3000. Provide the name `nodejs-port` for the container port.
2. Add a Readiness Probe that checks the URL path / on the port referenced with the name `nodejs-port` after a 2 seconds delay. You do not have to define the period interval.
3. Add a Liveness Probe that verifies that the app is up and running every 8 seconds by checking the URL path / on the port referenced with the name `nodejs-port`. The probe should start with a 5 seconds delay.
4. Shell into container and curl `localhost:3000`. Write down the output. Exit the container.
5. Retrieve the logs from the container. Write down the output.

---

## Walkthrough


Create the intial YAML with the following command.

```
$ kubectl run hello --image=bmuschko/nodejs-hello-world:1.0.0 --port=3000 -o yaml --dry-run=client --restart=Never > pod.yaml
```

Edit the YAML file and add the probes.

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: hello
  name: hello
spec:
  containers:
  - image: bmuschko/nodejs-hello-world:1.0.0
    name: hello
    ports:
    - name: nodejs-port
      containerPort: 3000
    readinessProbe:
      httpGet:
        path: /
        port: nodejs-port
      initialDelaySeconds: 2
    livenessProbe:
      httpGet:
        path: /
        port: nodejs-port
      initialDelaySeconds: 5
      periodSeconds: 8
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}
```

Create the Pod from the YAML file, shell into the Pod as soon as it is running and execute the `curl` command.

```
$ kubectl apply -f pod.yaml
pod/hello created

$ kubectl exec hello -it -- /bin/sh
# curl localhost:3000
Hello World
# exit
```

Rendering the logs of the Pod reveals additional log output.

```
$ kubectl logs pod/hello
Magic happens on port 3000
```
