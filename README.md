# RubyGems.org Shipit

This is the [shipit-engine](https://github.com/Shopify/shipit-engine) instance for deploying RubyGems.org and related applications.

## Setup MySQL

Shipit needs MySQL database to be running. You can copy `config/database.yml.sample` to `config/database.yml` and tweak.

## Running tests

Tests also need Redis, which holds task output. `docker compose up -d --wait`
starts both MySQL and Redis.

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

A Job that never starts its task (image pull failure, boot failure, lost
submission) would leave the task `pending` and block the stack. The minutely
CronJob fails tasks that are still `pending` 10 minutes after they were created.

### Rolling back to in-Sidekiq execution

Sidekiq runs as `shipit-task-launcher`, which can only create Jobs, so turning
the executor off also means giving Sidekiq the deploy permissions back. Change
both in `config/deploy/production/sidekiq.yaml.erb` and deploy:

- set `SHIPIT_KUBERNETES_TASK_EXECUTOR` to `"false"`
- set `serviceAccountName` to `shipit-task`

Nothing else is needed: krane reads the `ejson-keys` Secret from the target
namespace through the Kubernetes API, which `shipit-task` is allowed to do.

If task Jobs are the thing that is broken, Shipit cannot deploy its own
rollback. Run the deploy command from `shipit.yml` by hand instead.

## RBAC

Sidekiq uses the dedicated `shipit:shipit-task-launcher` ServiceAccount, which
can only create Jobs in the `shipit` namespace. The Jobs use the separate
`shipit:shipit-task` ServiceAccount for deployment access, so the long-running
worker does not inherit permissions in application namespaces. Do not grant
deployment access to the namespace's `default` ServiceAccount.

Tasks deploy applications into several namespaces. Krane's pruning discovers
all namespaced resource types, including custom resources, so the deployer must
manage all namespaced resources. Bind the `shipit-deployer` ClusterRole to
`shipit:shipit-task` only in each approved target namespace (`shipit`,
`rubygems-staging`, and `rubygems-production`); the RoleBinding prevents those
permissions from applying cluster-wide. Krane also needs to list namespaces
while validating its Kubernetes context and inspect the API root and custom
resource definitions during discovery, so grant those read-only, cluster-scoped
permissions with a separate ClusterRoleBinding.

Create these with `kubectl create -f`, not `kubectl apply -f`. Krane prunes
RoleBindings that `kubectl apply` created and that are not in the deployed
manifests, so an applied `shipit-deployer` RoleBinding is deleted by the first
deploy to its namespace, which then fails. For example:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: shipit-deployer
rules:
  - apiGroups: ["*"]
    resources: ["*"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: shipit-discovery-reader
rules:
  - apiGroups: [""]
    resources: ["namespaces"]
    verbs: ["get", "list"]
  - apiGroups: ["apiextensions.k8s.io"]
    resources: ["customresourcedefinitions"]
    verbs: ["get", "list"]
  - nonResourceURLs: ["/"]
    verbs: ["get"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: shipit-discovery-reader
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: shipit-discovery-reader
subjects:
  - kind: ServiceAccount
    name: shipit-task
    namespace: shipit
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

Do not bind `shipit-deployer` with a ClusterRoleBinding or substitute
`cluster-admin`. Verify every namespace explicitly, for example with `kubectl
auth can-i --as=system:serviceaccount:shipit:shipit-task
--namespace=TARGET_NAMESPACE --list`.
