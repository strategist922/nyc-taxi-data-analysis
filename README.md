# nyc-taxi-data-analysis

This repository contains AWS architecture made of Terraform and Python scripts to 
analyse [The New York City Taxi and Limousine Commission dataset](https://www1.nyc.gov/site/tlc/about/tlc-trip-record-data.page).
 
In the first step whole dataset is imported to S3 bucket into data folder (267 GB).
Processed data are partitioned by company, year, month and stored in the following structure:


Then data from S3 are crawled and transformed to Parquet format using AWS Glue Python script (runs around 1 hour). 
Processed data is stored on S3 in parquet-data folder (size for yellow taxi trip data: 39.6 GB)

## Build infrastructure
Run Terraform to build AWS infrastructure specifying owner prefix that will be added before all generated aws resources and region.
```
$ terraform init
$ terraform apply -var owner=nickname -var region=eu-central-1
```

Terraform generates 32 AWS resources.


## Usage
In the first step, we can import [dataset](https://www1.nyc.gov/site/tlc/about/tlc-trip-record-data.page) to S3 into `data` folder. 
We can do this by running `nyc-taxi-import-data` state machine, that will generate
bucket structure, and import all csv files one by one with Lambda functions.

### S3 file structure
```
├── data
│  ├── fhv
│  ├── green
│  └── yellow
│     ├── 2018
│     ├── ...
│        ├── 01
│           └── yellow.csv
│        ├── ...
├── parquet-data
├── glue-scripts
```

Next step is crawling our data (yellow taxi dataset), and transforming them to Parquet format. 
To achieve that we can simply run Glue Crawler `nyc-taxi-data-crawler`. 
Succeeded crawler will automatically trigger next steps of transformation (using CloudWatch, Step Functions, Glue Job, Lambda and Glue Crawler)
As a result our data will be stored on S3 in `parquet-data` folder.