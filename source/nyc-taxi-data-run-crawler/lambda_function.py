import boto3
import os

client = boto3.client('glue')
CRAWLER_NAME = os.environ['startCrawlerName']

def lambda_handler(event, context):
    response = client.start_crawler(Name=CRAWLER_NAME)