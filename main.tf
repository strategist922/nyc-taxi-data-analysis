provider "aws" {
  region = "eu-central-1"
}

module "lambda" {
  source = "./modules/lambda"
  owner = "${var.owner}"
}

module "state-machine" {
  source = "./modules/state-machine"
  owner = "${var.owner}"
  lambda-iterator-arn = "${module.lambda.lambda-iterator-arn}"
  lambda-worker-arn = "${module.lambda.lambda-worker-arn}"
  lambda-s3-structure-builder-arn = "${module.lambda.lambda-s3-structure-builder-arn}"
}