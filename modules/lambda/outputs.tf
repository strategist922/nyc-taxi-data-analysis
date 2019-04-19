output "lambda-worker-arn" {
  value = "${aws_lambda_function.lambda-worker.arn}"
}

output "lambda-iterator-arn" {
  value = "${aws_lambda_function.lambda-iterator.arn}"
}