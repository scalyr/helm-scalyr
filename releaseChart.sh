#!/usr/bin/env bash

if [ "$(git branch --show-current)" != "gh-pages" ]
then
  echo "Merge to gh-pages first!"
  exit 1
fi

helm lint .

helm package .

helm repo index --url https://dodevops.github.io/helm-scalyr .


