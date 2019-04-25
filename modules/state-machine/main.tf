data "template_file" "import-data-definition" {
  template = "${file("modules/state-machine/step-machine-definitions/import-data-state-machine-definition.json")}"

  vars {
    lambda-iterator-arn             = "${var.lambda-iterator-arn}"
    lambda-worker-arn               = "${var.lambda-worker-arn}"
    lambda-s3-structure-builder-arn = "${var.lambda-s3-structure-builder-arn}"
  }
}

data "template_file" "run-crawler-definition" {
  template = "${file("modules/state-machine/step-machine-definitions/crawler-state-machine-definition.json")}"

  vars {
    convert-to-parquet-job-name     = "${var.convert-to-parquet-job-name}"
    run-crawler-lambda-function-arn = "${var.run-crawler-lambda-function-arn}"
  }
}

data "template_file" "state-machine-role-policy" {
  template = "${file("modules/state-machine/state-machine-role-policy.json")}"
}

data "template_file" "lambda-invoke-policy" {
  template = "${file("modules/state-machine/lambda-invoke-policy.json")}"
}

resource "aws_sfn_state_machine" "import-data-state-machine" {
  name     = "${var.owner}-nyc-taxi-import-data"
  role_arn = "${aws_iam_role.data-import-state-machine-iam-role.arn}"

  tags = {
    owner = "${var.owner}"
  }

  definition = "${data.template_file.import-data-definition.rendered}"
}

resource "aws_sfn_state_machine" "run-crawler-state-machine" {
  name     = "${var.owner}-nyc-taxi-crawler"
  role_arn = "${aws_iam_role.run-crawler-state-machine-iam-role.arn}"

  tags = {
    owner = "${var.owner}"
  }

  definition = "${data.template_file.run-crawler-definition.rendered}"
}

resource "aws_iam_role" "data-import-state-machine-iam-role" {
  name               = "${var.owner}-nyc-taxi-import-data-state-machine-role"
  assume_role_policy = "${data.template_file.state-machine-role-policy.rendered}"

  tags = {
    owner = "${var.owner}"
  }
}

resource "aws_iam_role" "run-crawler-state-machine-iam-role" {
  name               = "${var.owner}-nyc-taxi-run-crawler-state-machine-role"
  assume_role_policy = "${data.template_file.state-machine-role-policy.rendered}"

  tags = {
    owner = "${var.owner}"
  }
}

resource "aws_iam_role_policy" "run-crawler-lambda-execution-policy" {
  name   = "${var.owner}-nyc-taxi-data-lambda-invoke-policy"
  role   = "${aws_iam_role.run-crawler-state-machine-iam-role.id}"
  policy = "${data.template_file.lambda-invoke-policy.rendered}"
}

resource "aws_iam_role_policy" "import-data-lambda-execution-policy" {
  name   = "${var.owner}-nyc-taxi-data-lambda-invoke-policy"
  role   = "${aws_iam_role.data-import-state-machine-iam-role.id}"
  policy = "${data.template_file.lambda-invoke-policy.rendered}"
}

resource "aws_iam_role_policy_attachment" "iam-service-role" {
  role       = "${aws_iam_role.run-crawler-state-machine-iam-role.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}
