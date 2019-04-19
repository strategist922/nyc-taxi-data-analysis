data "archive_file" "lambda-iterator" {
  type          = "zip"
  source_file   = "source/nyc-taxi-data-step-function-iterator/lambda_function.py"
  output_path   = "output/lambda-iterator.zip"
}

data "archive_file" "lambda-worker" {
  type          = "zip"
  source_file   = "source/nyc-taxi-data-step-function-worker/lambda_function.py"
  output_path   = "output/lambda-worker.zip"
}

data "template_file" "role-policy" {
  template = "${file("modules/lambda/role-policy.json")}"
}

data "template_file" "s3-access-policy" {
  template = "${file("modules/lambda/s3-access-policy.json")}"
}

resource "aws_lambda_function" "lambda-iterator" {
  function_name = "${var.owner}-nyc-taxi-data-iterator"
  handler = "lambda_function.lambda_handler"
  description = "Step function index iterator"
  runtime = "python3.7"
  filename = "${data.archive_file.lambda-iterator.output_path}"
  source_code_hash = "${data.archive_file.lambda-iterator.output_base64sha256}"
  role = "${aws_iam_role.lambda-iterator-iam-role.arn}"
  tags = {
    owner = "${var.owner}"
  }
}

resource "aws_lambda_function" "lambda-worker" {
  function_name = "${var.owner}-nyc-taxi-data-worker"
  handler = "lambda_function.lambda_handler"
  description = "Importing data to S3 repository"
  runtime = "python3.7"
  timeout = "900"
  filename = "${data.archive_file.lambda-worker.output_path}"
  source_code_hash = "${data.archive_file.lambda-worker.output_base64sha256}"
  role = "${aws_iam_role.lambda-worker-iam-role.arn}"
  tags = {
    owner = "${var.owner}"
  }
}

resource "aws_iam_role" "lambda-iterator-iam-role" {
  name = "${var.owner}-nyc-taxi-data-lambda-iterator-role"
  assume_role_policy = "${data.template_file.role-policy.rendered}"
  tags = {
    owner = "${var.owner}"
  }
}

resource "aws_iam_role" "lambda-worker-iam-role" {
  name = "${var.owner}-nyc-taxi-data-lambda-worker-role"
  assume_role_policy = "${data.template_file.role-policy.rendered}"
  tags = {
    owner = "${var.owner}"
  }
}

resource "aws_iam_role_policy" "lambda-worker-iam-role-policy" {
  name = "${var.owner}-nyc-taxi-data-lambda-role-policy"
  role = "${aws_iam_role.lambda-worker-iam-role.id}"
  policy = "${data.template_file.s3-access-policy.rendered}"
}
