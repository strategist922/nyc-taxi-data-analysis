data "archive_file" "lambda-iterator" {
  type        = "zip"
  source_file = "source/nyc-taxi-data-step-function-iterator/lambda_function.py"
  output_path = "output/lambda-iterator.zip"
}

data "archive_file" "lambda-worker" {
  type        = "zip"
  source_file = "source/nyc-taxi-data-step-function-worker/lambda_function.py"
  output_path = "output/lambda-worker.zip"
}

data "archive_file" "lambda-s3-structure-builder" {
  type        = "zip"
  source_file = "source/nyc-taxi-data-s3-structure-builder/lambda_function.py"
  output_path = "output/lambda-iterator-s3-structure-builder.zip"
}

data "archive_file" "lambda-run-crawler" {
  type        = "zip"
  source_file = "source/nyc-taxi-data-run-crawler/lambda_function.py"
  output_path = "output/lambda-run-crawler.zip"
}

data "template_file" "role-policy" {
  template = "${file("modules/lambda/role-policy.json")}"
}

data "template_file" "s3-access-policy" {
  template = "${file("modules/lambda/s3-access-policy.json")}"
}

resource "aws_lambda_function" "lambda-iterator" {
  function_name    = "${var.owner}-nyc-taxi-data-iterator"
  handler          = "lambda_function.lambda_handler"
  description      = "Step function index iterator"
  runtime          = "python3.7"
  filename         = "${data.archive_file.lambda-iterator.output_path}"
  source_code_hash = "${data.archive_file.lambda-iterator.output_base64sha256}"
  role             = "${aws_iam_role.lambda-iterator-iam-role.arn}"

  tags = {
    owner = "${var.owner}"
  }
}

resource "aws_lambda_function" "lambda-worker" {
  function_name    = "${var.owner}-nyc-taxi-data-worker"
  handler          = "lambda_function.lambda_handler"
  description      = "Importing data to S3 repository"
  runtime          = "python3.7"
  timeout          = "900"
  filename         = "${data.archive_file.lambda-worker.output_path}"
  source_code_hash = "${data.archive_file.lambda-worker.output_base64sha256}"
  role             = "${aws_iam_role.lambda-iam-role.arn}"

  environment = {
    variables = {
      targetBucket = "${var.owner}-nyc-taxi"
    }
  }

  tags = {
    owner = "${var.owner}"
  }
}

resource "aws_lambda_function" "lambda-s3-structure-builder" {
  function_name    = "${var.owner}-nyc-taxi-data-s3-structure-builder"
  handler          = "lambda_function.lambda_handler"
  description      = "Creating S3 bucket structure"
  runtime          = "python3.7"
  timeout          = "100"
  filename         = "${data.archive_file.lambda-s3-structure-builder.output_path}"
  source_code_hash = "${data.archive_file.lambda-s3-structure-builder.output_base64sha256}"
  role             = "${aws_iam_role.lambda-iam-role.arn}"

  environment = {
    variables = {
      targetBucket = "${var.owner}-nyc-taxi"
    }
  }

  tags = {
    owner = "${var.owner}"
  }
}

resource "aws_lambda_function" "lambda-run-crawler" {
  function_name    = "${var.owner}-nyc-taxi-data-run-crawler"
  handler          = "lambda_function.lambda_handler"
  description      = "Run AWS Glue crawler on parquet catalog"
  runtime          = "python3.7"
  filename         = "${data.archive_file.lambda-run-crawler.output_path}"
  source_code_hash = "${data.archive_file.lambda-run-crawler.output_base64sha256}"
  role             = "${aws_iam_role.lambda-run-crawler-iam-role.arn}"

  environment = {
    variables = {
      startCrawlerName = "${var.startCrawlerName}"
    }
  }

  tags = {
    owner = "${var.owner}"
  }
}

resource "aws_iam_role" "lambda-iterator-iam-role" {
  name               = "${var.owner}-nyc-taxi-data-lambda-iterator-role"
  assume_role_policy = "${data.template_file.role-policy.rendered}"

  tags = {
    owner = "${var.owner}"
  }
}

resource "aws_iam_role" "lambda-iam-role" {
  name               = "${var.owner}-nyc-taxi-data-lambda"
  assume_role_policy = "${data.template_file.role-policy.rendered}"

  tags = {
    owner = "${var.owner}"
  }
}

resource "aws_iam_role" "lambda-run-crawler-iam-role" {
  name               = "${var.owner}-nyc-taxi-data-lambda-run-crawler"
  assume_role_policy = "${data.template_file.role-policy.rendered}"

  tags = {
    owner = "${var.owner}"
  }
}

resource "aws_iam_role_policy" "lambda-worker-iam-role-policy" {
  name   = "${var.owner}-nyc-taxi-data-lambda-role-policy"
  role   = "${aws_iam_role.lambda-iam-role.id}"
  policy = "${data.template_file.s3-access-policy.rendered}"
}

resource "aws_iam_role_policy_attachment" "iam-service-role" {
  role       = "${aws_iam_role.lambda-run-crawler-iam-role.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}
