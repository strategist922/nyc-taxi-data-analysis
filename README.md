# nyc-taxi-data-analysis

This repository contains AWS architecture made of Terraform and Python scripts to 
analyse [The New York City Taxi and Limousine Commission dataset](https://www1.nyc.gov/site/tlc/about/tlc-trip-record-data.page).
 
In the first step whole dataset is imported to S3 bucket into data folder (267 GB).
Processed data are partitioned by company, year, month and stored in the folowing structure:

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

Then data from S3 are crawled and transformed to Parquet format using AWS Glue Python script (runs around 1 hour). 
Processed data is stored on S3 in parquet-data folder (size for yellow taxi trip data: 39.6 GB)

# How to use?
Run terraform apply specifying owner prefix that will be added before all generated aws resources
```
$ terraform apply -var owner=nickname
```