# Configuring AI-Manager

This article explains about how to configure AI-Manager for training and inferencing the logs/events/incidents.

This article is based on
- RedHat OpenShift 4.5 on IBM Cloud (ROKS)
- Watson AI-Ops 2.1

## Overview

The core capabilities of the AI-Manager in Watson AI-Ops are

- Log Anomaly Detection
- Event Grouping
- Incident Similarity

It is required to do the following configurations in AI-Manager before training and inferencing the logs/events/incidents.

* AI Manager Instance
    * Application Groups at Instance level
    * Ops Integration at Instance level (Slack, ServiceNow)
* Application Groups
    * Applications at Application Group Level
    * Ops Integration at Application Group Level (ASM Toplogy)
* Applications
    * Ops Integration at Application Level (LogDNA, Humio, PagerDuty, NOI-Events, ELK, Splunk)
    * Insight Models at Application Level (Logs/incidents/events training)

Here is the architecture and flow of  Watson AI-Ops.

<img src="images/aimanager-arch-flow.png">

Note: Humio is used in the architecture. But you can use LogDNA as well.

Here is teh overall steps to be done for Log Anomaly detection. As part of this article, we will do the checked steps.

- [X] 1. Integrate Slack at AI-Manager Instance level
- [X] 2. Create Application Group
- [X] 3. Integrate ASM at App Group level
- [X] 4. Create Application (bookinfo)
- [ ] 5. Train Log Anomaly Models (LogDNA)
- [x] 6. Integrate LogDNA at app level
- [ ] 7. Introduce Log Anomaly at BookInfo app
- [ ] 8. View new Incident in a slack story

Here is the picture about overall steps.

<img src="images/log-anomaly-detection-steps.png">

----

## 1. AI-Manager Instance

Open AI-Manager console.

Click on the `View All` to see the AI-manager instances.

<img src="images/01-ai-manager-welcome.png">


The below picture shows the AI-Manager instances list. Here there is one entry found with the name `aimanager`. This was installed by default when the AI-Manager was installed.

Click on the `Open` link to see details of the instance.

<img src="images/02-ai-manager-home.png">

At AI-Manager instane level the following can be configured.

* Application Groups
* Ops Integration (Slack, ServiceNow)

### 1.1 Application Groups at AI-Manager Instance Level

We can create Application groups at this level. The below picture shows list of Application groups available in the `aimanager` instance.

There is a group called `Financial Apps` already created and listed here.

<img src="images/03-ai-manager-appgroup.png">

### 1.2 Ops Integrations at AI-Manager Instance Level

The below picture shows the Ops Integration where `slack` is being already integrated.

Click on the `...` link to see details of the `slack` integration.

<img src="images/04-ai-manager-ops-int.png">

#### 1.2.1 Slack configuration

The below picture shows the `slack` configuration details.

You should have already created a `slack` channel and those details to be furnished here.

<img src="images/05-ai-manager-ops-int-slack.png">

----

## 2. Application Group 

At Application Group  level the following can be configured.

* Applications
* Ops Integration (ASM Toplogy)

### 2.1 Application Group Configuration

#### Select a group

Click on the `...` link to see details of the `Financial Apps` group.

<img src="images/06-ai-manager-appgroup-select.png">

#### Edit

Here is the configuration of the Group. 

You need to enter slack channel id in the `Platform Channel ID`.

<img src="images/07-ai-manager-appgroup-edit.png">

#### Create

The create group screens looks like the below.

<img src="images/08-ai-manager-appgroup-create.png">


### 2.2 Ops Integration at Application Group Level

The below picture shows that the `Financial Apps` group is integrated with `ASM`.

Click on the `...` link to see details of the `ASM` integration.

<img src="images/09-appgroup-int.png">

#### 2.2.1 ASM (Netcool Agile Service Manager) Configuration

Here is the configuration of the `ASM`

<img src="images/10-appgroup-int-edit1.png">
<img src="images/10-appgroup-int-edit2.png">
<img src="images/10-appgroup-int-edit3.png">

### 2.3 Application at Application Group Level

The below picture shows list of applications installed under the `Financial Apps` group.

<img src="images/11-apps.png">

----

## 3. Applications

At Application level the following can be configured.

* Ops Integration (LogDNA, Humio, PagerDuty, NOI-Events, ELK, Splunk)
* Insight Models (Logs/incidents/events training)

From the above picture, click on the `bookinfo` app to see details of that.

### 3.1 Ops Integration at Application level

At App level integration can be done with below tools.

```
KAFKA
LogDNA
Humio
ELK
PagerDuty
Splunk
Custom
```

In most of the cases, atleast 2 integrations are configured per app.

- NOI-Events using `Kafka`
- Logs using `LogDNA` or `Humio`

#### 3.1.1 Integration with LogDNA and Kafka

The below picture shows that the application is integrated with `LogDNA`  and   `Kafka`.

You can click  on `...` link to see details of the `LogDNA`  and `Kafka`.

**Note:** You can do this step only after training the logs.

<img src="images/12-apps-int-home.png">

#### 3.1.1.1 LogDNA

1. The below picture shows the `LogDNA` configuration.

<img src="images/13-apps-int-logdna-edit0.png">
<img src="images/13-apps-int-logdna-edit1.png">
<img src="images/13-apps-int-logdna-edit3.png">

2. You can get the LogDNA Service Key from the below location in the logdna UI.

<img src="images/17-logdna.png">

3. You may need to update the Mapping as well.

```json
{
    "codec": "logdna",
    "message_field": "_line",
    "log_entity_types": "pod,_cluster,container",
    "instance_id_field": "_app",
    "rolling_time": 10,
    "timestamp_field": "_ts"
}
```

<img src="images/13-apps-int-logdna-edit5-mapping.png">


#### 3.1.1.2 Kafka (NOI-Events)

The below picture shows the `NOI-Events` configuration.

<img src="images/14-apps-int-noi-edit0.png">
<img src="images/14-apps-int-noi-edit1.png">

----

#### 3.1.2 Integration with Humio and Kafka

The below picture shows that the application is integrated with `Humio`  and   `Kafka`.

You can click  on `...` link to see details of the `Humio`  and `Kafka`.

<img src="images/20-humio.png">

#### Humio

1. The below picture shows the `Humio` configuration.

<img src="images/21-humio-edit1.png">
<img src="images/21-humio-edit2.png">
<img src="images/21-humio-edit3.png">

2. You can get the Humio Service Key from the below location in the Humio UI.

<img src="images/23-humio-keys.png">

3. You may need to update the Mapping as well.

<img src="images/22-humio-mapping1.png">
<img src="images/22-humio-mapping2.png">

```
{
    "codec": "humio",
    "message_field": "@rawstring",
    "log_entity_types": "clusterName, kubernetes.container_image_id, kubernetes.host, kubernetes.container_name, kubernetes.pod_name",
    "instance_id_field": "kubernetes.container_name",
    "rolling_time": 10,
    "timestamp_field": "@timestamp"
}
```
----

#### 3.1.3 Other Integrations options to the app

The below picture shows `create ops integration` screen with other integration options such as `Humio`, `ELK` and etc.

<img src="images/15-apps-int-create.png">

----

### 3.2 Insight Models

The below picture shows the `Insight Models` configured for the application.

You can train the logs, incidents, events and etc.

<img src="images/16-apps-insight-models.png">