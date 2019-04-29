provider "aws" {
  region = "${var.region}"
}

module "lambda" {
  source           = "./modules/lambda"
  owner            = "${var.owner}"
  startCrawlerName = "${module.glue.parquetDataCrawlerName}"
}

module "state-machine" {
  source                          = "./modules/state-machine"
  owner                           = "${var.owner}"
  lambda-iterator-arn             = "${module.lambda.lambda-iterator-arn}"
  lambda-worker-arn               = "${module.lambda.lambda-worker-arn}"
  lambda-s3-structure-builder-arn = "${module.lambda.lambda-s3-structure-builder-arn}"
  run-crawler-lambda-function-arn = "${module.lambda.lambda-run-crawler-arn}"
  convert-to-parquet-job-name     = "${module.glue.convert-to-parquet-job-name}"
  region                          = "${var.region}"
}

module "glue" {
  source = "modules/glue"
  owner  = "${var.owner}"
}

module "cloudwatch" {
  source                    = "modules/cloudwatch"
  owner                     = "${var.owner}"
  crawler-state-machine-arn = "${module.state-machine.crawler-state-machine-arn}"
  dataCrawlerName           = "${module.glue.sourceDataCrawlerName}"
}
