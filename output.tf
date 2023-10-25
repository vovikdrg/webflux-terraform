output "webflux_cluster_dns" {
    description = "Webflux cluster url."
    value = "http://${module.ecs_task.dns}/test"
}

output "blocking_cluster_dns" {
    description = "Blocking url."
    value = "http://${module.ecs_task_blocking.dns}/test"
}

output "lambda_url" {
    description = "Lambda url."
    value = "${module.lambda.base_url}/delay"
}