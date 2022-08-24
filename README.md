# scalyr-agent Helm Chart

[![Latest stable release of the Helm chart](https://img.shields.io/badge/dynamic/json.svg?label=stable&url=https://scalyr.github.io/helm-scalyr/info.json&query=$.scalyrAgent&colorB=blue&logo=helm)](https://scalyr.github.io/helm-scalyr/) [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) [![Lint and Tests](https://github.com/scalyr/helm-scalyr/actions/workflows/lint_tests.yml/badge.svg?branch=main)](https://github.com/scalyr/helm-scalyr/actions/workflows/lint_tests.yml) [![End to End Tests](https://github.com/scalyr/helm-scalyr/actions/workflows/end_to_end_tests.yaml/badge.svg?branch=main)](https://github.com/scalyr/helm-scalyr/actions/workflows/end_to_end_tests.yaml)

## Introduction

This helm chart installs the [Scalyr Agent monitor](https://app.scalyr.com/help/scalyr-agent) into a Kubernetes
cluster. It supports installing the agent with all features required to support a Kubernetes cluster monitoring.
Additionally, it can deploy Scalyr agents which monitor other parts of the infrastructure (for example a hosted
database service etc.).

**Homepage:** <https://github.com/scalyr/helm-scalyr>

## Installation

Use

```bash
helm install <name of release> scalyr-agent --repo https://scalyr.github.io/helm-scalyr/
```

to install this chart.

## Configuration

Two basic configuration keys have to be set up to allow logging to Scalyr cloud:

* ``scalyr.server``: The name of the Scalyr api server (defaults to ``agent.scalyr.com``. use ``eu.scalyr.com`` for EU.)
* ``scalyr.apiKey``: The api key used to authenticate to the Scalyr api server
* ``scalyr.config``: The Scalyr configuration

The scalyr configuration is done using the
[configuration map approach](https://app.scalyr.com/help/scalyr-agent-k8s#modify-config). This is basically a key/value
hash. The keys refer to the configuration file name for grouping monitors. The value is the Scalyr json configuration
for each monitor.

This chart's default values are set to support the monitoring of a Kubernetes cluster. The only value you have
to set manually is:

* ``scalyr.k8s.clusterName``: name of the Kubernetes cluster to monitor (will be visible in the Scalyr UI)

If you want to monitor additional things outside of Kubernetes (e.g. Databases), you can set the following values:

* ``controllerType``: For other monitors, it is usually best to set this to "deployment" instead of "daemonset"
* ``scalyr.k8s.enableLogs`` and ``scalyr.k8s.enableEvents``: Set this to false to remove the serviceaccount, clusterroles and
  additional mounts to the Scalyr agent pods

## Service Account Annotations

A common use case for Kubernetes ServiceAccounts is to provide pods with specific permissions to cloud resources. Consider the case where you wish to store the ``scalyr.apiKey`` in a secrets management service rather than plaintext or as a Kubernetes Secret. If you use a cloud-specific solution such as AWS Parameter Store or AWS Secrets Manager, the scalyr-agent pods will require specific IAM permissions to retrieve the value. (Note this will apply to any Kubernetes ServiceAccount-based permissions scheme)

### AWS EKS

EKS's native pod permission management system is IAM Roles for Service Accounts (IRSA). IRSA documentation is here: <https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html>

**Assumption**: You are using a Mutating Webhook or other solution that tells your pods to read secrets from Parameter Store or Secrets Manager upon startup.

Example:
  1. Create IAM Policy that can read the secrets in Param Store or Secrets Manager
  1. Create a service AWS IAM Role with appropriate OIDC template for this EKS cluster.
  1. Attach the IAM Policy to the IAM Role
  1. Override ``serviceAccount.annotations`` value in the helm chart with a value like the below:
  ```
  # Values relevant to ServiceAccount
  serviceAccount:
    annotations:
      eks.amazonaws.com/role-arn: arn:aws:iam::<AWS_ACCOUNT_ID>:role/<IAM_ROLE_NAME>
  ```
  This gives the pod permission to read the secret as defined in the IAM Policy. (Something in the cluster such as a MutatingWebhook will need to actually facilitate the secret lookup)

## Controller type

By default, this chart creates a daemonset which is the recommended deployment pattern for Kubernetes monitoring.

If you'd like to create a different Scalyr agent, you can set `controllerType` to "deployment" and set
`scalyr.k8s.enableLogs` and `scalyr.k8s.enableEvents` to false.

## Kubernetes Explorer

This chart also supports configuring the agent for the Kubernetes Explorer functionality
(https://www.dataset.com/blog/introducing-dataset-kubernetes-explorer/).

<a href="https://www.dataset.com/blog/introducing-dataset-kubernetes-explorer/"><img src="https://user-images.githubusercontent.com/125088/186437832-02735d95-5eea-41e0-bb5f-55808fc9c606.png" width="550px"/></a>

To install the chart enabling Kubernetes Explorer functionality, you can use the following command:

```bash
helm install <name of release> scalyr-agent --repo https://scalyr.github.io/helm-scalyr/ --set scalyr.k8s.enableExplorer=true
```

This command will enable Kubernetes Explorer functionality, but it won't install additional
dependencies (node exporter DaemonSet and kube state metrics Deployment) which are needed for the
complete Kubernetes Explorer experience.

If you have those two components already running in your cluster, follow instructions at https://app.scalyr.com/help/scalyr-agent-k8s-explorer#config-k8s-cluster
on how to adjust annotations for those pods so they get scraped for the agent.

Alternatively, this helm chart also offers convenience functionality where it can install those two
components for you.

You can do that using the command below:

```bash
helm install <name of release> scalyr-agent --repo https://scalyr.github.io/helm-scalyr/ --set scalyr.k8s.enableExplorer=true --set scalyr.k8s.installExplorerDependencies=true
```

This functionality is primarily meant to be used for Kubernetes Explorer evaluation purposes when
installing the agent on a new / fresh Kubernetes cluster (e.g. minikube).

To make clean up easier, both of those components are installed into the same namespace as the
agent itself.

Keep in mind that minikube uses self signed SSL certificates so if you want to use Kubernetes
Explorer with minikube, you also need to set ``scalyr.k8s.verifyKubeletQueries`` value to
``false``. This disables certificate validation when talking to the Kubelet API (unless you have a
very good reason for it, you should never disable certificate validation in production).

For example:

```bash
helm install <name of release> scalyr-agent --repo https://scalyr.github.io/helm-scalyr/ --set scalyr.k8s.enableExplorer=true --set scalyr.k8s.verifyKubeletQueries=false --set eventsIgnoreMaster=false
```

This commands also sets ``scalyr.k8s.eventsIgnoreMaster`` option to ``false``. This is needed when
running on minikube since by default minikube will only launch a single node (master) and Kubernetes
Events monitor which is required by the Kubernetes Explorer doesn't get scheduled on master nodes
by default.

## Changelog

For chart changelog, please see <https://github.com/scalyr/helm-scalyr/blob/main/CHANGELOG.md>.

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| scalyr | support@scalyr.com | https://github.com/scalyr |
| dploeger | develop@dieploegers.de | https://github.com/dploeger |

## Source Code

* <https://github.com/scalyr/helm-scalyr>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | optional affinity rules |
| controllerType | string | `"daemonset"` | Wether to setup a daemonset or a deployment for the Scalyr agent A daemonset should be used for Kubernetes monitoring while a deployment should be used for single resource monitorings (e.g. hosted databases, etc.) Valid values: "daemonset" or "deployment" |
| deployment.replicaCount | int | `1` | The count of replicas to use when using the deployment controller setup |
| fullnameOverride | string | `""` | Override the default full name that helm calculates |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"scalyr/scalyr-k8s-agent"` | Image to use. Defaults to the official scalyr agent image |
| image.tag | string | `""` | Tag to use. Defaults to appVersion from the chart metadata |
| image.type | string | `"buster"` | Which image distribution to use - "buster" for Debian Buster and "alpine" for Alpine Linux based image. Alpine Linux images are around 50% smaller in size than Debian buster based ones. |
| imagePullSecrets | list | `[]` | Image pull secrets to use if the image is in a private repository |
| livenessProbe.enabled | bool | `true` | set to false to disable default liveness probe which utilizes scalyr-agent-2 status -H command |
| livenessProbe.timeoutSeconds | int | `10` | timeout in seconds after which probe should be considered as failed if there is no response |
| nameOverride | string | `""` | Override the default name that helm calculates |
| nodeSelector | object | `{}` | optional node selectors |
| podAnnotations | object | `{}` | optional pod annotations |
| podLabels | object | `{}` | optional arbitrary pod metadata labels |
| podSecurityContext | object | `{}` |  |
| resources | object | `{"limits":{"cpu":"500m","memory":"500Mi"},"requests":{"cpu":"500m","memory":"500Mi"}}` | Pod resources. Defaults to the values documented in the official [Installation guide](https://app.scalyr.com/help/install-agent-kubernetes) |
| scalyr.apiKey | string | `""` | The Scalyr API key to use |
| scalyr.base64Config | bool | `true` | As Helm is currently [unable to correctly pass JSON strings](https://github.com/helm/helm/issues/5618), this can be set to true so all values of scalyr.config are expected to be base64 encoded and will be decoded in the chart |
| scalyr.config | object | `{}` | A hash of configuration files and their content as documented in the [Scalyr agent configmap configuration documentation](https://app.scalyr.com/help/scalyr-agent-k8s#modify-config) |
| scalyr.debugLevel | int | `0` | Set this to number between 1 and 5 (inclusive - 1 being least verbose and 5 being most verbose) to enable additional debug logging into agent_debug.log file. NOTE: If you want this debug log file to be ingested into Scalyr, you also need to set scalyr.ingestDebugLog option to true. |
| scalyr.ingestDebugLog | bool | `false` |  |
| scalyr.k8s.caCert | string | `""` | The path to the CA certificate to use to verify TLS-connection to the kubelet |
| scalyr.k8s.clusterName | string | `""` | The kubernetes cluster name (when using the kubernetes monitoring) |
| scalyr.k8s.enableEvents | bool | `true` | Enable fetching Kubernetes events |
| scalyr.k8s.enableExplorer | bool | `false` | Enable Kubernetes Explorer functionality (https://www.dataset.com/blog/introducing-dataset-kubernetes-explorer/). This functionality may require additional setup, for more information, please refer to the docs - https://app.scalyr.com/help/scalyr-agent-k8s-explorer NOTE: Explorer functionality is only supported when using DaemonSet agent deployment model. |
| scalyr.k8s.enableLogs | bool | `true` | Enable fetching Pod/Container logs from Kubernetes |
| scalyr.k8s.enableMetrics | bool | `true` | Enable fetching Kubernetes metrics. This requires scalyr.k8s.enableLogs to be true |
| scalyr.k8s.eventsIgnoreMaster | bool | `true` | Set to false to also allow Kubernetes Events monitor to run on master node. |
| scalyr.k8s.installExplorerDependencies | bool | `false` | Set to true to install additional dependencies which are needed for the complete Kubernetes Explorer experience. This includes node-exporter DaemonSet and kube-state-metrics Deployment. Both of the components are installed into the same namespace as the scalyr agent for easier cleanup. In production deployments, those two components usually get installed into monitoring or kube-system namespace. This functionality is only meant to be used on new clusters which don't already have those components running (e.g. local minikube cluster). |
| scalyr.k8s.verifyKubeletQueries | bool | `true` | Set this to false to disable TLS cert validation of queries to k8s kubelet. By default cert validation is enabled and connection is verified using the CA configured via the service account certificate (/run/secrets/kubernetes.io/serviceaccount/ca.crt file). If you want to use a custom CA bundle, you can do that by setting scalyr.k8s.caCert config option to point to this file (this file needs to be available inside the agent container). In some test environments such as minikube where self signed certs are used you may want to set this to false. |
| scalyr.server | string | `"agent.scalyr.com"` | The Scalyr server to send logs to. Use eu.scalyr.com for EU |
| securityContext | object | `{}` | optional security context entries |
| serviceAccount.annotations | object | `{}` | optional arbitrary service account annotations |
| tolerations | list | `[{"effect":"NoSchedule","key":"node-role.kubernetes.io/master","operator":"Exists"}]` | Pod tolerations. Defaults to the values documented in the official [Installation guide](https://app.scalyr.com/help/install-agent-kubernetes) |
| volumeMounts | object | `{}` | Additional volume mounts to set up |
| volumes | object | `{}` | Additional volumes to mount |

## Setting Custom Scalyr Agent Config Options

If you want to configure additional Scalyr Agent configuration options which are not exposed
directly via dedicated values file options, you can utilize ``scalyr.config`` values file option.

This config option allows you to define additional scalyr agent JSON config file fragments which
are read and parsed by the agent.

Since Helm is not able to correctly pass JSON strings as YAML key values, you should base64 JSON
config fragment value as shown below.

For example, let's say your custom config fragment lives in ``ci/examples/agent.d/my-config.json``.

1. Obtain base64 encoded version of the JSON file content

```bash
cat ci/examples/agent.d/my-config.json | sed -e 's/^ *//' | tr -d '\n' | base64
```

To avoid any YAML formatting issues, we also utilize ``sed`` and ``tr`` command to fold multi line
JSON into a single line

2. After you updated the base64 encoded value, update your values file

```yaml
scalyr:
  apiKey: "REPLACE_ME"
  base64Config: true
  config:
    my-config.json: eyJtYXhfbG9nX29mZnNldF9zaXplIjogNTI0Mjg4MCwiZGVidWdfbGV2ZWwiOiA1fQ==
```

## Development, CI/CD

On each push to master and other branches Github Actions workflow runs which performs basic helm
lint and helm install sanity checks against the changes.

[chart-testing](https://github.com/helm/chart-testing) wrapper is used for running helm lint and
helm install.

To run those checks locally, you need the following tools installed:

* helm 3
* chart-testing
* minikube (or kind cluster against which helm install can run)
* Python 3 with the following 3 libraries installed - yamllint, yamale

```bash
# 1. Install helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# 2. Install minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# 3. Install chart-testing
wget https://github.com/helm/chart-testing/releases/download/v3.4.0/chart-testing_3.4.0_linux_amd64.tar.gz
tar -xzvf chart-testing_3.4.0_linux_amd64.tar.gz
sudo mv ct /usr/local/bin
sudo mv etc ~/.ct

# 4. Create Python virtualenv and install libraries needed by chart testing
python3 -m venv .venv
source .venv/bin/activate
pip install yamale yamllint

# 5. Start minikube Kubernetes cluster
minikube start

# 6. Run actual lint and install task
ct lint --debug --config ci/ct.yaml

# To use valid API key
echo -e 'scalyr:\n  apiKey: "SCALYR_TEST_WRITE_API_KEY"' > charts/scalyr-agent/ci//test-values.yaml

ct install --debug --config ci/ct.yaml
```

You can find more example configs which are used by integration and end to
end tests in ``ci/`` directory.

As an alternative to manually installing those tools and setting up the environment, you can also
use [act](https://github.com/nektos/act) tool which allows you to run GHA workflow locally inside
Docker containers as shown below.

```bash
act lint_test
act
```

Keep in mind that it may take a while since it needs to pull down a large Docker image during the
first run. This tool also may not work correctly on some operating systems since it relies on
Docker inside Docker functionality for creating kind Kubernetes cluster.

## Publishing new version

New version of the chart is automatically released by the [Release](https://github.com/scalyr/helm-scalyr/actions/workflows/release.yml)
Github Actions workflow on push to main branch when changes are detected in the chart (e.g. chart
content or metadata has been updated).

Helm Chart repository is available at https://scalyr.github.io/helm-scalyr/.

## Copyright, License, and Contributor Agreement

Copyright 2020-2021 DO! DevOps. Copyright 2021 SentinelOne, Inc.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this work except
in compliance with the License. You may obtain a copy of the License in the LICENSE file, or at:

http://www.apache.org/licenses/LICENSE-2.0

By contributing you agree that these contributions are your own (or approved by your employer)
and you grant a full, complete, irrevocable copyright license to all users and developers of the
project, present and future, pursuant to the license of the project.

## Thank You

The chart has been originally developed by [Dennis Ploeger](https://github.com/dploeger) from
[dodevops](https://github.com/dodevops). They have agreed to transfer the ownership to Scalyr so we
can continue developing, improving and maintaining the chart.
