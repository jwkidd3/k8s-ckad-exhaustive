# Lab 30


<details>
<summary><b>Quick Reference</b></summary>
<p>

* Namespace: `default`<br>
* Documentation: [Ingresses](https://kubernetes.io/docs/concepts/services-networking/ingress/), [Ingress Controllers](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)

</p>
</details>

In this exercise, you will create an Ingress with a simple rule that routes traffic to a Service.

> **_NOTE:_** Kubernetes requires running an Ingress Controller to evaluate Ingress rules. Make sure your cluster employs an [Ingress Controller](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/). You can find installation guidance in the file [ingress-controller-setup.md](./ingress-controller-setup.md). If you do not already have a cluster, you can create one by using minikube or you can use the Katacoda lab ["Creating an Ingress"](https://learning.oreilly.com/scenarios/cka-prep-creating/9781492099130/).  If you are using minikube, the network is limited if using the Docker driver on Darwin, Windows, or WSL, and the Node IP is not reachable directly. Refer to the [documentation](https://minikube.sigs.k8s.io/docs/handbook/accessing/) to gain access to the minikube IP.

1. Verify that the Ingress Controller is running.
2. Create a new Deployment named `web` that controls a single replica running the image `bmuschko/nodejs-hello-world:1.0.0` on port 3000.
3. Expose the Deployment with a Service named `web` of type `NodePort`. The Service routes traffic to the Pods controlled by the Deployment `web`.
4. Make a request to the endpoint of the application on the context path `/`. You should see the message "Hello World".
5. Create an Ingress that exposes the path `/` for the host `hello-world.exposed`. The traffic should be routed to the Service created earlier.
6. List the Ingress object.
7. Add an entry in `/etc/hosts` that maps the virtual node IP address to the host `hello-world.exposed`.
8. Make a request to `http://hello-world.exposed`. You should see the message "Hello World".
---

## Walkthrough


If you are running Minikube you should be able to find the Ingress Controller Pod by running the following command in the `ingress-nginx` namespace.

```
$ kubectl get pods -n ingress-nginx
NAME                                        READY   STATUS      RESTARTS   AGE
...
ingress-nginx-controller-799c9469f7-d8whx   1/1     Running     0          4h24m
...
```

Create the Deployment with the following command.

```
$ kubectl create deployment web --image=bmuschko/nodejs-hello-world:1.0.0
deployment.apps/web created

$ kubectl get deployment web
NAME   READY   UP-TO-DATE   AVAILABLE   AGE
web    1/1     1            1           6s
```

Afterward, expose the application with a Service.

```
$ kubectl expose deployment web --type=NodePort --port=3000
service/web exposed

$ kubectl get service web
NAME         TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)          AGE
web          NodePort    10.97.2.103   <none>        3000:31769/TCP   5s
```

Identify one of the node's IP address.

```
$ kubectl get nodes -o wide
NAME       STATUS   ROLES                  AGE   VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE              KERNEL-VERSION   CONTAINER-RUNTIME
minikube   Ready    control-plane,master   21h   v1.22.3   192.168.64.38   <none>        Buildroot 2021.02.4   4.19.202         docker://20.10.8
```

Make a call to the application using the `curl` command. The application will respond with a "Hello World" message.

```
$ curl 192.168.64.38:31769
Hello World
```

Create an Ingress using the following manifest in the file `ingress.yaml`.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: hello-world-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$1
spec:
  rules:
    - host: hello-world.exposed
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: web
                port:
                  number: 3000
```

Create the Ingress object from the YAML manifest.

```
$ kubectl apply -f ingress.yaml
ingress.networking.k8s.io/hello-world-ingress created
```

List the Ingress object. The value for the IP address will populate after waiting for a little while. You may have to run the command multiple times.

```
$ kubectl get ingress hello-world-ingress
NAME                  CLASS   HOSTS                 ADDRESS         PORTS   AGE
hello-world-ingress   nginx   hello-world.exposed   192.168.64.38   80      72s
```

Edit the file `/etc/hosts` via `sudo vim /etc/hosts`. Add the following entry to map the host name `hello-world.exposed` to the node's IP address.

```
192.168.64.38 hello-world.exposed
```

The Ingress will now render the value `localhost` in the column "ADDRESS".

```
$ kubectl get ingress hello-world-ingress
NAME                  CLASS   HOSTS                 ADDRESS     PORTS   AGE
hello-world-ingress   nginx   hello-world.exposed   localhost   80      79s
```

Make a `curl` call to the host name mapped by the Ingress. The call should be routed toward the backend and respond with the message "Hello World".

```
$ curl hello-world.exposed
Hello World
```
