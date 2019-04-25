resource "aws_cloudwatch_event_rule" "run-state-machine-rule" {
  name          = "${var.owner}-on-crawler-success"
  description   = "Run state machine rule"
  event_pattern = "${data.template_file.cloudwatch-event-pattern.rendered}"
}

data "template_file" "cloudwatch-event-pattern" {
  template = "${file("modules/cloudwatch/event-patterns/cloudwatch-event-pattern.json")}"

  vars {
    crawlerName = "${var.dataCrawlerName}"
  }
}

resource "aws_cloudwatch_event_target" "state-machine-target" {
  rule     = "${aws_cloudwatch_event_rule.run-state-machine-rule.name}"
  arn      = "${var.crawler-state-machine-arn}"
  role_arn = "${aws_iam_role.cloudwatch-state-machine-iam-role.arn}"
}

data "template_file" "cloudwatch-states-execute-policy" {
  template = "${file("modules/cloudwatch/cloudwatch-states-execute-policy.json")}"
}

data "template_file" "cloudwatch-role-policy" {
  template = "${file("modules/cloudwatch/role-policy.json")}"
}

resource "aws_iam_role" "cloudwatch-state-machine-iam-role" {
  name               = "${var.owner}-nyc-taxi-cloudwatch-state-machine-role"
  assume_role_policy = "${data.template_file.cloudwatch-role-policy.rendered}"

  tags = {
    owner = "${var.owner}"
  }
}

resource "aws_iam_role_policy" "cloudwatch-iam-role-policy" {
  name   = "${var.owner}-nyc-taxi-data-lambda-role-policy"
  role   = "${aws_iam_role.cloudwatch-state-machine-iam-role.id}"
  policy = "${data.template_file.cloudwatch-states-execute-policy.rendered}"
}
