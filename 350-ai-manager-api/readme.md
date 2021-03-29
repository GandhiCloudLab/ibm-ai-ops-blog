# Using AI-Manager APIs in Watson AI-Ops

This article explains about how to use AI-Manager APIs to access the following from your AI-Manager instance.

- App Groups and Apps
- Stories list
- Story Details
- Similar Incidents

This article is based on

RedHat OpenShift 4.5 on IBM Cloud (ROKS)
Watson AI-Ops 2.1


Here is the link to Knowledge centre about this topic https://www.ibm.com/support/knowledgecenter/SSQLRP_2.1/api/aiops.json


## Auth Token

Auth Token is required to communicate with the AI-Manager APIs. 

The Auth token can be retrieved using the below commands.

```bash
AI_MANAGER_URL=https://aiops-dev-aiops.gsi-waiops-4c.us-south.containers.appdomain.cloud
USERNAME=admin
PASSWORD=
INSTANCE_NAME=devaimanager

TOKEN_URL=$AI_MANAGER_URL/aiops/v1/auth/token
MAIN_URL=$AI_MANAGER_URL/aiops/instances/$INSTANCE_NAME/api/v1/stories

# Get Token
JSON_DATA=" \"username\": \"$USERNAME\", \"password\": \"$PASSWORD\" "
TOKEN_VALUE=$(curl -X POST --header "Content-Type: application/json" --header "Accept: application/json" -d "{$JSON_DATA}" "$TOKEN_URL" | jq -r ".token" )
echo $TOKEN_VALUE
```

Here USERNAME and PASSWORD are AI Manager console credentials.

## 1. App Groups and Apps

Using the above retrieved auth token, the Application Groups and Application details can be retrieved using the below commands.

```bash
MAIN_URL=$AI_MANAGER_URL/aiops/instances/$INSTANCE_NAME/api/v1/application_groups

# Get Application Groups
curl --location --request GET "$MAIN_URL" --header "Authorization: Bearer $TOKEN_VALUE"
```

The complete script is available [here](https://github.com/GandhiCloudLab/ibm-ai-ops-blog/tree/master/350-ai-manager-api/scripts/01-app-groups.sh) 

The sample output is available [here](https://github.com/GandhiCloudLab/ibm-ai-ops-blog/tree/master/350-ai-manager-api/scripts/output/01-appgroups.json)


## 2. Stories

All the stories avialable for the ai-manager instance can retrieved using the below commands. 

The above retrieved auth token should also be used.

```bash
MAIN_URL=$AI_MANAGER_URL/aiops/instances/$INSTANCE_NAME/api/v1/stories

# Get Stories
curl --location --request GET "$MAIN_URL" --header "Authorization: Bearer $TOKEN_VALUE"
```

The complete script is available [here](https://github.com/GandhiCloudLab/ibm-ai-ops-blog/tree/master/350-ai-manager-api/scripts/02-stories.sh) 

The sample output is available [here](https://github.com/GandhiCloudLab/ibm-ai-ops-blog/tree/master/350-ai-manager-api/scripts/output/02-stories.json) 

## 3. Story details by id

The story detail can be accessed for the story id using the below commands. 

The above retrieved auth token should also be used.


```bash
STORY_ID=ad083f5c-9095-11eb-b9cc-2a7a84175224

MAIN_URL=$AI_MANAGER_URL/aiops/instances/$INSTANCE_NAME/api/v1/stories/$STORY_ID

# Get Story by id
curl --location --request GET "$MAIN_URL" --header "Authorization: Bearer $TOKEN_VALUE"
```

The complete script is available [here](https://github.com/GandhiCloudLab/ibm-ai-ops-blog/tree/master/350-ai-manager-api/scripts/03-story-by-id.sh) 

The sample output is available [here](https://github.com/GandhiCloudLab/ibm-ai-ops-blog/tree/master/350-ai-manager-api/scripts/output/03-story-by-id.json)


## 4. Similar Incident Search

The similar incidents list can be retrieved by passing the search text and story id as like the below. 

```bash
STORY_ID=ad083f5c-9095-11eb-b9cc-2a7a84175224
APPLICATION_GROUP_ID=9aemlr67
APPLICATION_ID=sglve7ly
SEARCH_TEXT=ratings

MAIN_URL=$AI_MANAGER_URL/aiops/instances/$INSTANCE_NAME/api/v1/incidents/search

# incidents search
JSON_DATA=" \"story_id\": \"$STORY_ID\", \"app_group_id\": \"$APPLICATION_GROUP_ID\", \"app_id\": \"$APPLICATION_ID\", \"search_text\": \"$SEARCH_TEXT\" "
curl -X POST --header "Authorization: Bearer ${TOKEN_VALUE}" --header "Content-Type: application/json" --header "Accept: application/json" -d "{$JSON_DATA}" "$MAIN_URL"
```

The complete script is available [here](https://github.com/GandhiCloudLab/ibm-ai-ops-blog/tree/master/350-ai-manager-api/scripts/04-incidents-search.sh) 

The sample output is available [here](https://github.com/GandhiCloudLab/ibm-ai-ops-blog/tree/master/350-ai-manager-api/scripts/output/04-similar-incidents.json)