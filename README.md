# NWEA MAP Growth

This repository contains code for a Google Cloud Function that fetches CSV files from the NWEA MAP API and loads them to a Google Cloud Storage bucket. This repository is meant to be forked and configured to utilize GitHub Actions to deploy a Cloud Function to Google Cloud.

1. Create a secret nwea-map-password that stores the NWEA MAP password
2. Create a GCS bucket to store CSV extracts
3. Create a service account
4. Grant the service account Storage Object Creator to the bucket
5. Grant the service account Secret Manager Secret Accessor to the secret


## Test function locally:

```bash

cd src;

functions-framework --target=main --debug --signature-type=http;

curl -X POST http://localhost:8080 -H "Content-Type:application/json"

```
