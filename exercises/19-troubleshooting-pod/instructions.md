# Exercise 19

<details>
<summary><b>Quick Reference</b></summary>
<p>

* Namespace: `default`<br>
* Documentation: [Debug Pods](https://kubernetes.io/docs/tasks/debug/debug-application/debug-pods/)

</p>
</details>

In this exercise, you will practice your troubleshooting skills by inspecting a misconfigured Pod.

1. Create a new Pod from the YAML manifest in the file [`pod.yaml`](./pod.yaml).
2. Check the Pod's status. You should see the Pod enter `CrashLoopBackOff` shortly after creation — the container is starting and failing repeatedly. Use `kubectl describe` to see the restart count and recent container events.
3. Render the logs of the most recent terminated container (`kubectl logs <pod> --previous` may be needed) and identify the error message.
4. Try to shell into the container. The image is `gcr.io/distroless/nodejs20-debian11` — distroless images contain no shell, so `kubectl exec ... -- sh` will not work. Use `kubectl debug` with `--share-processes` to attach a debug container if you need to inspect the filesystem.
5. Suggest solutions that can fix the root cause of the issue.