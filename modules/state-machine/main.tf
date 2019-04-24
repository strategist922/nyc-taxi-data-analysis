data "template_file" "definition" {
  template = "${file("modules/state-machine/definition.json")}"
  vars {
    lambda-iterator-arn = "${var.lambda-iterator-arn}"
    lambda-worker-arn = "${var.lambda-worker-arn}"
    lambda-s3-structure-builder-arn = "${var.lambda-s3-structure-builder-arn}"
  }
}

data "template_file" "state-machine-role-policy" {
  template = "${file("modules/state-machine/state-machine-role-policy.json")}"
}

data "template_file" "lambda-invoke-policy" {
  template = "${file("modules/state-machine/lambda-invoke-policy.json")}"
}

resource "aws_sfn_state_machine" "state-machine" {
  name = "${var.owner}-nyc-taxi-data-state-machine"
  role_arn = "${aws_iam_role.state-machine-iam-role.arn}"
  tags = {
    owner = "${var.owner}"
  }
  definition = "${data.template_file.definition.rendered}"
}

resource "aws_iam_role" "state-machine-iam-role" {
  name = "${var.owner}-nyc-taxi-data-state-machine-role"
  assume_role_policy = "${data.template_file.state-machine-role-policy.rendered}"
  tags = {
    owner = "${var.owner}"
  }
}

resource "aws_iam_role_policy" "lambda-execution" {
  name = "${var.owner}-nyc-taxi-data-lambda-invoke-policy"
  role = "${aws_iam_role.state-machine-iam-role.id}"
  policy = "${data.template_file.lambda-invoke-policy.rendered}"
}
