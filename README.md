# NWEA MAP Growth

This repository contains code for a Google Cloud Function that fetches CSV files from the NWEA MAP API and uploads them to a Google Cloud Storage bucket.

## Schedule recurring NWEA MAP export
In NWEA MAP...

1. Click on View Reports > MAP Growth Reports
2. Click on Data Export Scheduler > [schedule a data export](https://teach.mapnwea.org/report/map/comprehensiveDataFile.seam)
3. Enable Data Export Scheduler
4. Set Frequency to **Daily**
5. Select a preferred Export Type (Comprehensive is recommended)
6. Select your preferred options under Contents
7. Click Save

## Deploy Cloud Function
The `deploy.sh` file handles all steps necessary to deploy the Cloud Function. This involves creating a service account, Secret, and Cloud Storage bucket. A Cloud Scheduler job is also created to trigger the Cloud Function nightly causing the CSV files in the Cloud Storage bucket to always represent current assessment term data as of the previous day.

Navigate to your Google Cloud project and activate Cloud Shell. Run the commands below:

```bash

git clone https://github.com/xmarcosx/nwea-map-etl.git;
cd nwea-map-etl;
cp .env-prod .env;
```

Complete the .env file by filling in your NWEA MAP username and password.

```bash
bash deploy.sh
```

<!-- 

## Test function locally:

```bash

cd src;

functions-framework --target=main --debug --signature-type=http;

curl -X POST http://localhost:8080 -H "Content-Type:application/json"

``` -->
