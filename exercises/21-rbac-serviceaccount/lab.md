# Lab 21


<details>
<summary><b>Quick Reference</b></summary>
<p>

* Namespace: `t23`<br>
* Documentation: [Using RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/), [Configure Service Accounts for Pods](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/)

</p>
</details>

In this exercise, you will define Role Based Access Control (RBAC) to grant permissions to a service account. The permissions should only apply to certain API resources and operations.

1. Create a new namespace named `t23`.
2. Create a Pod named `service-list` in the namespace `t23`. The container uses the image `alpine/curl:3.14` and makes a `curl` call to the Kubernetes API that lists Service objects in the `default` namespace in an infinite loop. The Pod should hit `https://kubernetes.default.svc/api/v1/namespaces/default/services` and authenticate using the service-account token mounted at `/var/run/secrets/kubernetes.io/serviceaccount/token`. (You may pass `-k` to curl since the kind cluster uses a self-signed CA.)
3. Create and attach the service account `api-call` to the Pod.
4. Inspect the container logs after the Pod has been started. What response do you expect to see from the `curl` command?
5. Assign a ClusterRole and RoleBinding to the service account that only allows the operation needed by the Pod. Have a look at the response from the `curl` command.
---

## Walkthrough


Create the namespace `t23`.

```
$ kubectl create namespace t23
```

Create the service account `api-call` in the namespace.

```
$ kubectl create serviceaccount api-call -n t23
```

Define a YAML manifest file with the name `pod.yaml`. The contents of a file define a Pod that makes a HTTPS GET call to the API server to retrieve the list of Services in the `default` namespace.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: service-list
  namespace: t23
spec:
  serviceAccountName: api-call
  containers:
  - name: service-list
    image: alpine/curl:3.14
    command: ['sh', '-c', 'while true; do curl -s -k -m 5 -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" https://kubernetes.default.svc.cluster.local/api/v1/namespaces/default/services; sleep 10; done']
```

Create the Pod with the following command.

```
$ kubectl apply -f pod.yaml
```

Check the logs of the Pod. The API call is not authorized, as shown in the log output below.

```
$ kubectl logs service-list -n t23
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {},
  "status": "Failure",
  "message": "services is forbidden: User \"system:serviceaccount:t23 \
              :api-call\" cannot list resource \"services\" in API \
              group \"\" in the namespace \"default\"",
  "reason": "Forbidden",
  "details": {
    "kind": "services"
  },
  "code": 403
}
```

Create the YAML manifest in the file `clusterrole.yaml`, as shown below.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: list-services-clusterrole
rules:
- apiGroups: [""]
  resources: ["services"]
  verbs: ["list"]
```

Reference the ClusterRole in a RoleBinding defined in the file `rolebinding.yaml`. The subject should list the service account `api-call` in the namespace `t23`.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: serviceaccount-service-rolebinding
  namespace: t23
subjects:
- kind: ServiceAccount
  name: api-call
  namespace: t23
roleRef:
  kind: ClusterRole
  name: list-services-clusterrole
  apiGroup: rbac.authorization.k8s.io
```

Create both objects from the YAML manifests.

```
$ kubectl apply -f clusterrole.yaml
$ kubectl apply -f rolebinding.yaml
```

The API call running inside of the container should now be authorized and be allowed to list the Service objects in the `default` namespace. As shown in the output below, the namespace currently hosts at least one Service object, the `kubernetes.default` Service.

```
$ kubectl logs service-list -n t23
{
  "kind": "ServiceList",
  "apiVersion": "v1",
  "metadata": {
    "resourceVersion": "1108"
  },
  "items": [
     {
       "metadata": {
         "name": "kubernetes",
         "namespace": "default",
         "uid": "30eb5425-8f60-4bb7-8331-f91fe0999e20",
         "resourceVersion": "199",
         "creationTimestamp": "2022-09-08T18:06:52Z",
         "labels": {
           "component": "apiserver",
           "provider": "kubernetes"
       },
       ...
     }
  ]
}
```
