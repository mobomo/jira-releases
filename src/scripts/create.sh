#!/bin/bash
set -eu

# VARS EVAL.
JIRA_TOKEN=$(eval echo "$JIRA_AUTH_TOKEN")
ISSUE_KEYS=$(eval echo "$ISSUE_KEYS")
RELEASE_NAME=$(eval echo "$RELEASE_NAME")
echo "$SET_RELEASED"

# Creating the release.
NOW=$(date +"%Y-%m-%d")
VERSION_ID=$(curl -X POST -H "Authorization: Basic ${JIRA_TOKEN}" \
    -H "Content-Type: application/json" \
    --data '{"name": "'"${RELEASE_NAME}"'","startDate": "'"${NOW}"'","project": "'"${JIRA_PROJECT}"'", "released": false}' \
    "${JIRA_URL}"/rest/api/2/version | jq .id | tr -d '"')

echo "Created version ID: $VERSION_ID"

# Jira API calls to update tickets fixed version.
add-fix-version() {
  if [ -n "${ISSUE_KEYS}" ]; then
    for issue in ${ISSUE_KEYS//,/ }
      do
        echo "Updating $issue fixVersions field..."
        ## Add (will append to existing ones) ${RELEASE_NAME} to issue fixVersions field.
        curl \
          -X PUT \
          -H "Authorization: Basic ${JIRA_TOKEN}" \
          -H "Content-Type: application/json" \
          --data '{"update":{"fixVersions":[{"add":{"name":"'"${RELEASE_NAME}"'"}}]}}' \
          "${JIRA_URL}"/rest/api/2/issue/"$issue"
      done
  else
    echo "No issues to update Fix Versions."
    exit 1
  fi
}

add-fix-version

if [[ "$SET_RELEASED" = 1 ]]; then
  echo "Releasing version ${RELEASE_NAME}"
  echo "${JIRA_URL}/rest/api/2/version/${VERSION_ID}"
  curl \
    -X PUT \
    -H "Authorization: Basic ${JIRA_TOKEN}" \
    -H "Content-Type: application/json" \
    --data '{"name":"'"${RELEASE_NAME}"'", "released": true, "releaseDate": "'"${NOW}"'"}' \
    "${JIRA_URL}"/rest/api/2/version/"${VERSION_ID}"
fi
