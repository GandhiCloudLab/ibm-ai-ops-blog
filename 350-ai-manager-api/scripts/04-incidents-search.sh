#!/usr/bin/env bash
             
AI_MANAGER_URL=https://aiops-dev-aiops.gsi-waiops-4c.us-south.containers.appdomain.cloud
USERNAME=admin
PASSWORD=
INSTANCE_NAME=devaimanager

STORY_ID=ad083f5c-9095-11eb-b9cc-2a7a84175224
APPLICATION_GROUP_ID=9aemlr67
APPLICATION_ID=sglve7ly
SEARCH_TEXT=ratings

TOKEN_URL=$AI_MANAGER_URL/aiops/v1/auth/token
MAIN_URL=$AI_MANAGER_URL/aiops/instances/$INSTANCE_NAME/api/v1/incidents/search

# Get Token
JSON_DATA=" \"username\": \"$USERNAME\", \"password\": \"$PASSWORD\" "
TOKEN_VALUE=$(curl -X POST --header "Content-Type: application/json" --header "Accept: application/json" -d "{$JSON_DATA}" "$TOKEN_URL" | jq -r ".token" )

# incidents search
JSON_DATA=" \"story_id\": \"$STORY_ID\", \"app_group_id\": \"$APPLICATION_GROUP_ID\", \"app_id\": \"$APPLICATION_ID\",  \"search_text\": \"$SEARCH_TEXT\" "
curl -X POST --header "Authorization: Bearer ${TOKEN_VALUE}" --header "Content-Type: application/json" --header "Accept: application/json" -d "{$JSON_DATA}" "$MAIN_URL"
