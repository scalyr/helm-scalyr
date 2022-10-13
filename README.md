# scalyr-agent Helm Chart

[![Latest stable release of the Helm chart](https://img.shields.io/badge/dynamic/json.svg?label=stable&url=https://scalyr.github.io/helm-scalyr/info.json&query=$.scalyrAgent&colorB=blue&logo=helm)](https://scalyr.github.io/helm-scalyr/) [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) [![Lint and Tests](https://github.com/scalyr/helm-scalyr/actions/workflows/lint_tests.yml/badge.svg?branch=main)](https://github.com/scalyr/helm-scalyr/actions/workflows/lint_tests.yml) [![End to End Tests](https://github.com/scalyr/helm-scalyr/actions/workflows/end_to_end_tests.yaml/badge.svg?branch=main)](https://github.com/scalyr/helm-scalyr/actions/workflows/end_to_end_tests.yaml)

## Introduction

This helm chart installs the [Scalyr Agent](https://app.scalyr.com/help/scalyr-agent) in a Kubernetes
cluster. Two Agent Plugins plugins are also installed:
- The [Kubernetes monitor](https://app.scalyr.com/monitors/kubernetes) enables the Agent to monitor Kubernetes clusters.
- The [Kubernetes Events monitor](https://app.scalyr.com/monitors/kubernetes-events) collects events from the Kubernetes API server for all nodes except master.

We implement the Kubernetes-recommended node-level logging architecture, running the Agent as a DaemonSet
in your cluster. The DaemonSet runs an Agent pod on each node, and each Agent pod collects logs from other pods on the node.

By default, the Agent collects pod logs and container metrics for all nodes, and *Kubernetes Events* for all nodes except master. You can also install the Agent as a Deployment to monitor other parts of the infrastructure, for example a hosted database service. See "Configuration" below.


## Installation

You must set some items:
- ``scalyr.apiKey``: Must be a "Log Write Access" API key. Log into your DataSet account. Then click on your account (email address), and select "Api Keys".
- ``scalyr.k8s.clusterName``: You must set a name for your Kubernetes cluster, which shows in the UI.
- By default data uploads to our US server. For EU customers, set `scalyr.server="eu.scalyr.com"`.
- `<release-version>`: The latest release version is at the top of the [README](https://scalyr.github.io/helm-scalyr/). For previous releases, you can consult the CHANGELOG.  

To install:

```bash
helm install <release-version> scalyr-agent --repo https://scalyr.github.io/helm-scalyr/ --set scalyr.apiKey="<your write logs api key>" --set scalyr.k8s.clusterName="<your-k8s-cluster-name>"
```

## Install Kubernetes Explorer

This chart also supports Kubernetes Explorer, our latest Kubernetes integration.
(https://www.dataset.com/blog/introducing-dataset-kubernetes-explorer/).  

<a href="https://www.dataset.com/blog/introducing-dataset-kubernetes-explorer/"><img src="https://user-images.githubusercontent.com/125088/186437832-02735d95-5eea-41e0-bb5f-55808fc9c606.png" width="550px"/></a>

With Kubernetes Explorer the Agent also runs the [Openmetrics monitor](https://github.com/scalyr/scalyr-agent-2/tree/master/scalyr_agent/builtin_monitors). This lets you use open source [metric exporters](https://prometheus.io/docs/instrumenting/exporters/) to import metrics from applications running in your cluster.

To install Kubernetes Explorer:

```bash
helm install <release-version> scalyr-agent --repo https://scalyr.github.io/helm-scalyr/ --set scalyr.apiKey="<your write logs api key>" --set scalyr.k8s.clusterName="<your-k8s-cluster-name>" --set scalyr.k8s.enableExplorer=true
```

Two required dependencies, ``node-exporter`` and ``kube-state-metrics``, must be installed. If they are already
installed in your cluster, see [Configure Kubernetes Explorer](https://app.scalyr.com/help/scalyr-agent-k8s-explorer#config-k8s-cluster) to add Annotations to the ``node-exporter`` DaemonSet and the ``kube-state-metrics`` Deployment.

The helm chart can install these components for you, usually to evaluate Kubernetes Explorer in a fresh cluster, for example in minikube. To make cleanup easier, the components install into the same namespace as the Agent.

Note that minikube uses self-signed SSL certificates. You must set ``scalyr.k8s.verifyKubeletQueries`` to ``false`` to disable certificate validation when talking to the Kubelet API. (Unless you have a very good reason, **do not** disable certificate validation in production.)

Also note that minikube runs a single-node (master) by default, and you must set ``scalyr.k8s.eventsIgnoreMaster`` to ``false`` for the Kubernetes Events monitor to run on master.

To install Kubernetes Explorer, ``node-exporter``, and ``kube-state-metrics`` in a single-node minikube cluster:

```bash
helm install <release-version> scalyr-agent --repo https://scalyr.github.io/helm-scalyr/ --set scalyr.apiKey="<your write logs api key>" --set scalyr.k8s.clusterName="<your-k8s-cluster-name>" --set scalyr.k8s.enableExplorer=true --set scalyr.k8s.verifyKubeletQueries=false --set scalyr.k8s.eventsIgnoreMaster=false
```

You can also consult our [Minikube installation](https://app.scalyr.com/help/install-agent-kubernetes-minikube) page for more information on the `Service` and `DaemonSet` for `node-exporter`; and the `Deployment`, `Service`, `ServiceAccount`, `ClusterRole`, and `ClusterRoleBinding` for `kube-state-metrics`.


## Configuration

The chart's [default values](https://github.com/scalyr/helm-scalyr/blob/main/charts/scalyr-agent/values.yaml) are set to monitor a Kubernetes cluster.

To monitor other parts of the infrastructure, for example a Database, set:

* ``controllerType``: It is usually best to set this to "deployment" instead of "daemonset".
* ``scalyr.k8s.enableLogs`` and ``scalyr.k8s.enableEvents``: Set these to ``false`` to remove the serviceaccount, clusterroles and
  other mounts to the Scalyr agent pods.

Configuration takes the [confimap approach](https://app.scalyr.com/help/scalyr-agent-k8s#modify-config). This is basically a key-value
hash. The keys refer to the configuration file name for grouping monitors. The value is the Scalyr json configuration
for each monitor.

To set more configuration options not present in `values.yaml`, you can set the ``scalyr.config`` option in the file. See "Set Custom Configuration Options" below.


## Set Custom Configuration Options

To set Agent configuration options that are not in the chart's [values.yaml](https://github.com/scalyr/helm-scalyr/blob/main/charts/scalyr-agent/values.yaml), set the ``scalyr.config`` option. The Agent reads and parses [JSON file fragments](https://app.scalyr.com/help/scalyr-agent#modularConfig) set in this option. Since Helm cannot pass JSON strings as YAML key values, each JSON fragment must be base64 JSON.

For example, if your custom config fragment is at ``ci/examples/agent.d/my-config.json``:

1\. Create the base64 encoded version of the JSON file content

```bash
cat ci/examples/agent.d/my-config.json | sed -e 's/^ *//' | tr -d '\n' | base64 | tr -d '\n' ; echo ""
```

``sed`` and ``tr`` convert multi-line JSON to a single line to prevent any issues with YAML formatting.

2\. Update your values file

You may want to review the Helm documentation on [values files](https://helm.sh/docs/chart_template_guide/values_files/)

```yaml
scalyr:
  config: {
    my-config.json: eyJtYXhfbG9nX29mZnNldF9zaXplIjogNTI0Mjg4MCwiZGVidWdfbGV2ZWwiOiA1fQ==
  }
```


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


## Changelog

For chart changelog, please see <https://github.com/scalyr/helm-scalyr/blob/main/CHANGELOG.md>.

For agent changelog, please see <https://github.com/scalyr/scalyr-agent-2/blob/release/CHANGELOG.md>.

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
echo -e 'scalyr:\n  apiKey: "SCALYR_TEST_WRITE_API_KEY"' > charts/scalyr-agent/ci/test-values.yaml

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
