#!/bin/bash

echo "First variable: $1"
echo "Second variable: $2"

namespace=$(echo $1 | tr '[:upper:]' '[:lower:]')
echo "Namespace is $namespace"

deploymentName=$(echo $2 | xargs)
echo "Deployment Name is $deploymentName"

echo "Get all the pods before restart"
kubectl get pods -n $namespace

echo "Restarting $deploymentName deployment"
kubectl rollout restart deployment/$deploymentName -n $namespace

echo "Sleep for 45 secs..."
sleep 45

echo "Get all the pods after restarting - $deploymentName"
kubectl get pods -n $namespace