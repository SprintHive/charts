# k8s-elasticsearch-chart
A secure Elasticsearch (5.4.1) cluster on top of Kubernetes made easy.

### Table of Contents

* [Abstract](#abstract)
* [Important Notes](#important-notes)
* [Pre-Requisites](#pre-requisites)
* [Install](#install)
* [Accessing the service](#Accessing the service)
* [Install plug-ins](#plugins)
* [Clean up with Curator](#curator)
* [Credits](#credits)
* [FAQ](#faq)
* [Troubleshooting](#troubleshooting)

## Abstract

Elasticsearch best-practices recommend to separate nodes in three roles:
* `Master` nodes - intended for clustering management only, no data, no HTTP API
* `Client` nodes - intended for client usage, no data, with HTTP API
* `Data` nodes - intended for storing and indexing data, no HTTP API

Given this, this chart launches a cluster of 3 master, 2 client and 2 data nodes secured with TLS links between the nodes and on the REST interface. The elasticsearch security is provided by an open source third party plugin called [Search Guard](https://github.com/floragunncom/search-guard). The security features provided by SearchGuard and (paid) enterprise features can be seen (here)[https://floragunn.com/searchguard-license-support/].

<a id="important-notes">

## (Very) Important notes

* Elasticsearch needs a few system and user limits increased in order to run properly. This chart will not work unless these are set appropriately. See [ElasticSearch recommendations](https://www.elastic.co/guide/en/elasticsearch/reference/master/setting-system-settings.html) on the nodes on which the pods are launched.

* By default, `ES_JAVA_OPTS` is set to `-Xms512m -Xmx512m`. This is a *very low* value but many users, i.e. `minikube` users, were having issues with pods getting killed because hosts were out of memory.
One can change this in the deployment descriptors available in this repository.

* As of the moment, Kubernetes pod descriptors use an `emptyDir` for storing data in each data node container. This is meant to be for the sake of simplicity and should be adapted according to one's storage needs.

* The [stateful](stateful) directory contains an example which deploys the data pods as a `StatefulSet`. These use a `volumeClaimTemplates` to provision persistent storage for each pod.

<a id="pre-requisites">

## Pre-requisites

* Kubernetes cluster with **beta features enabled** (tested with v1.6.4 on top of CoreOS)
* `kubectl` configured to access the cluster master API Server
* Keystore and truststore for node-to-node communication in JKS format in a Kubernetes secret for each node in the cluster. See [TLS Overview](http://floragunncom.github.io/search-guard-docs/tls_overview.html) and [TLS node certificate](http://floragunncom.github.io/search-guard-docs/tls_node_certificates.html). By default, the pods will expect secrets in the following structure:
 - secret/es-[client|master|data]-[https|transport]-tls
   - keystore-[transport|https].jks
     alias: es-[client|master|data]-[statefulset id]

### Install

To use this chart run ```helm install --name <name-suffix> . --namespace <namespace>```

    # assuming that you are in the <PROJECT_HOME/elasticsearch> dir run
    helm install --name esdb . --namespace infra    
    
    # To unistall this chart run 
    helm delete --purge esdb    

Wait for containers to be in the `Running` state with all containers `Ready` and check one of the Elasticsearch master nodes logs:
```
$ kubectl get po,svc
NAME                                 READY     STATUS    RESTARTS   AGE
po/es-master-esdb-0                   1/1       Running     0          8m
po/es-client-esdb-0                   1/1       Running     0          8m
po/es-data-esdb-0                     1/1       Running     0          8m
po/es-data-esdb-1                     1/1       Running     0          8m
po/es-data-esdb-2                     1/1       Running     0          8m

NAME                          CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
svc/elasticsearch             10.233.47.253   <none>        9200/TCP       8m
svc/elasticsearch-discovery   10.233.30.229   <none>        9300/TCP       8m
```

### Accessing the service

*Don't forget* that services in Kubernetes are only acessible from containers in the cluster. For different behavior one should [configure the creation of an external load-balancer](http://kubernetes.io/v1.1/docs/user-guide/services.html#type-loadbalancer). While it's supported within this example service descriptor, its usage is out of scope of this document, for now.

```
$ kubectl get svc elasticsearch
NAME            CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
elasticsearch   10.233.47.253   <none>        9200/TCP         8m
```

From any host on the Kubernetes cluster (that's running `kube-proxy` or similar), run:

```
curl http://elasticsearch:9200
```

One should see something similar to the following:

```json
{
  "name" : "es-client-esdb-0",
  "cluster_name" : "kube-es",
  "cluster_uuid" : "0xnwm8-xQ1mw-CUVgCUN2g",
  "version" : {
    "number" : "5.5.1",
    "build_hash" : "2cfe0df",
    "build_date" : "2017-05-29T16:05:51.443Z",
    "build_snapshot" : false,
    "lucene_version" : "6.6.0"
  },
  "tagline" : "You Know, for Search"
}
```

Or if one wants to see cluster information:

```
curl https://10.233.47.253:9200/_cluster/health?pretty -H 'Authorization: Basic YWRtaW46YWRtaW4='
```

One should see something similar to the following:

```json
{
  "cluster_name" : "kube-es",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 7,
  "number_of_data_nodes" : 2,
  "active_primary_shards" : 1,
  "active_shards" : 2,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}
```

<a id="plugins">
## Install plug-ins

The image used in this repo is very minimalist. However, one can install additional plug-ins at will by simply specifying updating the `Plugins` variable in the chart values or override it when installing the chart. Be sure to keep the security guard plugin otherwise search guard will not work. Example of command line override:
```
helm install elasticsearch-chart --set Plugins="com.floragunn:search-guard-5:5.4.1-12,x-pack"
```

<a id="curator">

## Clean up with Curator

Additionally, one can run a [CronJob](http://kubernetes.io/docs/user-guide/cron-jobs/) that will periodically run [Curator](https://github.com/elastic/curator) to clean up indices (or do other actions on the Elasticsearch cluster). This requires Kubernetes Alpha features and is *untested*.

```
helm install elasticsearch-chart/curator
```

<a id="credits">
## Credits
The README and base configuration for this project was forked from: https://github.com/pires/kubernetes-elasticsearch-cluster

## FAQ

### Why does `NUMBER_OF_MASTERS` differ from number of master-replicas?
The default value for this environment variable is 2, meaning a cluster will need a minimum of 2 master nodes to operate. If a cluster has 3 masters and one dies, the cluster still works. Minimum master nodes are usually `n/2 + 1`, where `n` is the number of master nodes in a cluster. If a cluster has 5 master nodes, one should have a minimum of 3, less than that and the cluster _stops_. If one scales the number of masters, make sure to update the minimum number of master nodes through the Elasticsearch API as setting environment variable will only work on cluster setup. More info: https://www.elastic.co/guide/en/elasticsearch/guide/1.x/_important_configuration_changes.html#_minimum_master_nodes


### How can I customize `elasticsearch.yaml`?
Read a different config file by settings env var `path.conf=/path/to/my/config/`. Another option would be to build one's own image from  [this repository](https://github.com/pires/docker-elasticsearch-kubernetes)

## Troubleshooting
One of the errors one may come across when running the setup is the following error:
```
[2016-11-29T01:28:36,515][WARN ][o.e.b.ElasticsearchUncaughtExceptionHandler] [] uncaught exception in thread [main]
org.elasticsearch.bootstrap.StartupException: java.lang.IllegalArgumentException: No up-and-running site-local (private) addresses found, got [name:lo (lo), name:eth0 (eth0)]
	at org.elasticsearch.bootstrap.Elasticsearch.init(Elasticsearch.java:116) ~[elasticsearch-5.0.1.jar:5.0.1]
	at org.elasticsearch.bootstrap.Elasticsearch.execute(Elasticsearch.java:103) ~[elasticsearch-5.0.1.jar:5.0.1]
	at org.elasticsearch.cli.SettingCommand.execute(SettingCommand.java:54) ~[elasticsearch-5.0.1.jar:5.0.1]
	at org.elasticsearch.cli.Command.mainWithoutErrorHandling(Command.java:96) ~[elasticsearch-5.0.1.jar:5.0.1]
	at org.elasticsearch.cli.Command.main(Command.java:62) ~[elasticsearch-5.0.1.jar:5.0.1]
	at org.elasticsearch.bootstrap.Elasticsearch.main(Elasticsearch.java:80) ~[elasticsearch-5.0.1.jar:5.0.1]
	at org.elasticsearch.bootstrap.Elasticsearch.main(Elasticsearch.java:73) ~[elasticsearch-5.0.1.jar:5.0.1]
Caused by: java.lang.IllegalArgumentException: No up-and-running site-local (private) addresses found, got [name:lo (lo), name:eth0 (eth0)]
	at org.elasticsearch.common.network.NetworkUtils.getSiteLocalAddresses(NetworkUtils.java:187) ~[elasticsearch-5.0.1.jar:5.0.1]
	at org.elasticsearch.common.network.NetworkService.resolveInternal(NetworkService.java:246) ~[elasticsearch-5.0.1.jar:5.0.1]
 	at org.elasticsearch.common.network.NetworkService.resolveInetAddresses(NetworkService.java:220) ~[elasticsearch-5.0.1.jar:5.0.1]
 	at org.elasticsearch.common.network.NetworkService.resolveBindHostAddresses(NetworkService.java:130) ~[elasticsearch-5.0.1.jar:5.0.1]
 	at org.elasticsearch.transport.TcpTransport.bindServer(TcpTransport.java:575) ~[elasticsearch-5.0.1.jar:5.0.1]
 	at org.elasticsearch.transport.netty4.Netty4Transport.doStart(Netty4Transport.java:182) ~[?:?]
 	at org.elasticsearch.common.component.AbstractLifecycleComponent.start(AbstractLifecycleComponent.java:68) ~[elasticsearch-5.0.1.jar:5.0.1]
 	at org.elasticsearch.transport.TransportService.doStart(TransportService.java:182) ~[elasticsearch-5.0.1.jar:5.0.1]
 	at org.elasticsearch.common.component.AbstractLifecycleComponent.start(AbstractLifecycleComponent.java:68) ~[elasticsearch-5.0.1.jar:5.0.1]
 	at org.elasticsearch.node.Node.start(Node.java:525) ~[elasticsearch-5.0.1.jar:5.0.1]
 	at org.elasticsearch.bootstrap.Bootstrap.start(Bootstrap.java:211) ~[elasticsearch-5.0.1.jar:5.0.1]
 	at org.elasticsearch.bootstrap.Bootstrap.init(Bootstrap.java:288) ~[elasticsearch-5.0.1.jar:5.0.1]
 	at org.elasticsearch.bootstrap.Elasticsearch.init(Elasticsearch.java:112) ~[elasticsearch-5.0.1.jar:5.0.1]
 	... 6 more
[2016-11-29T01:28:37,448][INFO ][o.e.n.Node               ] [kIEYQSE] stopping ...
[2016-11-29T01:28:37,451][INFO ][o.e.n.Node               ] [kIEYQSE] stopped
[2016-11-29T01:28:37,452][INFO ][o.e.n.Node               ] [kIEYQSE] closing ...
[2016-11-29T01:28:37,464][INFO ][o.e.n.Node               ] [kIEYQSE] closed
```

This is related to how the container binds to network ports (defaults to ``_local_``). It will need to match the actual node network interface name, which depends on what OS and infrastructure provider one uses. For instance, if the primary interface on the node is `p1p1` then that is the value that needs to be set for the `NETWORK_HOST` environment variable.
Please see [the documentation](https://github.com/pires/docker-elasticsearch#environment-variables) for reference of options.

In order to workaround this, set `NETWORK_HOST` environment variable in the pod descriptors as follows:
```yaml
- name: "NETWORK_HOST"
  value: "_eth0_" #_p1p1_ if interface name is p1p1, ens4 would be _ens4_, etc
```
