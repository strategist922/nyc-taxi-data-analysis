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

Then data can be transformed to Parquet format and stored in parqued-data folder. Size for yellow taxi trip data: 39.6 GB)