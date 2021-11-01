## Scalyr Agent 2 Helm Chart Changes by Release

For actual scalyr agent changelog, please see https://github.com/scalyr/scalyr-agent-2/blob/master/CHANGELOG.md.

## 0.2.4

- Scalyr agent has been updated to v2.1.24.
- Removed unnecessary ports resource definition from the deployment and daemonset template.
- Allow user to define arbitrary agent pod labels using ``podLabels`` config option.

## 0.2.3

- Fix permission mask for the ``kubernetes.json`` file which is written as part of the ConfigMap.
