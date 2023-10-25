module "lambda" {
  source = "./lambda"
}



module "ecs_task"{
  depends_on = [ module.lambda]
  source = "./ecs_task"
  docker_image = "732757519306.dkr.ecr.ap-southeast-2.amazonaws.com/webflux:latest"
  task_name = "webflux"
  scale_up_cpu = 75
  scale_down_cpu = 25
  lambda_url = "${module.lambda.base_url}/delay"
}

module "ecs_task_blocking"{
  depends_on = [ module.lambda]
  source = "./ecs_task"
  docker_image = "732757519306.dkr.ecr.ap-southeast-2.amazonaws.com/blocking:latest"
  task_name = "blocking"
  scale_up_cpu = 35
  scale_down_cpu = 10
    lambda_url = "${module.lambda.base_url}/delay"
}