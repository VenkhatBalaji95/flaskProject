#!/bin/bash

echo "First variable: $1"
echo "Second variable: $2"
echo "Third variable: $3"
echo "Fourth variable: $4"

service=$(echo $1 | tr '[:upper:]' '[:lower:]')
echo "Service is $service"

namespace=$(echo $2 | tr '[:upper:]' '[:lower:]')
echo "Namespace is $namespace"

deploymentName=$(echo $3 | xargs)
echo "Deployment Name is $deploymentName"

podCount=$4
echo "Pod count is $podCount"

case $service in
	start-app)
		echo "Start All process will start all the deployments in the $2 namespace";;
	stop-app)
		echo "Stop All process will stop all the deployment in the $2 namespace";;
	*)
		echo "Invalid services. Valid services are 'start-all' or 'stop-all'"
		exit 5;;
esac

if [ "$service" = "start-app" ]; then
	if [ "$podCount" -gt 0 ]; then
		echo "Pod count greater than 0 validation passed"
	else
		echo "Pod count should be greater than 0 for start-app"
		exit 5
	fi
	echo "Start-all process starts..."
	echo "Get Deployment before start"
	kubectl get deployment $deploymentName -n $namespace
	if kubectl scale --replicas=$podCount deployment/$deploymentName -n $namespace; then
		echo "Started deployment for $deploymentName"
		echo "sleep for 60 secs..."
		sleep 60
		kubectl get deployments $deploymentName -n $namespace
	else
		echo "$deploymentName Deployment object start failed"
	fi
else
	if [ "$podCount" -ne 0 ]; then
		echo "Pod count should be 0 for stop-app"
		exit 5
	else
		echo "Pod count not equal to 0 validation pased"
	fi
	echo "Stop-all process starts..."
	echo "Get Deployment before stop"
	kubectl get deployment $deploymentName -n $namespace
        if kubectl scale --replicas=0 deployment/$deploymentName -n $namespace; then
                echo "Stopped deployment for $deploymentName"
                echo "sleep for 60 secs..."
                sleep 60
                kubectl get deployments $deploymentName -n $namespace
        else
                echo "$deploymentName Deployment object stop failed"
        fi
fi