import json
import boto3
import os

s3 = boto3.client('s3')
TARGET_BUCKET = os.environ['targetBucket']

def lambda_handler(event, context):

    sourceBucket = "nyc-tlc"
    prefix = "trip data/yellow"
    index = event.get("iterator").get("index")

    objects = s3.list_objects(Bucket=sourceBucket, Prefix=prefix)['Contents']
    sourceFile = objects[index]['Key']
    year = sourceFile.split('_')[2].split('-')[0]
    month = sourceFile.split('-')[1].split('.')[0]
    companyName = sourceFile.split('/')[1].split('_')[0]
    targetFilePath = f"data/{companyName}/{year}/{month}/{companyName}.csv"

    message = f"Copy from {sourceFile} -> {targetFilePath}"
    print(message)

    iterator = {
        "index": event.get("iterator").get("index"),
        "step": event.get("iterator").get("step")
    }

    copySource = {
        'Bucket': sourceBucket,
        'Key': sourceFile
    }

    s3.copy(copySource, TARGET_BUCKET, targetFilePath)
    print("Done")

    return {
        "count": event.get("count"),
        "iterator": iterator
    }
