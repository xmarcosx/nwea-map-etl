# NWEA MAP Growth

This repository contains code for a Google Cloud Function that fetches CSV files from the NWEA MAP API and uploads them to a Google Cloud Storage bucket. This repository is meant to be forked and configured to utilize GitHub Actions to deploy a Cloud Function to Google Cloud. This will allow future updates to this codebase to be brought into your environment

The Cloud Function can be scheduled to be triggered nightly causing the CSV files in the Cloud Storage bucket to always represent current assessment term data as of the previous day.

## Schedule recurring NWEA MAP export
In NWEA MAP:

1. Click on View Reports > MAP Growth Reports
2. Click on Data Export Scheduler > [schedule a data export](https://teach.mapnwea.org/report/map/comprehensiveDataFile.seam)
3. Enable Data Export Scheduler
4. Set Frequency to **Daily**
5. Select a preferred Export Type (Comprehensive is recommended)
6. Select your preferred options under Contents
7. Click Save

## Deploy Cloud Function
Navigate to your Google Cloud project and active Cloud Shell.

```bash

git clone https://github.com/xmarcosx/nwea-map-etl.git;
cd nwea-map-etl;
cp .env-prod .env;

```


## Configure Google Cloud
In your Google Cloud project:

1. Create a [service account](https://console.cloud.google.com/iam-admin/serviceaccounts) that will be used to deploy the Cloud Function
    * Set a name (ie. *deploy-cloud-function*)
    * Grant the account the following roles:
        * Service Account User
        * Cloud Functions Developer
        * Secret Manager Secret Accessor
2. Download a [JSON service account key](https://cloud.google.com/iam/docs/creating-managing-service-account-keys#iam-service-account-keys-create-console) for the new user
3. Create a secret in [Secret Manager](https://console.cloud.google.com/security/secret-manager) to store your NWEA password
    * Name it `nwea-map-password`
    * Set the value to your NWEA MAP password
    * Click Create Secret
4. Create a [Cloud Storage bucket](https://console.cloud.google.com/storage/browser) that will house your NWEA MAP CSV files
    * Give your service account the role *Storage Object Admin*
5. 


## Scheduling a nightly trigger
Google Cloud Scheduler can be used to automatically run the Cloud Function once a day.

1. Head to [Google Cloud Scheduler](https://console.cloud.google.com/cloudscheduler)
2. Click **Schedule a job**
3. Select a location, click **Next**
4. Give the job a name (ie. nwea_map_function_trigger)
5. Set a frequency (ie. `0 5 * * *` will trigger the job every day at 5 AM)
6. Set a timezone
7. Click **Continue**
8. Set Target type to **HTTP**
9. Set URL to your Cloud Function's [trigger URL](https://console.cloud.google.com/functions/details/us-central1/nwea-map-etl?tab=trigger)
10. Set Auth header to **Add OIDC token**
11. Set Service account to the email of your App Engine default service account which can be found under [Service Accounts](https://console.cloud.google.com/iam-admin/serviceaccounts)
12. Set Audience to the Cloud Function trigger URL you used above
13. Click **Continue**
14. Click **Create**

<!-- 

## Test function locally:

```bash

cd src;

functions-framework --target=main --debug --signature-type=http;

curl -X POST http://localhost:8080 -H "Content-Type:application/json"

``` -->
