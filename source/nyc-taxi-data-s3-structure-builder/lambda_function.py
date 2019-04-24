import json
import boto3

s3 = boto3.client('s3')

sourceBucket = "nyc-tlc"
targetBucket = "rmitula-nyc-taxi"

companies = ['fhv', 'green', 'yellow']
years = range(2009, 2019)
months = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12']

def lambda_handler(event, context):
    
    for company in companies:
        for year in years:
            for month in months:
                print(f": {company}/{year}/{month}")
                response = s3.put_object(
                    Bucket = targetBucket,
                    Key = f"data/{company}/{year}/{month}/"
                )

    print("Finished")

    iterator = {
        "index": event.get("iterator").get("index"),
        "step": event.get("iterator").get("step")
    }

    return {
        "count": event.get("count"),
        "iterator": iterator
    }


