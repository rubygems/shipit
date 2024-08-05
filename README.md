# RubyGems.org Shipit

This is the [shipit-engine](https://github.com/Shopify/shipit-engine) instance for deploying RubyGems.org and related applications.

## Setup MySQL

Shipit needs MySQL database to be running. You can copy `config/database.yml.sample` to `config/database.yml` and tweak.

You can also use pre-configured setup (originally prepared for CI) using `docker compose`.

```bash
cp config/database.ci.yml config/database.ylm
docker compose up -d
```

## Running tests

Once ready MySQL setup is ready, you can run tests using standard rails commands.

1. initialize DB (needed only once)

```bash
bin/rails db:setup
```

2. run tests

```bash
bin/rails test
```

# RBAC

The following RBAC rules are necessary:

kubectl create rolebinding shipit-access --clusterrole=cluster-admin --serviceaccount=shipit:default --namespace=shipit
kubectl create rolebinding shipit-access --clusterrole=cluster-admin --serviceaccount=shipit:default --namespace=rubygems-staging
kubectl create rolebinding shipit-access --clusterrole=cluster-admin --serviceaccount=shipit:default --namespace=rubygems-production
