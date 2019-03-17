#!/bin/bash

TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)

sed -i 's/SHIPIT_SERVICE_ACCOUNT_TOKEN/'"$TOKEN"'/g' /root/.kube/config
sed -i 's/SHIPIT_SERVICE_ACCOUNT_TOKEN/'"$TOKEN"'/g' /home/deploy/.kube/config

exec "$@"
