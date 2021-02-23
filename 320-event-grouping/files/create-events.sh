#!/bin/bash

JSON_PATH=@./op1
USER_PWD=root:sssssssssss
URL_NOI=http://eventmgr-route-namespace.cluster.us-south.containers.appdomain.cloud/objectserver/restapi/alerts/status

curl -X POST -v -u $USER_PWD -H "Accept: application/json" -H "Content-Type: application/json" -d @ratings_down.json $URL_NOI
curl -X POST -v -u $USER_PWD -H "Accept: application/json" -H "Content-Type: application/json" -d @reviews-v2_down.json $URL_NOI
curl -X POST -v -u $USER_PWD -H "Accept: application/json" -H "Content-Type: application/json" -d @reviews-v3_down.json $URL_NOI
curl -X POST -v -u $USER_PWD -H "Accept: application/json" -H "Content-Type: application/json" -d @poductpage_down.json $URL_NOI
