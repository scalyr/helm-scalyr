# scalyr-helm

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2.1.11](https://img.shields.io/badge/AppVersion-2.1.11-informational?style=flat-square)

## Introduction

This helm chart installs the [Scalyr Agent monitor](https://app.scalyr.com/help/scalyr-agent) into a Kubernetes
cluster. It supports installing the agent with all features required to support a Kubernetes cluster monitoring.
Additionally, it can deploy Scalyr agents which monitor other parts of the infrastructure (for example a hosted
database service etc.).

## Configuration

Two basic configuration keys have to be set up to allow logging to Scalyr cloud:

* scalyr.server: The name of the Scalyr api server (defaults to scalyr.com)
* scalyr.apiKey: The api key used to authenticate to the Scalyr api server
* scalyr.config: The Scalyr configuration

The scalyr configuration is done using the
[configuration map approach](https://app.scalyr.com/help/scalyr-agent-k8s#modify-config). This is basically a key/value
hash. The keys refer to the configuration file name for grouping monitors. The value is the Scalyr json configuration
for each monitor.

## Controller type

By default, this chart creates a daemonset which is the recommended deployment pattern for Kubernetes monitoring.

If you'd like to create a different Scalyr agent, you can set `controllerType` to "deployment" and set `supportK8s` to
false.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | optional affinity rules |
| controllerType | string | `"deamonset"` | Wether to setup a daemonset or a deployment for the Scalyr agent A daemonset should be used for Kubernetes monitoring while a deployment should be used for single resource monitorings (e.g. hosted databases, etc.) Valid values: "daemonset" or "deployment" |
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
| scalyr.config | object | `{}` | A hash of configuration files and their json content as documented in the [Scalyr agent configmap configuration documentation](https://app.scalyr.com/help/scalyr-agent-k8s#modify-config) |
| scalyr.k8s.caCert | string | `""` | The path to the CA certificate to use to verify TLS-connection to the kubelet |
| scalyr.k8s.clusterName | string | `""` | The kubernetes cluster name (when using the kubernetes monitoring) |
| scalyr.k8s.verifyKubeletQueries | string | `"false"` | Set this to true and set up scalyr.k8s.caCert to activate TLS validation of queries to the k8s kubelet |
| scalyr.server | string | `"scalyr.com"` | The Scalyr server to send logs to |
| securityContext | object | `{}` | optional security context entries |
| supportK8s | bool | `true` | enable all features required for Kubernetes monitoring |
| tolerations | list | `[{"effect":"NoSchedule","key":"node-role.kubernetes.io/master","operator":"Exists"}]` | Pod tolerations. Defaults to the values documented in the official [Installation guide](https://app.scalyr.com/help/install-agent-kubernetes) |
| volumeMounts | object | `{}` | Additional volume mounts to set up |
| volumes | object | `{}` | Additional volumes to mount |

