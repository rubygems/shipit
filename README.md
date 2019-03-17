# RubyGems.org Shipit

This is the [shipit-engine](https://github.com/Shopify/shipit-engine) instance for deploying RubyGems.org and related applications.

# RBAC

The following RBAC rules are necessary:

kubectl create rolebinding shipit-access --clusterrole=cluster-admin --serviceaccount=shipit:default --namespace=shipit
kubectl create rolebinding shipit-access --clusterrole=cluster-admin --serviceaccount=shipit:default --namespace=rubygems-staging
kubectl create rolebinding shipit-access --clusterrole=cluster-admin --serviceaccount=shipit:default --namespace=rubygems-production
