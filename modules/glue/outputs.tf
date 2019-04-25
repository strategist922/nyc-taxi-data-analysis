output "convert-to-parquet-job-name" {
  value = "${module.job.convert-to-parquet-job-name}"
}

output "sourceDataCrawlerName" {
  value = "${module.crawler.sourceDataCrawlerName}"
}

output "parquetDataCrawlerName" {
  value = "${module.crawler.parquetDataCrawlerName}"
}
