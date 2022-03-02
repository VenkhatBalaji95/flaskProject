#!/bin/bash

echo "First variable: $1"
echo "Second variable: $2"

service=$(echo $1 | tr '[:upper:]' '[:lower:]')
echo "Service is $service"

namespace=$(echo $2 | tr '[:upper:]' '[:lower:]')
echo "Namespace is $namespace"

case $service in
	start-all)
		echo "Start All process will start all the deployments in the $2 namespace";;
	stop-all)
		echo "Stop All process will stop all the deployment in the $2 namespace";;
	*)
		echo "Invalid services. Valid services are 'start-all' or 'stop-all'"
		exit 5;;
esac

if [ "$service" = "start-all" ]; then
	echo "Start-all process starts..."
	echo "Get Pods before start"
	kubectl get pods -n $namespace
	deploymentList=$(kubectl get deployments --no-headers -o custom-columns=":metadata.name" -n $namespace)
	echo "Deployment list: $deploymentList"
	echo "Starting pods in all deployments"
	for deploymentName in $deploymentList; do
		echo "Deployment name: $deploymentName"
		deploymentNo=$(kubectl get deployment $deploymentName -n $namespace -o=jsonpath='{.metadata.labels.appReplicas}')
		echo "Deployment App replica: $deploymentNo"
		if [ "$deploymentNo" != "0" ]; then
			if kubectl scale --replicas=$deploymentNo deployment/$deploymentName -n $namespace; then
				echo "Started deployment for $deploymentName"
				kubectl label deployment $deploymentName appReplicas- -n $namespace
				echo "Deleted appReplicas label on $deploymentName deployment"
				kubectl get pods,deployments -n $namespace
			else
				echo "Deployment object start failed"
			fi
		else
			echo "Issue with scaling the deployment $deploymentName"
			kubectl label deployment $deploymentName appReplicas- -n $namespace
			echo "Deleted appReplicas label on $deploymentName deployment"
			kubectl get pods,deployments -n $namespace
		fi
	done
	echo "Sleep for 60 seconds"
	sleep 60
	echo "Get pods after starting all the deployments on $namespace"
	kubectl get pods -n $namespace
else
	echo "Stop-all process starts..."
	echo "Get Pods before stop"
        kubectl get pods -n $namespace
	deploymentList=$(kubectl get deployments --no-headers -o custom-columns=":metadata.name" -n $namespace)
	echo "Deployment list: $deploymentList"
        echo "Stopping pods in all deployments"
        for deploymentName in $deploymentList; do
		echo "Deployment name: $deploymentName"
                deploymentNo=$(kubectl get deployment $deploymentName -n $namespace -o=jsonpath='{.spec.replicas}')
                echo "Deployment App replica: $deploymentNo"
		if [ "$deploymentNo" != "0" ]; then
			kubectl label deployment $deploymentName appReplicas=$deploymentNo -n $namespace
			echo "Added appReplicas label on $deploymentName deployment"
			if kubectl scale --replicas=0 deployment/$deploymentName -n $namespace; then
				echo "Stopped deployment for $deploymentName"
				kubectl get pods,deployments -n $namespace
                        else
                                echo "Deployment object start failed"
                        fi
		else
			echo "$deploymentName appReplicas label is already at 0. No action taken"
			kubectl get pods,deployments -n $namespace
		fi
	done
	echo "Sleep for 60 secs"
	sleep 60
        echo "Get pods after stopping all the deployments on $namespace"
        kubectl get pods -n $namespace
fi