resource "aws_glue_job" "convert-to-parquet-job" {
  name     = "${var.owner}-nyc-taxi-data-convert-to-parquet-job"
  role_arn = "${aws_iam_role.glue-iam-role.arn}"
  command {
    script_location = "s3://${aws_s3_bucket_object.s3-convert-to-parquet-script.bucket}/${aws_s3_bucket_object.s3-convert-to-parquet-script.key}"
  }
}

data "template_file" "s3-convert-to-parquet-script-template" {
  template = "${file("modules/glue/job/glue-scripts/convert-to-parquet.py")}"
  vars {
    bucketName = "${var.owner}-nyc-taxi"
  }
}

resource "aws_s3_bucket_object" "s3-convert-to-parquet-script" {
  bucket = "${var.owner}-nyc-taxi"
  key    = "glue-scripts/convert-to-parquet.py"
  content = "${data.template_file.s3-convert-to-parquet-script-template.rendered}"
  etag = "${filemd5("modules/glue/job/glue-scripts/convert-to-parquet.py")}"
}

data "template_file" "s3-access-policy" {
  template = "${file("modules/glue/crawler/s3-access-policy.json")}"
}

data "template_file" "role-policy" {
  template = "${file("modules/glue/crawler/role-policy.json")}"
}

resource "aws_iam_role_policy_attachment" "iam-service-role" {
  role = "${aws_iam_role.glue-iam-role.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy" "iam-s3-access-policy" {
  name = "${var.owner}-nyc-taxi-data-glue-job-s3-role-policy"
  role = "${aws_iam_role.glue-iam-role.id}"
  policy = "${data.template_file.s3-access-policy.rendered}"
}

resource "aws_iam_role" "glue-iam-role" {
  name = "${var.owner}-nyc-taxi-data-glue-job-role"
  assume_role_policy = "${data.template_file.role-policy.rendered}"
  tags = {
    owner = "${var.owner}"
  }
}