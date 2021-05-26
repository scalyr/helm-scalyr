# scalyr-agent

[![Artifact HUB](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/scalyr-agent)](https://artifacthub.io/packages/search?repo=scalyr-agent) ![Version: 0.2.0](https://img.shields.io/badge/Version-0.2.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2.1.20](https://img.shields.io/badge/AppVersion-2.1.20-informational?style=flat-square)

## Introduction

This helm chart installs the [Scalyr Agent monitor](https://app.scalyr.com/help/scalyr-agent) into a Kubernetes
cluster. It supports installing the agent with all features required to support a Kubernetes cluster monitoring.
Additionally, it can deploy Scalyr agents which monitor other parts of the infrastructure (for example a hosted
database service etc.).

This chart is not affiliated with Scalyr, Inc. in any way. For support, please open an issue in this
project's [issue tracker](https://github.com/dodevops/helm-scalyr/issues).

## Installation

Use

    helm install <name of release> scalyr-agent --repo https://dodevops.io/helm-scalyr

to install this chart.

## Configuration

Two basic configuration keys have to be set up to allow logging to Scalyr cloud:

* scalyr.server: The name of the Scalyr api server (defaults to scalyr.com)
* scalyr.apiKey: The api key used to authenticate to the Scalyr api server
* scalyr.config: The Scalyr configuration

The scalyr configuration is done using the
[configuration map approach](https://app.scalyr.com/help/scalyr-agent-k8s#modify-config). This is basically a key/value
hash. The keys refer to the configuration file name for grouping monitors. The value is the Scalyr json configuration
for each monitor.

This chart's default values are set to support the monitoring of a Kubernetes cluster. The only value you have
to set manually is:

* config.k8s.clusterName: name of the Kubernetes cluster to monitor (will be visible in the Scalyr UI)

If you want to monitor additional things outside of Kubernetes (e.g. Databases), you can set the following values:

* controllerType: For other monitors, it is usually best to set this to "deployment" instead of "daemonset"
* supportK8s: Set this to false to remove the serviceaccount, clusterroles and additional mounts to the Scalyr
 agent pods

## Controller type

By default, this chart creates a daemonset which is the recommended deployment pattern for Kubernetes monitoring.

If you'd like to create a different Scalyr agent, you can set `controllerType` to "deployment" and set `supportK8s` to
false.

**Homepage:** <https://github.com/dodevops/helm-scalyr>

## Source Code

* <https://github.com/dodevops/helm-scalyr>

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
| imagePullSecrets | list | `[]` | Image pull secrets to use if the image is in a private repository |
| nameOverride | string | `""` | Override the default name that helm calculates |
| nodeSelector | object | `{}` | optional node selectors |
| podAnnotations | object | `{}` | optional pod annotations |
| podSecurityContext | object | `{}` |  |
| resources | object | `{"limits":{"cpu":"500m","memory":"500Mi"},"requests":{"cpu":"500m","memory":"500Mi"}}` | Pod resources. Defaults to the values documented in the official [Installation guide](https://app.scalyr.com/help/install-agent-kubernetes) |
| scalyr.apiKey | string | `""` | The Scalyr API key to use |
| scalyr.base64Config | bool | `true` | As Helm is currently [unable to correctly pass JSON strings](https://github.com/helm/helm/issues/5618), this can be set to true so all values of scalyr.config are expected to be base64 encoded and will be decoded in the chart |
| scalyr.config | object | `{}` | A hash of configuration files and their content as documented in the [Scalyr agent configmap configuration documentation](https://app.scalyr.com/help/scalyr-agent-k8s#modify-config) |
| scalyr.k8s.caCert | string | `""` | The path to the CA certificate to use to verify TLS-connection to the kubelet |
| scalyr.k8s.clusterName | string | `""` | The kubernetes cluster name (when using the kubernetes monitoring) |
| scalyr.k8s.enableEvents | bool | `true` | Enable fetching Kubernetes events |
| scalyr.k8s.enableLogs | bool | `true` | Enable fetching Pod/Container logs from Kubernetes |
| scalyr.k8s.enableMetrics | bool | `true` | Enable fetching Kubernetes metrics. This requires scalyr.k8s.enableLogs to be true |
| scalyr.k8s.verifyKubeletQueries | string | `"false"` | Set this to true and set up scalyr.k8s.caCert to activate TLS validation of queries to the k8s kubelet |
| scalyr.server | string | `"scalyr.com"` | The Scalyr server to send logs to |
| securityContext | object | `{}` | optional security context entries |
| tolerations | list | `[{"effect":"NoSchedule","key":"node-role.kubernetes.io/master","operator":"Exists"}]` | Pod tolerations. Defaults to the values documented in the official [Installation guide](https://app.scalyr.com/help/install-agent-kubernetes) |
| volumeMounts | object | `{}` | Additional volume mounts to set up |
| volumes | object | `{}` | Additional volumes to mount |

