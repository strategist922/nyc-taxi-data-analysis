output "lambda-worker-arn" {
  value = "${aws_lambda_function.lambda-worker.arn}"
}

output "lambda-iterator-arn" {
  value = "${aws_lambda_function.lambda-iterator.arn}"
}

output "lambda-s3-structure-builder-arn" {
  value = "${aws_lambda_function.lambda-s3-structure-builder.arn}"
}