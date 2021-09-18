import glob
import io
import os
import zipfile

import requests

from google.cloud import secretmanager, storage


gcp_project_id = os.environ.get('GCP_PROJECT')

def get_secret():
    client = secretmanager.SecretManagerServiceClient()
    response = client.access_secret_version(
        {"name": f"projects/{gcp_project_id}/secrets/nwea-map-password/versions/latest"})
    
    return response.payload.data.decode("UTF-8")

def main(request):

    nwea_api_url = 'https://api.mapnwea.org/services/reporting/dex'
    nwea_password = get_secret()
    nwea_username = os.environ.get('NWEA_USERNAME')
    gcs_bucket = os.environ.get('GCS_BUCKET')

    
    session = requests.Session()
    session.auth = (nwea_username, nwea_password)
    response = session.request('GET', nwea_api_url)

    if response.ok is False:
        response.raise_for_status()

    zip = zipfile.ZipFile(io.BytesIO(response.content))
    zip.extractall('/tmp')

    storage_client = storage.Client()
    bucket = storage_client.bucket(gcs_bucket)
    for csv_path in glob.glob('/tmp/*.csv'):
        blob = bucket.blob(os.path.basename(csv_path))
        blob.upload_from_filename(csv_path)

    return f'Uploaded CSV files to GCS'
