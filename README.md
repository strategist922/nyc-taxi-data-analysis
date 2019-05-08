# :taxi: nyc-taxi-data-analysis

This repository contains AWS architecture made with Terraform and Python scripts to 
analyse [The New York City Taxi and Limousine Commission dataset](https://www1.nyc.gov/site/tlc/about/tlc-trip-record-data.page).

This analysis is focused on `yellow` taxi data, but can be easily improved to process `green` and `fhv` data too.

Initial raw data size is 225.3 GB of CSV format files containing 957 667 710 rows of data.

---
## About: Yellow Medallion Taxicabs
These are the famous NYC yellow taxis that provide transportation exclusively through street-hails. 
The number of taxicabs is limited by a finite number of medallions issued by the TLC. 
You access this mode of transportation by standing in the street and hailing an available 
taxi with your hand. The pickups are not pre-arranged.

## Build infrastructure
First and foremost create S3 bucket with your own prefix. For example using AWS CLI: 
```
aws s3api create-bucket --bucket your-name-nyc-taxi --region eu-central-1
```

Run Terraform to build AWS infrastructure with the same prefix and region as created bucket. 
This prefix will be added before all generated aws resources.

```
$ terraform init
$ terraform apply -var owner=your-name -var region=eu-central-1
```

## AWS QuickSight sample visualizations

### Most popular taxi pick-up places
![QuickSight visualization](/quicksight/2.png)

### Number of taxi trips by year (dataset size)
![QuickSight visualization](/quicksight/1.png)

### Average trip distance by year (in miles)
![QuickSight visualization](/quicksight/3.png)

### Busiest days of the week (records count)
![QuickSight visualization](/quicksight/4.png)

### Vendor impact (records count)
![QuickSight visualization](/quicksight/5.png)

### Busiest months of the year
![QuickSight visualization](/quicksight/6.png)
