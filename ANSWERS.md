\# GNX DevOps Machine Test — Answers

\*\*Candidate Name:\*\* Fairoz

\*\*Date:\*\* 12-06-2026



\---



\## Q1. CrashLoopBackOff Diagnosis



> Your `gnx-backend` pod is in `CrashLoopBackOff`. Write the exact `kubectl` commands

> you would run to diagnose it and explain what you look for in each output.



\*\*Answer:\*\*



I would start with `kubectl get pods -n gnx-app` to identify the failing pod and check restart count.

Then I would run `kubectl describe pod <pod-name> -n gnx-app` to check events, image pull issues, failed probes, OOMKilled errors, or configuration problems.

Next I would check logs using `kubectl logs <pod-name> -n gnx-app`.

If the pod restarted, I would also run `kubectl logs <pod-name> -n gnx-app --previous`.

I would verify environment variables, Secrets, ConfigMaps, volume mounts, and database connectivity.

Finally, I would check recent events using `kubectl get events -n gnx-app --sort-by=.metadata.creationTimestamp`.



\---



\## Q2. Frontend Cannot Reach Backend



> The frontend can't connect to the backend inside Kubernetes. The backend Service exists.

> What are the possible causes and how do you debug each one?



\*\*Answer:\*\*



Possible causes are wrong backend service name, wrong service port, incorrect Ingress path rewrite, backend pods not ready, or DNS/network issue.

I would run `kubectl get svc -n gnx-app` to confirm the backend service exists and exposes port 3000.

Then I would run `kubectl get endpoints -n gnx-app` to verify the service has backend pod endpoints.

I would check pod readiness using `kubectl get pods -n gnx-app` and `kubectl describe pod`.

I would exec into a frontend pod and test `curl http://gnx-backend:3000/health`.

I would also check frontend API URL configuration and Ingress rules for `/api` routing.



\---



\## Q3. Why PersistentVolumeClaim for PostgreSQL?



> Why did you use a PersistentVolumeClaim for PostgreSQL? What would happen to your

> todo data if you removed the PVC and used a plain Deployment without it?



\*\*Answer:\*\*



PostgreSQL stores application data on disk, so it needs persistent storage.

A PersistentVolumeClaim keeps database files even if the PostgreSQL pod is restarted or recreated.

Without a PVC, data stored inside the container filesystem would be lost when the pod is deleted or rescheduled.

If we used a plain Deployment without persistent storage, todos could disappear after redeployment or node movement.

PVC separates database data from the pod lifecycle.

This is important for proving that todo data remains after refresh and pod restart.



\---



\## Q4. Pipeline Ran But Pods Still Show Old Image



> Your CI/CD pipeline built and pushed a new image, but after the deploy stage,

> the pods are still running the old image. What are the possible reasons?



\*\*Answer:\*\*



The deployment image may not have been updated, or the pipeline may have targeted the wrong namespace or deployment name.

The image may have been pushed successfully but Kubernetes may still be using an old tag.

If the same tag is reused, Kubernetes may use a cached image unless `imagePullPolicy: Always` is configured.

The new image pull may also fail because of wrong registry credentials or an invalid image name.

I would check `kubectl describe deployment`, `kubectl rollout history`, and `kubectl describe pod`.

I would also verify the image using `kubectl get deployment gnx-backend -n gnx-app -o yaml`.



\---



\## Q5. Secret vs ConfigMap



> What is the difference between a Kubernetes Secret and a ConfigMap?

> Why did you use a Secret for the database password instead of a ConfigMap?



\*\*Answer:\*\*



A ConfigMap is used for non-sensitive configuration such as URLs, feature flags, or normal environment values.

A Secret is used for sensitive values such as passwords, tokens, and keys.

Secrets are base64 encoded and can be protected separately using RBAC and encryption at rest.

The database password should be stored in a Secret because it is sensitive.

Using a ConfigMap for a DB password would expose it more casually in normal configuration.

In production, Secrets should also be protected with strict access controls.



\---



\## Q6. What is a Readiness Probe?



> Explain what a Readiness Probe does. What happens to a pod's traffic

> if the readiness probe fails?



\*\*Answer:\*\*



A readiness probe tells Kubernetes whether a pod is ready to receive traffic.

If the readiness probe passes, the pod is added to the Service endpoints.

If the readiness probe fails, Kubernetes keeps the pod running but removes it from traffic routing.

This prevents users from reaching an application that has started but is not ready.

For the backend, `/health` on port 3000 confirms the API is ready.

For the frontend, `/` on port 80 confirms Nginx is serving the UI.



\---



\## Q7. Rolling Update vs Recreate



> What is the difference between a RollingUpdate and a Recreate deployment strategy?

> When would you choose one over the other?



\*\*Answer:\*\*



RollingUpdate replaces old pods gradually with new pods, keeping the application available during deployment.

Recreate stops all old pods first and then starts new pods, which causes downtime.

RollingUpdate is preferred for stateless applications like frontend and backend.

Recreate may be used when two versions cannot run together or when exclusive access is required.

For most web applications, RollingUpdate is safer because it supports zero-downtime deployments.

For incompatible database migrations or single-instance workloads, Recreate may sometimes be simpler.

