## Scalyr Agent 2 Helm Chart Changes by Release

For actual scalyr agent changelog, please see https://github.com/scalyr/scalyr-agent-2/blob/release/CHANGELOG.md

## 0.2.38

- Update chart for DataSet agent v2.2.9 release.


## 0.2.37

- Update chart for DataSet agent v2.2.8 release.

## 0.2.36

- Update chart for DataSet agent v2.2.7 release.

## 0.2.35

- Update chart for DataSet agent v2.2.6 release.

## 0.2.34

- Add new ``useRawApiKeyEnvValue`` chart value. When this value is set to true (defaults to false),
  ``scalyr.apiKey`` chart value is used as-is for the ``SCALYR_API_KEY`` pod environment variable.

  When this value is set to true, corresponding ``Secret`` object is also not created.

  This value can be used in deployments which utilize an operator / tool like kube-secrets-init
  which directly replaces matching prefixed environment variable value with a secret value.

  For more information on the use case and usage of this chart value, please refer to the
  README.md.

  #63 #64

## 0.2.33

- Update chart for DataSet agent v2.2.4 release.

## 0.2.32

- Update chart for DataSet agent v2.2.3 release.

## 0.2.31

- Update ClusterRole to allow interrogation of Argo Rollout resources.
- Update chart for DataSet agent v2.2.2 release.

## 0.2.30

- Update chart for DataSet agent v2.1.40 release.

## 0.2.29

- Update chart for DataSet agent v2.1.39 release.

## 0.2.28

- Update chart for DataSet agent v2.1.38 release.
- Add support of the ``livenessProbe.debug`` option which prints additional info on agent's ``livenessProbe``.

## 0.2.27

- Allow user to set the priority of the Scalyr Agent DaemonSet using ``scalyr.priorityClassName``
  chart value.

  Contributed by @justinb-shipt. #41 #42

## 0.2.26

- Allow user to define additional environment variables for the agent DaemonSet / Deployment
  using new ``extraEnvVars`` chart value.

  Contributed by @xdvpser. #36

## 0.2.25

- Update chart for DataSet agent v2.1.37 release.

## 0.2.24

- Small template formatting fix for DaemonSet and Deployment template ``volumes`` and
  ``volumeMounts`` section. #35

## 0.2.23

- Fix a bug with ``scalyr.base64Config`` chart value not being correctly indented in the ConfigMap
  template.

  Contributed by @xdvpser. #30 #32

## 0.2.22

- Fix a bug with ``volumesMount`` chart value not being used inside the DaemonSet and Deployment
  template.

  Contributed by @xdvpser. #25 #31

## 0.2.21

- Add new ``existingSecretRef`` chart value. When set (defaults to unset), it will use that
  value for the agent ``secretKeyRef`` ``name`` field value. When not set, ``secretKeyRef``
  ``name`` field value defaults to ``{{ include "scalyr-helm.fullname" . }}-scalyr-api-key``.

  This allows users to re-use the existing Kubernetes secret where DataSet API key is stored.

  Contributed by @yuri-1987. #26

## 0.2.20

- Update agent to the latest stable version (v2.1.36).

## 0.2.19

- Update chart to throw an error if required ``scalyr.k8s.clusterName`` value is not specified.
- Update Kubernetes Explorer config to make sure we also scrape Kubernetes API metrics.
  
  Metrics scraping is enabled by default and can be disabled by setting `scaly.k8s.enableMetrics`
  chart value to ``false``.

## 0.2.18

- Add new ``scalyr.k8s.installExplorerDependencies`` chart config option.

  When this option is set to true (defaults to false), all the dependencies / pre-requisites which
  are required for the complete Kubernetes Explorer experience will be installed in the cluster
  (node exporter DaemonSet and kube state metrics Deployment).

  This option should be used in combination with ``scalyr.k8.enableExplorer`` and is primarily
  meant to be used on fresh / testing clusters (e.g. minikube).

- Add new ``scalyr.k8s.eventsIgnoreMaster`` chart config option.

  When this option is set to false (defaults to true), Kubernetes Events monitor will also be
  scheduled on master nodes.

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
