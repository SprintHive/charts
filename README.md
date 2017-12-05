# Charts

A collection for charts used by SprintHive. 
The intention is for users to use these charts via the [https://github.com/sprinthive/ship](ship-cli) 
but this repo could be used directly if you want to tweak some of the charts. 

This is a guide which will describe how these charts can be installed into minikube running on a laptop.   

## Getting started with minikube

This is documented as part of the SHIP guide [read more here](https://github.com/SprintHive/ship/wiki/Before-you-start)

### How to use this repo 

If you would like to tweak some settings then clone the repo and then to run install a chart change to the 
sub-directory and then run the helm install script. 
    
    # Clone the SprintHive charts repo
    git clone https://github.com/SprintHive/charts.git

    # So for example to install the elasticearch chart   
    cd elasticsearch           
    helm install --name esdb --namespace infra .

Uninstall a chart

    # helm del --purge <name>
    # so for example to uninstall the elasticsearch chart
    helm del --purge esdb                

### Preparing minikube

This is documented as part of the SHIP guide [read more here](https://github.com/SprintHive/ship/wiki/Preparing-minikube)

## Installing the base stack

* [Elasticsearch](#elasticsearch) 
* [Jenkins](#jenkins)
* [Grafana](#grafana)
* [Kibana](#kibana)
* [Nexus](#nexus)
* [Prometheus](#prometheus)
* [fluent-bit](#fluent-bit)
* [zipkin](#zipkin)
* kong
* kong-cassandra
* [MongoDB](#mongodb)
* [rabbitmq](#rabbitmq)

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
      
<a id="fluent-bit">
      
### Install Fluent bit

    # In fluent-bit sub-directory:
    helm install --name fluent-bit --namespace infra .
    
<a id="zipkin">

### Install Zipkin

    # In the zipkin sub-directory:
    helm install --name tracing --namespace infra .
    
    # To uninstall the chart, do this:
    helm delete --purge tracing
              
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
    
<a id="rabbitmq">
      
### Install Rabbit MQ

    # In rabbitmq sub-directory:
    helm install --name rabbitmq --namespace local .
    
    # To uninstall the chart, do this:
    helm delete --purge rabbitmq
    