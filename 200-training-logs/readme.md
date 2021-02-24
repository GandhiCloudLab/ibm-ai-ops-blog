# Training Log anomaly models for AI Manager in Watson AI-Ops

This article explains about how to train normal logs from LogDNA/Humio and create log anomaly models for AI Manager in Watson AI-Ops.

The article is based on the the following
 - RedHat OpenShift 4.5 on IBM Cloud (ROKS)
 - Watson AIOps 2.1

## Overview

Here is the architecture and flow of  Watson AI-Ops.

<img src="images/aimanager-arch-flow.png">

Note: Humio is used in the architecture. But you can use LogDNA as well.

Here is the overall steps to be done for Log Anomaly detection. As part of this article, we will do the checked steps.

- [ ] 1. Integrate Slack at AI-Manager Instance level
- [ ] 2. Create Application Group
- [ ] 3. Integrate ASM at App Group level
- [ ] 4. Create Application (bookinfo)
- [x] 5. Train Log Anomaly Models (LogDNA)
- [ ] 6. Integrate LogDNA at app level
- [ ] 7. Introduce Log Anomaly at BookInfo app
- [ ] 8. View new Incident in a slack story


Here is the picture about overall steps.

<img src="images/log-anomaly-detection-steps.png">

## 1. Download logs from LogDNA / Humio

Download normal logs (logs without error) from LogDNA / Humio. 

The content of the file would be looking like [this](files/normal-1.json). 

Refer the below articles to know how to download logs.


## 2. Generate Training Scripts

1. Open the `bookinfo` app from the `aimanager` instance.

2. Select the `Insight Models` tab.

3. Click on the `edit` icon of the `Logs Model` item.

<img src="images/apps-insight-models-log1.png">

### Give version number for the training

For first time training, enter `1` as a version number, otherwise, give next version. 

<img src="images/apps-insight-models-log2.png">

Here in this case, we are giving verion number as `2`.  Click on `Generate Scripts`

<img src="images/apps-insight-models-log3.png">

### Generate Training scripts

Here is the training script generated. You can use this info for training. Here `Application Group Id` and `Application Id` can be noted.

<img src="images/apps-insight-models-log4.png">


## 3. Training

### 3.1 Prepare Normal Logs

Let us assume, we have already trained the normal logs version `1`. For the next time training here the version should be  `2`.

#### Rename log file

Rename the log file into `normal-2.json` as we train for 2nd time.

For the first time, the log file name should be `normal-1.json`

#### gzip log file

gzip the log file by running the below command

```
  gzip normal-2.json
```

You will get `normal-2.json.gz` file.

#### Move the log file under version number folder

Create a folder with the version number. And copy the log file side by running the below command.

```
  mkdir 2
  cp normal-2.json.gz 2
```

### 3.2 Get into training POD

#### Login to Cluster

```
oc login --token=YYYYYYYYYYYYYYYYYY --server=https://a111-e.us-south.containers.cloud.ibm.com:11111
```

#### Switch Namespace

Switch to namespace where AI Manager is installed.

Ex: 
```
oc project aiops21
```

#### Get into training POD

Get into the `model-train-console` POD

```
 oc exec -it $(oc get po |grep model-train-console|awk '{print $1}') bash
```

### 3.3 Create Directory Structure

It is required to create Directory Structure in the training POD. The directory structure contains  `log-ingest` , `Application Group Id` and `Application Id` directories.

Run the below command.

```
 mkdir -p /home/zeno/data/log-ingest/vmsvhjhj/uj0r4jom
```

Here 

`vmsvhjhj` is `Application Group Id`

`uj0r4jom` is `Application Id`


### 3.4 Copy Logs  from local system to training pod

#### Open New Terminal Window

Open another Terminal Window

#### Copy Normal logs to Training POD

1. Goto the folder `2` where we have stored the normal logs.

2. Run the below command to copy the file to training pod.

```
oc cp 2 $(oc get po |grep model-train-console|awk '{print $1}'):/home/zeno/data/log-ingest/vmsvhjhj/uj0r4jom
```

#### Back to the Training POD shell

Go back to the previous terminal window, where we had the training POD shell.

### 3.5 Copy logs from Training POD to s3 bucket

#### Create S3 bucket from Training POD

Create S3 buckets by doing the below step. It will create, if it is not exists.

```
  aws s3 mb s3://log-ingest
```

#### Copy log data from Training POD to s3 bucket

Run the below command, to copy to s3 bucket

```
aws s3 cp /home/zeno/data/log-ingest s3://log-ingest/ --recursive
```

The output would be something like the below.

```
upload: log-ingest/vmsvhjhj/uj0r4jom/2/normal-2.json.gz to s3://log-ingest/vmsvhjhj/uj0r4jom/2/normal-2.json.gz
```

### 3.6 Update S3 Datastore

This is one time process.

Need to modify the `mount_cos` datastore into `s3_datastore` in the training pod.

Refer Appendix section below.

### 3.7 Update Mapping file

This is one time process. 

This step can be skipped for LogDNA as it is a default one.

Need to create `groupid-appid-ingest_conf.json` in the training pod for humio/elk/splunk logs. The template is already given below.

```
/home/zeno/train/ingest_configs/log/groupid-appid-ingest_conf.json.elk_example
/home/zeno/train/ingest_configs/log/groupid-appid-ingest_conf.json.humio_example
/home/zeno/train/ingest_configs/log/groupid-appid-ingest_conf.json.splunk_example
```

For creating mapping file for humio you can run the below command. 

```
cd /home/zeno/train/ingest_configs/log
cp groupid-appid-ingest_conf.json.humio_example vmsvhjhj-uj0r4jom-ingest_conf.json
```

Here 

`vmsvhjhj` is `Application Group Id`

`uj0r4jom` is `Application Id`

### 3.8 Run training

#### Run 

Run the below command to start the training.

```
cd /home/zeno/train
python3 train_pipeline.pyc -p "log" -g "vmsvhjhj" -a "uj0r4jom" -v "2"
```

#### Output

The output could be the following.

```
Launching Jobs for: Log Ingest Training
	prepare training environment

	training_ids:
		1: ['training-YJGzTF-MR']
	jobs ids are saved here: JOBS/vmsvhjhj/uj0r4jom/2/log_ingest.json

.............
.............
.............

```

#### Verify trained model

Run the following curl command inside the model-train-console pod to verify the existence of trained models:


```
curl -u $ES_USERNAME:$ES_PASSWORD -XGET https://$ES_ENDPOINT/_cat/indices  --insecure | grep vmsvhjhj-uj0r4jom-2
```

Note: There should be four models in Elasticsearch (applications, pca_model, pca_fe, and templates).


#### Error during training

When there is an error during the training and you want to delete the training entry, then you can do that using DLaaS.

Refer Appendix section below.

## Quick Reference

```
oc project devaiops
cd /Users/jeyagandhi/Gandhi/01-Tasks/049-AI-Ops/Work/20210202-wealthcare-dev/humio/logs
oc cp 1 $(oc get po |grep model-train-console|awk '{print $1}'):/home/zeno/data/log-ingest/w0vpv1gi/za4xk6hg

oc exec -it $(oc get po |grep model-train-console|awk '{print$1}') bash

aws s3 ls s3://log-ingest/w0vpv1gi/za4xk6hg/
aws s3 cp /home/zeno/data/log-ingest/  s3://log-ingest/ --recursive
aws s3 rm s3://log-ingest/w0vpv1gi/za4xk6hg/1/.DS_Store

cd /home/zeno/train
python3 train_pipeline.pyc -p "log" -g "w0vpv1gi" -a "za4xk6hg" -v "1"

Verify trained model:
curl -u $ES_USERNAME:$ES_PASSWORD -XGET https://$ES_ENDPOINT/_cat/indices  --insecure | grep w0vpv1gi-za4xk6hg-1

Note: There should be four models in Elasticsearch (applications, pca_model, pca_fe, and templates).

```

## Appendix

### 1. Update S3 Datastore in Learner POD

#### Update S3-Datastore in Learner POD

This documentation explains about how to modify the `mount_cos` datastore into `s3_datastore` in the training pod.

This update to be done before start the logs/etc training.

You could see the error in the `learner` pod.

<img src="images/01-error.png">

#### Training POD

Get into the training pod.

```
 oc exec -it $(oc get po |grep model-train-console|awk '{print $1}') bash
```

#### Get into the folder

```
cd /home/zeno/train/manifests/s3fs-pvc

ls

```

The output could be like the below.

```
log_ingest.yaml
event_group.yaml
event_ingest.yaml
log_anomaly_eval.yaml
log_ingest_eval.yaml
event_group_eval.yaml
log_anomaly.yaml
```

#### Replace the datastore

1. Open the above files one by one

2. Find for text `mount_cos`

<img src="images/02-find.png">

3. Replace it with `s3_datastore`

<img src="images/03-replace.png">

### 2. DLaaS (Deep Learning as a Service)

DLaaS helps to cleanup if any error occured during the logs training.

#### Training POD

DLaaS commands to be run inside the training POD.

Here is the command to get into the training pod.

```
 oc exec -it $(oc get po |grep model-train-console|awk '{print $1}') bash
```

#### dlaas ls

This command lists all trainings done so far.

```
<user1>$ dlaas ls
```

The output could be like the below.

```
ID                 NAME        FRAMEWORKS                    STATUS    START                         COMPLETED 
training--J3iZj1Gg Log Ingest  data-preprocessing-mtworkflow           2020-12-18 07:08:05 +0000 UTC 2020-12-18 07:11:12 +0000 UTC
training-yD3OZjJGR Log Anomaly log-anomaly-training                    2020-12-18 07:12:27 +0000 UTC 2020-12-18 07:14:58 +0000 UTC
training-hwqOZC1GR Log Anomaly log-anomaly-training                    2020-12-18 07:12:28 +0000 UTC 2020-12-18 07:17:15 +0000 UTC
training-DkeOWCJMR Log Anomaly log-anomaly-training                    2020-12-18 07:12:28 +0000 UTC 2020-12-18 07:20:03 +0000 UTC
training-U3cbGK-Mg Log Ingest  data-preprocessing-mtworkflow           2021-01-05 04:19:04 +0000 UTC 2021-01-05 04:22:13 +0000 UTC
training-oQ5lGF-MR Log Anomaly log-anomaly-training                    2021-01-05 04:23:26 +0000 UTC 2021-01-05 04:26:12 +0000 UTC
training-97tlMKaGg Log Anomaly log-anomaly-training                    2021-01-05 04:23:27 +0000 UTC 2021-01-05 04:27:37 +0000 UTC
```

#### dlaas delete

This command delete the mentioned trainings.

```
dlaas delete training-obRpLKaGg training-ZmzpYK-Mg
```

##  Reference

### 1. MinIO Client Complete Guide

aws s3 commands are available here.

https://docs.min.io/docs/minio-client-complete-guide.html


### 2. Knowledge center documentation
The reference to the knowledge center documentation is available here.

https://www.ibm.com/support/knowledgecenter/en/SSQLRP_2.1/train/aiops-train-model-ovr.html

https://www.ibm.com/support/knowledgecenter/en/SSQLRP_2.1/train/aiops-train-model-la.html


### 3. Other related Articles

Configuring AI-Manager in Watson AI-Ops

https://community.ibm.com/community/user/middleware/blogs/jeya-gandhi-rajan-m1/2021/02/09/configuring-ai-manager-in-watson-ai-ops


Log Anomaly Detection by AI-Manager in Watson AI-Ops

https://community.ibm.com/community/user/middleware/blogs/jeya-gandhi-rajan-m1/2021/02/14/log-anomaly-detection-by-ai-manager-in-w-ai-ops

