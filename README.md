# RubyGems.org Shipit

This is the [shipit-engine](https://github.com/Shopify/shipit-engine) instance for deploying RubyGems.org and related applications.

## Setup MySQL

Shipit needs MySQL database to be running. You can copy `config/database.yml.sample` to `config/database.yml` and tweak.

## Running tests

Once ready MySQL setup is ready, you can run tests using standard rails commands.

1. initialize DB (needed only once)

```bash
bin/rails db:prepare
```

2. run tests

```bash
bin/rails test
```

## Task execution

Production sets `SHIPIT_KUBERNETES_TASK_EXECUTOR=true` on Sidekiq. Each Shipit
task is submitted as a standalone Kubernetes Job using the current Shipit image,
so a rollout can replace Sidekiq without replacing the process supervising the
deployment. The Jobs are created dynamically and are not part of the manifests
managed by `krane deploy shipit`.

Set `SHIPIT_KUBERNETES_TASK_EXECUTOR=false` (or remove it) to restore Shipit
Engine's default in-Sidekiq execution strategy without a code change.

## RBAC

Sidekiq uses the dedicated `shipit:shipit-task-launcher` ServiceAccount, which
can only create Jobs in the `shipit` namespace. The Jobs use the separate
`shipit:shipit-task` ServiceAccount for deployment access, so the long-running
worker does not inherit permissions in application namespaces. Do not grant
deployment access to the namespace's `default` ServiceAccount.

Tasks deploy applications into several namespaces. Provision a least-privilege
`shipit-deployer` ClusterRole for the resource kinds used by those applications,
then create a RoleBinding to `shipit:shipit-task` in **each** allowed target
namespace (`shipit`, `rubygems-staging`, and `rubygems-production`). A RoleBinding
keeps the ClusterRole's permissions scoped to that one namespace. For example:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: shipit-deployer
rules:
  - apiGroups: [""]
    resources: ["configmaps", "endpoints", "pods", "secrets", "services", "serviceaccounts"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
  - apiGroups: ["apps"]
    resources: ["daemonsets", "deployments", "replicasets", "statefulsets"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
  - apiGroups: ["batch"]
    resources: ["cronjobs", "jobs"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
  - apiGroups: ["networking.k8s.io"]
    resources: ["ingresses"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
  - apiGroups: ["rbac.authorization.k8s.io"]
    resources: ["rolebindings", "roles"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: shipit-deployer
  namespace: REPLACE_WITH_TARGET_NAMESPACE
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: shipit-deployer
subjects:
  - kind: ServiceAccount
    name: shipit-task
    namespace: shipit
```

Keep the ClusterRole synchronized with the manifests Shipit actually deploys;
do not substitute `cluster-admin`. Verify every namespace explicitly, for
example with `kubectl auth can-i --as=system:serviceaccount:shipit:shipit-task
--namespace=TARGET_NAMESPACE --list`.
