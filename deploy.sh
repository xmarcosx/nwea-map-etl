if [ -f .env ]; then
    export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
fi

gcloud services enable cloudbuild.googleapis.com;
gcloud services enable cloudfunctions.googleapis.com;
gcloud services enable cloudscheduler.googleapis.com;

gcloud iam service-accounts create nwea-map-etl;

gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT \
    --member="serviceAccount:nwea-map-etl@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com" \
    --role=roles/iam.serviceAccountUser \
    --role=roles/cloudfunctions.developer \
    --role=roles/secretmanager.secretAccessor \
    --role=roles/storage.objectAdmin;

printf $NWEA_PASSWORD | gcloud secrets create nwea-map-password --data-file=-;

gsutil mb -p $GOOGLE_CLOUD_PROJECT gs://nwea-map-$GOOGLE_CLOUD_PROJECT;

cd src;

gcloud functions deploy nwea-map-etl \
    --project $GOOGLE_CLOUD_PROJECT \
    --service-account nwea-map-etl@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com \
    --runtime python37 \
    --entry-point main \
    --trigger-http \
    --set-env-vars GCS_BUCKET=$GCS_BUCKET \
    --set-env-vars NWEA_USERNAME=$NWEA_USERNAME;

 gcloud scheduler jobs create http nwea_map_function_trigger \
    --schedule "0 5 * * *" \
    --time-zone "America/Chicago"\
    --uri "http://myproject/my-url.com"
    --http-method POST;