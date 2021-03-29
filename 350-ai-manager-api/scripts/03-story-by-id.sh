#!/usr/bin/env bash

AI_MANAGER_URL=https://aiops-dev-aiops.gsi-waiops-4c.us-south.containers.appdomain.cloud
USERNAME=admin
PASSWORD=
INSTANCE_NAME=devaimanager

STORY_ID=ad083f5c-9095-11eb-b9cc-2a7a84175224

TOKEN_URL=$AI_MANAGER_URL/aiops/v1/auth/token
MAIN_URL=$AI_MANAGER_URL/aiops/instances/$INSTANCE_NAME/api/v1/stories/$STORY_ID

# Get Token
JSON_DATA=" \"username\": \"$USERNAME\", \"password\": \"$PASSWORD\" "
TOKEN_VALUE=$(curl -X POST --header "Content-Type: application/json" --header "Accept: application/json" -d "{$JSON_DATA}" "$TOKEN_URL" | jq -r ".token" )

# Get Story by id
curl --location --request GET "$MAIN_URL" --header "Authorization: Bearer $TOKEN_VALUE"


