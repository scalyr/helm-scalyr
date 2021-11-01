## Scalyr Agent 2 Helm Chart Changes by Release

For actual scalyr agent changelog, please see https://github.com/scalyr/scalyr-agent-2/blob/master/CHANGELOG.md.

## 0.2.5

- Update NOTES file to print information on how to retrieve pod logs.
- Add agent liveness probes which utilize ``scalyr-agent status -H`` command.
- Kubelet CA vertification has been enabled by default. If you want to disable it, you can set
  ``k8s.verifyKubeletQueries`` config option to ``false``.
- Chart installation will now fail early if ``scalyr.config`` entry value contains a string value
  which is not correctly base64 encoded.

## 0.2.4

- Scalyr agent has been updated to v2.1.24.
- Removed unnecessary ports resource definition from the deployment and daemonset template.
- Allow user to define arbitrary agent pod labels using ``podLabels`` config option.

## 0.2.3

- Fix permission mask for the ``kubernetes.json`` file which is written as part of the ConfigMap.
