#!/usr/bin/env bash
# Utility script which calls scalyr query tools and exists with non in case the provided query
# returns no results after maximum number of retry attempts has been reached. We perform multiple
# retries to make the build process more robust and less flakey and to account for delayed
# ingestion for any reason.

set -e

SCALYR_TOOL_QUERY=$1

function retry_on_failure {
  i=1
  retry_attempts=5
  sleep_delay=10

  until [ "${i}" -ge "${retry_attempts}" ]
  do
     echo ""
     echo "Running function \"$@\" attempt ${i}/${retry_attempts}..."
     echo ""

     exit_code=0
     "$@" && break
     exit_code=$?

     echo ""
     echo "Sleeping ${sleep_delay} before next attempt.."
     echo ""

     i=$((i+1))
     sleep ${sleep_delay}
  done

  if [ "${exit_code}" -ne 0 ]; then
      echo "Command failed to complete successfully after ${retry_attempts} attempts. Exiting with non-zero." >&2
      exit 1
  fi
}

function query_scalyr {
    echo "Using query '${SCALYR_TOOL_QUERY}'"

    RESULT=$(eval "scalyr query '${SCALYR_TOOL_QUERY}' --columns='timestamp,severity,message' --start='200m' --count='100' --output multiline")
    RESULT_LINES=$(echo -e "${RESULT}" | sed '/^$/d' | wc -l)

    echo "Results for query '${SCALYR_TOOL_QUERY}':"
    echo -e "${RESULT}"

    if [ "${RESULT_LINES}" -lt 1 ]; then
        echo "Expected at least 1 matching line, got none"
        return 1
    fi

    echo "Found ${RESULT_LINES} matching log lines"
    return 0
}

retry_on_failure query_scalyr
