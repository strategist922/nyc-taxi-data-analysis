variable "owner" {
  type = "string"
}

variable "lambda-worker-arn" {
  type = "string"
}

variable "lambda-iterator-arn" {
  type = "string"
}

variable "lambda-s3-structure-builder-arn" {
  type = "string"
}

variable "convert-to-parquet-job-name" {
  type = "string"
}

variable "run-crawler-lambda-function-arn" {
  type = "string"
}
