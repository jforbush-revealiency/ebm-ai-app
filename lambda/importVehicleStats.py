import json
import os
import urllib
import boto3
from urllib import request, parse

print('Loading EBM AI Vehicle Stats import function')

s3 = boto3.client('s3')

# Set EBM_API_URL in your Lambda environment variables.
# After deploying to Render, set this to: https://your-app.onrender.com/secure/api/vehicle_stats/import_stat_file
EBM_API_URL = os.environ.get('EBM_API_URL', 'https://your-render-app.onrender.com/secure/api/vehicle_stats/import_stat_file')

def lambda_handler(event, context):
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')

    print(f"New file detected: s3://{bucket}/{key}")

    try:
        params = {'bucket': bucket, 'file_key': key}
        data = urllib.parse.urlencode(params).encode()

        req = request.Request(EBM_API_URL)
        try:
            with request.urlopen(req, data) as f:
                response_body = f.read().decode('utf-8')
                print(f"API response: {response_body}")
                return response_body
        except Exception as e:
            print(f"Error calling EBM API: {e}")
            raise e

    except Exception as e:
        print(f"Error processing s3://{bucket}/{key}: {e}")
        raise e
