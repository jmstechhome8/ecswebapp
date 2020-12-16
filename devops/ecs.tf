resource "aws_ecs_cluster" "main" {
  name = "jms-cluster"
}

data "template_file" "cb_app" {
  template = file("./templates/ecs/cb_app.json.tpl")

  vars = {
    app_image      = var.app_image
    app_port       = var.app_port
    cpu    = var.cpu
    memory = var.memory
    aws_region     = var.aws_region
    tag            = var.tag
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "jms-app-task"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = var.cpu
  memory                   = var.memory
  container_definitions    = data.template_file.cb_app.rendered
}

resource "aws_ecs_service" "main" {
  name            = "jms-service1"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.app_count
  launch_type     = "EC2"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.private.*.id
  
  }

 

  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_role]
}
