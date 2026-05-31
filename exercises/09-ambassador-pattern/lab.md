# Lab 9


<details>
<summary><b>Quick Reference</b></summary>
<p>

* Namespace: `ext-access`<br>
* Documentation: [Pods](https://kubernetes.io/docs/concepts/workloads/pods/)

</p>
</details>

In this example, you'll be asked to implement rate-limiting functionality for HTTP(S) calls to an external service. For example, the requirements for the rate limiter could say that an application can only make a maximum of five calls every 15 minutes. Instead of strongly coupling the rate-limiting logic to the application code, it will be provided by an ambassador container.

The image `bmuschko/nodejs-business-app:1.0.0` represents a Node.js-based application that makes a call to localhost on port 8081. The ambassador container represented by the image `bmuschko/nodejs-ambassador:1.0.0` running on port 8081 will take on making the HTTP call to the external service while at the same time enforcing rate limiting.

> **_NOTE:_** If you do not already have a cluster, you can create one by using minikube or you can use the Katacoda lab ["Implementing the Ambassador Pattern"](https://www.katacoda.com/orm-benjamin-muschko/courses/ckad-assessment/ambassador-pattern/).

1. Create a YAML manifest for a Pod with the name `rate-limiter` in the namespace `ext-access`. Store the definition in the file named `rate-limiter.yaml`. The main application container named `business-app` should use the image `bmuschko/nodejs-business-app:1.0.0` and expose the container port 8080.
2. Modify the YAML manifest by adding the ambassador container named `ambassador`. The ambassador container uses the image `bmuschko/nodejs-ambassador:1.0.0` and exposes the container port 8081.
3. Test the rate-limiting functionality. First, create the Pod, shell into the `business-app` container that runs the business application, and execute a series of `curl` commands that target `localhost:8081`, the end point of the `ambassador` container. The first five calls will be allowed to the external service. On the sixth call, you’ll receive an error message, as the rate limit has been reached within the given time frame.

---

## Walkthrough


Create the namespace `ext-access` to begin with.

```
$ kubectl create ns ext-access
namespace/ext-access created
```

Start by generating the YAML manifest in `dry-run` mode. The resulting manifest in the file `rate-limiter.yaml` will set up the main application container.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: rate-limiter
  namespace: ext-access
spec:
  containers:
  - name: business-app
    image: bmuschko/nodejs-business-app:1.0.0
    ports:
    - containerPort: 8080
  restartPolicy: Never
```

The main application container is set up. Edit the file `rate-limiter.yaml` and add the `ambassador` container. The YAML manifest should look like the following:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: rate-limiter
  namespace: ext-access
spec:
  containers:
  - name: business-app
    image: bmuschko/nodejs-business-app:1.0.0
    ports:
    - containerPort: 8080
  - name: ambassador
    image: bmuschko/nodejs-ambassador:1.0.0
    ports:
    - containerPort: 8081
  restartPolicy: Never
```

The order of definition for the containers is not important. Ambassador containers will be started in parallel.

Execute the following command to create the Pod:

```
$ kubectl apply -f rate-limiter.yaml
pod/rate-limiter created
```

Ensure that the Pod transitions into the "Running" status:

```
$ kubectl get pod rate-limiter -n ext-access
NAME           READY   STATUS    RESTARTS   AGE
rate-limiter   2/2     Running   0          31s
```

Shell into the container named `business-app`. Execute the `curl` command at least six times. You should encounter the error message "Too many requests have been made from this IP, please try again after an hour" on the sixth call:

```
$ kubectl exec rate-limiter -it -c business-app -n ext-access -- /bin/sh
# curl localhost:8080/test
{"args":{"test":"123"},"headers":{"x-forwarded-proto":"https", "x-forwarded-port":"443","host":"postman-echo.com", "x-amzn-trace-id":"Root=1-5f177dba-e736991e882d12fcffd23f34"}, "url":"https://postman-echo.com/get?test=123"}
...
# curl localhost:8080/test
Too many requests made created from this IP, please try again after an hour
```

An end user would have to wait for the rate limiting to reset, which will take about an hour.
