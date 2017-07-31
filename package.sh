#!/bin/sh

mkdir -p packages

for x in $(ls -d */ | grep -v packages); do
  cd $x
  helm package . -d ../packages
  cd ..
done

cd packages
helm repo index .
aws s3 sync . s3://sprinthive-charts
