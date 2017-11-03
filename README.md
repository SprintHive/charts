# Charts

A collection for charts used by SprintHive

## Getting started with minikube

This guide assumes that you have the following installed:

minikube  
kubectl  
helm  

### Adding the SprintHive charts repo to helm 

    # Add a repo to helm so that helm will find the sprinthive-charts 
    helm repo add sprinthive-charts https://s3.eu-west-2.amazonaws.com/sprinthive-charts

### Configure your minikube

    minikube config set memory 4096

### Add tiler to your cluster

    helm init

## Installing the base stack

elasticsearch
kibana
grafana
prometheus
kong
kong-cassandra
jenkins
fluent-bit
zipkin

### Installing Elasticsearch
    
To run elasticsearch we need to increase the vm.max_map_count to 262144  

    # ssh into minikube 
    minikube ssh
    sudo sysctl vm.max_map_count=262144
    
    
    helm install --name esdb --namespace infra sprinthive-charts/elasticsearch
    
    helm delete --purge esdb    

### Installing Jenkins

    helm install --name jenkins --namespace infra . 


### Installing Grafana

    helm install --name grafana --namespace infra stable/grafana

### Installing Kibana

    helm install --name kibana --namespace infra .

###  


## How to use this repo

    git clone https://github.com/SprintHive/charts


See each sub-directory for further instructions    
    
    