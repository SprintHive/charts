# Charts

A collection for charts used by SprintHive. This repo is used by the "go" branch in the 
[https://github.com/sprinthive/ship]() repo, which is currently under development.
The intention is for users to use these charts via the ship-cli but this repo could be used if you want to use some of the charts. 

This is a guide which will describe how these charts can be installed into minikube running on a laptop.   

## Getting started with minikube

This guide assumes that you have the following installed:

* minikube  
* kubectl  
* helm  

### How to use this repo 

    Depending if you want to tweak the config for any of the charts or not 

#### Adding the SprintHive charts repo to helm

    # Clone the SprintHive charts repo
    git clone https://github.com/SprintHive/charts.git
    
    # Add a repo to helm so that helm will find the sprinthive-charts 
    # TODO: put elsewhere... helm repo add sprinthive-charts https://s3.eu-west-2.amazonaws.com/sprinthive-charts

### Configure your minikube

The next section we will configure the amount of memory and cpus minikube is allowed to use.   
 * memory - as always with memory the recommended amount is as much as you can, the minimum is 5120   
 * cpus - by default minikube is configured to use 2 which is will work but I like to bump it to 4 if possible.

> If you already have an existing minikube, for these changes to be applied you must delete your node, 
as per the onscreen instructions

    # set the memory
    minikube config set memory 5120
    
    # set the cpus
    minikube config set cps 4
    
To run elasticsearch we need to increase the vm.max_map_count to 262144. 
[See this link for more info](https://www.elastic.co/guide/en/elasticsearch/reference/current/vm-max-map-count.html)  

    # ssh into minikube  
    minikube ssh
    
    # create a file /var/lib/boot2docker/bootlocal.sh with the following contents sudo sysctl vm.max_map_count=262144

    # exit the ssh session
    exit

Delete and start your minikube for the changes to take effect

    minikube delete
    minikube start --extra-config=apiserver.Authorization.Mode=RBAC
        
Confirm that your memory is 4096 and your cpus is 4

    kubectl describe node 
    
    # You should see something like this
    ...        
    Capacity:
     cpu:		4
     memory:	5078412Ki
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

Some basic helm commands.

Install a chart

    # helm install --name <name> --namespace <name> <chartname>
    # so for example to install elasticsearch into the infra namespace
    helm install --name esdb --namespace infra /sprinthive/elasticsearch
    
Uninstall a chart

    # helm del --purge <name>
    # so for example to uninstall the elasticsearch chart
    helm del --purge esdb                

* [Elasticsearch](#elasticsearch) 
* [Jenkins](#jenkins)
* [Grafana](#grafana)
* [Kibana](#kibana)
* [Nexus](#nexus)
* [MongoDB](#mongodb)
* [Prometheus](#prometheus)
* [fluent-bit](#fluent-bit)
* [rabbitmq](#rabbitmq)
* [zipkin](#zipkin)
* kong
* kong-cassandra

<a id="elasticsearch">

### Installing Elasticsearch
        
    # In elasticsearch sub-directory:
    helm install --name logdb --namespace infra .
      
    # Confirm elasticsearch is running as expected
    kubectl port-forward -n infra es-local-logdb-0 9200
      
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
    helm delete --purge logdb    

<a id="jenkins">

### Installing Jenkins

    # In jenkins sub-directory:
    helm install --name cicd --namespace infra .
      
    # follow onscreen instructions to get your Jenkins admin password
      
    # Confirm jenkins is running as expected
    kubectl port-forward -n infra <POD-NAME> 8080
    # Browse to:
    http://localhost:8080
        
    # To uninstall the chart, do this:
    helm delete --purge cicd
    

<a id="grafana">

### Installing Grafana

    # Install from Kubernetes Charts
    helm install --name metricviz --namespace infra stable/grafana
      
    # To uninstall the chart, do this:
    helm delete --purge metricviz
    
<a id="kibana">

### Installing Kibana

    # In kibana sub-directory:
    helm install --name logviz --namespace infra .
      
    # To uninstall the chart, do this:
    helm delete --purge logviz

<a id="nexus">

### Install Nexus 

    # In nexus sub-directory:
    helm install --name repo --namespace infra .
      
    # To uninstall the chart, do this:
    helm delete --purge repo
    
<a id="mongodb">

### Install MongoDB 

    # In mongodb sub-directory:
    helm install --name mongodb --namespace local .

    # Confirm that this is running do a port-forward and connect to mongodb using a mongodb client
    kubectl port-forward -n local <POD-NAME> 27017
    
To access your mongodb instance, you have to a add a route to your pods network so that mongodb.local.svc.cluster.local 
will resolve to your minikube network    


     
    # Adding a route for your pod network
    kubectl get po -n local -o wide   
      
    NAMESPACE     NAME               READY     STATUS    RESTARTS   AGE   IP           NODE
    ...
    local         mongodb-mongodb-0  1/1       Running   2          2d    172.17.0.13  minikube
    ...
    
    # Adjust the following command so that it points to the IP range of your cluster
    sudo route -n add 10.0.0.0/24 $(minikube ip)
    sudo route -n add 172.17.0.0/24 $(minikube ip)      
     
    # Create service
    kubectl expose deployment mongodb -n local --type=NodePort
      
<a id="prometheus">

### Install Prometheus 

    # In prometheus sub-directory:
    helm install --name metricdb --namespace infra .
        
    # Confirm Prometheus is running as expected
    kubectl port-forward -n infra <POD-NAME> 9090
    # Browse to:
    http://localhost:9090
        
    # To uninstall the chart, do this:
    helm delete --purge metricdb

<a id="fluent-bit">
      
### Install Fluent bit

    # In fluent-bit sub-directory:
    helm install --name logcollect --namespace infra .

    # To uninstall the chart, do this:
    helm delete --purge logcollect
    
<a id="rabbitmq">
      
### Install Rabbit MQ

    # In rabbitmq sub-directory:
    helm install --name rabbitmq --namespace local .
    
    # To uninstall the chart, do this:
    helm delete --purge rabbitmq
    
<a id="zipkin">

### Install Zipkin

    # In the zipkin sub-directory:
    helm install --name tracing --namespace infra .
    
    # To uninstall the chart, do this:
    helm delete --purge tracing
    
