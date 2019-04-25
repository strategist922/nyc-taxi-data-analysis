# nyc-taxi-data-analysis

This repository contains AWS architecture made with Terraform and Python scripts to 
analyse [The New York City Taxi and Limousine Commission dataset](https://www1.nyc.gov/site/tlc/about/tlc-trip-record-data.page).

## Build infrastructure
Run Terraform to build AWS infrastructure specifying owner prefix that will be added before all generated aws resources and region.
```
$ terraform init
$ terraform apply -var owner=nickname -var region=eu-central-1
```

Terraform generates 32 AWS resources.


## Usage
In the first step, we can import [dataset](https://www1.nyc.gov/site/tlc/about/tlc-trip-record-data.page) to S3 (267 GB) into `data` folder. 
We can do this by running `nyc-taxi-import-data` state machine, that will generate
bucket structure, partition our data by company, year, month and import all csv files one by one using Lambda functions.

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

Next step is crawling our data (yellow taxi dataset ~39.6 GB), and transforming them to Parquet format. 
To achieve that we can simply run Glue Crawler `nyc-taxi-data-crawler`. 
Succeeded crawler will automatically trigger next steps of transformation (using CloudWatch, Step Functions, Glue Job, Lambda and Glue Crawler).
As a result our data will be stored on S3 in `parquet-data` folder.