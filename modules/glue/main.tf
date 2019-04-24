module "crawler" {
  source = "crawler"
  owner = "${var.owner}"
}

module "job" {
  source = "job"
  owner = "${var.owner}"
}