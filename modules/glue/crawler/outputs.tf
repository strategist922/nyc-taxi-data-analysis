output "sourceDataCrawlerName" {
  value = "${aws_glue_crawler.source-data-crawler.name}"
}

output "parquetDataCrawlerName" {
  value = "${aws_glue_crawler.parquet-data-crawler.name}"
}
