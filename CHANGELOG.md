## Scalyr Agent 2 Helm Chart Changes by Release

For actual scalyr agent changelog, please see https://github.com/scalyr/scalyr-agent-2/blob/release/CHANGELOG.md

## 0.2.18

- Add new ``scalyr.k8s.installExplorerDependencies`` chart config option.

  When this option is set to true, all the dependencies / pre-requisites which are required for
  the complete Kubernetes Explorer experience will be installed in the cluster (node-exporter
  DaemonSet and kube state metrics Deployment).

  This option should be used in combination with ``scalyr.k8.enableExplorer`` and is primarily
  meant to be used on fresh / testing clusters.

## 0.2.17

- Add new ``scalyr.k8s.enableExplorer`` chart config option. When this option is set to true, it
  enabled Kubernetes Explorer (https://www.dataset.com/blog/introducing-dataset-kubernetes-explorer/)
  functionality.

  For more information on this functionality, please refer to the docs - https://app.scalyr.com/help/scalyr-agent-k8s-explorer.

- Make sure ``kubernetes_monitor`` has ``stop_agent_on_failure`` monitor config option set to
  ``true`` (which is the default upstream value).

- Add new ``scalyr.debugLevel`` and ``scalyr.ingestDebugLog`` chart config option which enables
  debug logging + debug log ingestion which can help with troubleshooting.

- Update default ``ClusterRole`` definition so it also grants get permissions to ``nodes/proxy``
  and ``/metrics`` endpoints which are required for the Kubernetes Explorer functionality.

## 0.2.16

- Update agent to the latest stable version (v2.1.33).

## 0.2.15

- Update agent to the latest stable version (v2.1.32).

## 0.2.14

- Update agent to the latest stable version (v2.1.31).

## 0.2.13

- Add support for new ``serviceAccount.annotations`` value with which user can specify which
  annotations get added to the created service account.

  This is useful in scenarios where IAM Roles for Service Accounts are used in order to give
  the pods IAM role so they can retrieve secrets. #13

  Contributed by @matthewmrichter.

## 0.2.12

- Update agent to the latest stable version (v2.1.30).

## 0.2.11

- Update agent to the latest stable version (v2.1.29).

## 0.2.10

- Update agent to the latest stable version (v2.1.28).

## 0.2.9

- Update agent to the latest stable version (v2.1.27).

## 0.2.8

- Update agent to the latest stable version (v2.1.26). This new agent version Docker Images now utilize Python 3.8.
- Add new ``image.type`` config option with which user can specify which base type image to use (``buster``, ``alpine``). Defaults to ``buster``.

## 0.2.7

- Update agent to the latest stable version (v2.1.25).

## 0.2.6

- Bump default livenessProbe ``timeoutSeconds`` to ``10`` and allow user to override it via
  ``livenessProbe.timeoutSeconds`` config option.

## 0.2.5

- Update NOTES file to print information on how to retrieve agent pod logs after helm chart
  installation.
- Add agent liveness probe which utilizes ``scalyr-agent status -H`` command. Probe can be disabled
  using ``livenessProbe.enabled`` config option.
- Kubelet CA verification has been enabled by default. If you want to disable it, you can set
  ``k8s.verifyKubeletQueries`` config option to ``false``.
- Chart installation will now fail early if ``scalyr.config`` entry value contains a string value
  which is not correctly base64 encoded.

## 0.2.4

- Scalyr agent has been updated to v2.1.24.
- Removed unnecessary ports resource definition from the deployment and daemonset template.
- Allow user to define arbitrary agent pod labels using ``podLabels`` config option.

## 0.2.3

- Fix permission mask for the ``kubernetes.json`` file which is written as part of the ConfigMap.
