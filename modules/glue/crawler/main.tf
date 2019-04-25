# Edit s3 bucket source to crawl
resource "aws_glue_crawler" "source-data-crawler" {
  database_name = "${aws_glue_catalog_database.source-data-database.name}"
  name          = "${var.owner}-nyc-taxi-data-crawler"
  role          = "${aws_iam_role.glue-iam-role.arn}"

  s3_target {
    path = "s3://${var.owner}-nyc-taxi/data/yellow"
  }
}

resource "aws_glue_crawler" "parquet-data-crawler" {
  database_name = "${aws_glue_catalog_database.parquet-data-database.name}"
  name          = "${var.owner}-nyc-taxi-parquet-crawler"
  role          = "${aws_iam_role.glue-iam-role.arn}"

  s3_target {
    path = "s3://${var.owner}-nyc-taxi/parquet-data/yellow"
  }
}

data "template_file" "s3-access-policy" {
  template = "${file("modules/glue/crawler/s3-access-policy.json")}"
}

resource "aws_glue_catalog_database" "source-data-database" {
  name = "${var.owner}-nyc-taxi-data-database"
}

resource "aws_glue_catalog_database" "parquet-data-database" {
  name = "${var.owner}-nyc-taxi-parquet-database"
}

data "template_file" "role-policy" {
  template = "${file("modules/glue/crawler/role-policy.json")}"
}

resource "aws_iam_role" "glue-iam-role" {
  name               = "${var.owner}-nyc-taxi-data-glue-role"
  assume_role_policy = "${data.template_file.role-policy.rendered}"

  tags = {
    owner = "${var.owner}"
  }
}

resource "aws_iam_role_policy_attachment" "iam-service-role" {
  role       = "${aws_iam_role.glue-iam-role.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy" "iam-s3-access-policy" {
  name   = "${var.owner}-nyc-taxi-data-glue-s3-role-policy"
  role   = "${aws_iam_role.glue-iam-role.id}"
  policy = "${data.template_file.s3-access-policy.rendered}"
}
