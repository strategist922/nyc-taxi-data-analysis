import json
import boto3

s3 = boto3.client('s3')

def lambda_handler(event, context):
    
    sourceBucket = "nyc-tlc"
    targetBucket = "rmitula-nyc-taxi-data-3"
    prefix = "trip data/"
    index = event.get("iterator").get("index")
    
    objects = s3.list_objects(Bucket=sourceBucket, Prefix=prefix)['Contents']
    sourceFile = objects[index]['Key']
    year = sourceFile.split('_')[2].split('-')[0]
    month = sourceFile.split('-')[1].split('.')[0]
    targetFile = sourceFile.split('/')[1].split('_')[0]
    targetFilePath = f"{year}/{month}/{targetFile}.csv"
    
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

    s3.copy(copySource, targetBucket, targetFilePath)
    print("Done")

    return {
        "count": event.get("count"),
        "iterator": iterator
    }
