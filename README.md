# Charts

A collection for charts used by SprintHive

## Getting started with minikube

This guide assumes that you have the following installed:

* minikube  
* kubectl  
* helm  

### Adding the SprintHive charts repo to helm 

    # Clone the SprintHive charts repo
    git clone https://github.com/SprintHive/charts.git
    
    # Add a repo to helm so that helm will find the sprinthive-charts 
    # TODO: put elsewhere... helm repo add sprinthive-charts https://s3.eu-west-2.amazonaws.com/sprinthive-charts

### Configure your minikube

> For these changes to be applied you must delete your node.

    # set the memory
    minikube config set memory 4096
    
    # delete and start your minikube for the changes to take effect
    minikube delete
    minikube start --extra-config=apiserver.Authorization.Mode=RBAC
        
    # Confirm that your memory is 4096
    kubectl describe node 
    
    # You should see something like this
    ...        
    Capacity:
     cpu:		2
     memory:	4046860Ki
    ... 

### Add tiller to your cluster

    helm init
    
    # Confirm that tiller pod has started
    kubectl get po --all-namespaces
      

    # Output should be similar to this (STATUS = Running):
    NAMESPACE     NAME                             READY     STATUS    RESTARTS   AGE
    ...
    kube-system   tiller-deploy-84b97f465c-j78gj   1/1       Running   0          15s
    ...
    
### Replicate a permissive policy using RBAC role bindings.

    # WARNING:
    #   The following policy allows ALL service accounts to act as cluster administrators. Any application running in a container 
    #   receives service account credentials automatically, and could perform any action against the API, including viewing secrets 
    #   and modifying permissions. This is not a recommended policy.  
    kubectl create clusterrolebinding permissive-binding --clusterrole=cluster-admin --user=admin --user=kubelet --group=system:serviceaccounts
      

## Installing the base stack

* [Elasticsearch](#elasticsearch) 
* [Jenkins](#jenkins)
* [Grafana](#grafana)
* [Kibana](#kibana)
* [Nexus](#nexus)
* [MongoDB](#mongodb)
* prometheus
* kong
* kong-cassandra
* fluent-bit
* zipkin


<a id="elasticsearch">

### Installing Elasticsearch
    
To run elasticsearch we need to increase the vm.max_map_count to 262144  

    # ssh into minikube 
    minikube ssh
    sudo sysctl vm.max_map_count=262144
    exit
    
Now install the chart       
    
    # In elasticsearch sub-directory:
    helm install --name esdb --namespace infra .
      
    # Confirm elasticsearch is running as expected
    kubectl port-forward -n infra es-local-esdb-0 9200
      
    curl http://localhost:9200/_cluster/health?pretty=true
    
    # You should see something like this:
      {
        "cluster_name" : "kube-es",
        "status" : "green",
        "timed_out" : false,
        "number_of_nodes" : 1,
        "number_of_data_nodes" : 1,
        "active_primary_shards" : 0,
        "active_shards" : 0,
        "relocating_shards" : 0,
        "initializing_shards" : 0,
        "unassigned_shards" : 0,
        "delayed_unassigned_shards" : 0,
        "number_of_pending_tasks" : 0,
        "number_of_in_flight_fetch" : 0,
        "task_max_waiting_in_queue_millis" : 0,
        "active_shards_percent_as_number" : 100.0
      }
      
    # To uninstall the chart, do this:
    helm delete --purge esdb    

<a id="jenkins">

### Installing Jenkins

    # In jenkins sub-directory:
    helm install --name jenkins --namespace infra .
      
    # follow onscreen instructions to get your Jenkins admin password
      
    # Confirm jenkins is running as expected
    kubectl port-forward -n infra <POD-NAME> 8080
    # Browse to:
    http://localhost:8080
        
    # To uninstall the chart, do this:
    helm delete --purge jenkins
    

<a id="grafana">

### Installing Grafana

    # Install from Kubernetes Charts
    helm install --name grafana --namespace infra stable/grafana
      
    
<a id="kibana">

### Installing Kibana

    # In kibana sub-directory:
    helm install --name kibana --namespace infra .
      

<a id="nexus">

### Install Nexus 

    # In nexus sub-directory:
    helm install --name nexus --namespace infra .
      
    
<a id="mongodb">

### Install MongoDB 

    # In mongodb sub-directory:
    helm install --name mongodb --namespace infra .

      
### How to use this repo

    git clone https://github.com/SprintHive/charts

