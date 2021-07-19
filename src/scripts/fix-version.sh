#!/bin/bash
set -eu

# VARS EVAL.
TAG_TO_DEPLOY=$(eval echo "$TAG")
JIRA_TOKEN=$(eval echo "$JIRA_AUTH_TOKEN")

# Jira API calls to update tickets fixed version.
add-fix-version() {
  JIRA_ISSUES=$(get-jira-issues) ## @to-do: Replace with the array with the issue keys.
  if [ -n "${JIRA_ISSUES}" ]; then
    echo "Included tickets between ${CURRENT_TAG} and ${TAG_TO_DEPLOY}: ${JIRA_ISSUES}"
    echo "export JIRA_ISSUES=$(get-jira-issues)" >> "$BASH_ENV"
    for issue in ${JIRA_ISSUES//,/ }
      do
        echo "Updating $issue fixVersions field..."
        ## Add (will append to existing ones) ${TAG_TO_DEPLOY} to issue fixVersions field.
        curl \
          -X POST \
          -H "Authorization: Basic ${JIRA_TOKEN}" \
          -H "Content-Type: application/json" \
          --data '{"update":{"fixVersions":[{"add":{"name":"'"${TAG_TO_DEPLOY}"'"}}]}}' \
          "${JIRA_URL}"/rest/api/3/issue/"$issue"
      done
  else
    echo "No issues to update Fix Versions."
    echo 'export JIRA_ISSUES="No Tickets found."' >> "$BASH_ENV"
  fi
}
