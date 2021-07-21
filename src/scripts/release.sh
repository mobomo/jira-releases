#!/bin/bash
set -eu

# VARS EVAL.
RELEASE_NAME=$(eval echo "$RELEASE_NAME")
JIRA_TOKEN=$(eval echo "$JIRA_AUTH_TOKEN")

# Creating the release.
NOW=$(date +"%Y-%m-%d")
VERSION_ID=$(curl -X GET -H "Authorization: Basic ${JIRA_TOKEN}" \
    -H "Content-Type: application/json" \
    "${JIRA_URL}"/rest/api/2/project/"${JIRA_PROJECT}"/versions \
    | jq '. | map(. | select(.name=="'"${RELEASE_NAME}"'"))' | jq .[0].id | tr -d '"')
echo "Created version ID: $VERSION_ID"

# Releasing version.
echo "Releasing version ${RELEASE_NAME}"
curl \
  -X PUT \
  -H "Authorization: Basic ${JIRA_TOKEN}" \
  -H "Content-Type: application/json" \
  --data '{"released": true,"releaseDate": "'"${NOW}"'"}' \
  "${JIRA_URL}"/rest/api/2/version/"$VERSION_ID"

# Release Previous.
if [[ "$RELEASE_PREV" = 1 ]]; then
  echo "Releasing previous versions of ${RELEASE_NAME}"
  PREV_VERSIONS=$(curl \
    -X GET \
    -H "Authorization: Basic ${JIRA_TOKEN}" \
    -H "Content-Type: application/json" \
    "${JIRA_URL}"/rest/api/2/project/"${JIRA_PROJECT}"/versions \
    | jq '. | map(. | select(.released==false))' \
    | jq '. | map(. | select(.id<="'"${VERSION_ID}"'"))' \
    | jq -c '.[].id' | tr -d '"')

  if [ -n "${PREV_VERSIONS}" ]; then
    echo "Found versions: $PREV_VERSIONS"
    for version in ${PREV_VERSIONS//\n/ }
      do
        curl \
          -X PUT \
          -H "Authorization: Basic ${JIRA_TOKEN}" \
          -H "Content-Type: application/json" \
          --data '{"released": true,"releaseDate": "'"${NOW}"'"}' \
          "${JIRA_URL}"/rest/api/2/version/"$version"
      done
  else
    echo "There are no previous unreleased versions."
  fi
fi