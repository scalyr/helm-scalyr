#!/usr/bin/env bash

if [ -z "$1" ]
then
  echo "Usage: releaseChart.sh <version>"
  exit 1
fi

VERSION="$1"

if [ "$(git branch --show-current)" != "gh-pages" ]
then
  echo "Merge to gh-pages first!"
  exit 1
fi

helm lint .

helm package .

helm repo index --url https://dodevops.github.io/helm-scalyr .


