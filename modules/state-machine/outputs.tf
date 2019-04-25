output "state-machine-id" {
  value = "${aws_sfn_state_machine.import-data-state-machine.id}"
}

output "crawler-state-machine-arn" {
  value = "${aws_sfn_state_machine.run-crawler-state-machine.id}"
}
