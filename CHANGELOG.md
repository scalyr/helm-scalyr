## Scalyr Agent 2 Helm Chart Changes by Release

For actual scalyr agent changelog, please see https://github.com/scalyr/scalyr-agent-2/blob/master/CHANGELOG.md.

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
