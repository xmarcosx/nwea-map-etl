if [ -f .env ]; then
    export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
fi

gcloud services enable cloudbuild.googleapis.com;
gcloud services enable cloudfunctions.googleapis.com;
gcloud services enable cloudscheduler.googleapis.com;
gcloud services enable secretmanager.googleapis.com;

gcloud iam service-accounts create nwea-map-etl;

gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT \
    --member="serviceAccount:nwea-map-etl@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com" \
    --role=roles/iam.serviceAccountUser;

gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT \
    --member="serviceAccount:nwea-map-etl@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com" \
    --role=roles/cloudfunctions.developer;

gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT \
    --member="serviceAccount:nwea-map-etl@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com" \
    --role=roles/secretmanager.secretAccessor;

gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT \
    --member="serviceAccount:nwea-map-etl@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com" \
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
    --set-env-vars GCS_BUCKET=nwea-map-$GOOGLE_CLOUD_PROJECT \
    --set-env-vars NWEA_USERNAME=$NWEA_USERNAME \
    --quiet;

gcloud app create --region=us-central;

gcloud scheduler jobs create http nwea_map_function_trigger \
    --schedule "0 5 * * *" \
    --time-zone "America/Chicago"\
    --uri "https://us-central1-$GOOGLE_CLOUD_PROJECT.cloudfunctions.net/nwea-map-etl" \
    --http-method POST \
    --oidc-service-account-email $GOOGLE_CLOUD_PROJECT@appspot.gserviceaccount.com \
    --oidc-token-audience "https://us-central1-$GOOGLE_CLOUD_PROJECT.cloudfunctions.net/nwea-map-etl" \
    --project $GOOGLE_CLOUD_PROJECT \
    --quiet;
