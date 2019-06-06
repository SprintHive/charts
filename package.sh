#!/bin/sh

# Usage
# ./package.sh sprinthive-dev-charts

rm -rf packages
mkdir -p packages

declare -a packages=(
  "elasticsearch"
  "kong"
  "kong-cassandra"
  "kong-ingress-controller"
  "fluent-bit"
  "zipkin"
  "kibana"
  "nexus"
  "prometheus-operator"
  "clair"
  "saml-proxy-injector"
)

for x in "${packages[@]}"
do
  cd $x
  helm package . -d ../packages
  cd ..
done

cd packages
helm repo index . --url https://s3.eu-west-2.amazonaws.com/$1
aws --profile sh-charts s3 sync . s3://$1
