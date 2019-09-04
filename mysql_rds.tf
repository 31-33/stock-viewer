resource "aws_rds_cluster" "stock_rds_cluster" {
    cluster_identifier = "stock-viewer-tf"
    database_name = "stockviewer"
    deletion_protection = false
    skip_final_snapshot = true

    master_password = "${var.db_credentials["password"]}"
    master_username = "${var.db_credentials["username"]}"

    engine = "aurora"
    engine_mode = "serverless"
    engine_version = "5.6.10a"
    port = 3306

    scaling_configuration {
        auto_pause = false
        max_capacity = 64
        min_capacity = 1
        seconds_until_auto_pause = 300
    }

    provisioner "local-exec" {
        command = "aws rds modify-db-cluster --db-cluster-identifier ${aws_rds_cluster.stock_rds_cluster.cluster_identifier} --enable-http-endpoint"
    }
}

resource "aws_secretsmanager_secret" "db-secret" {
    name = "stock-rds-secret-tf"
    recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "db-secret-version" {
    depends_on = [
        "aws_secretsmanager_secret.db-secret"
    ]
    secret_id = "${aws_secretsmanager_secret.db-secret.id}"
    secret_string = "${jsonencode(var.db_credentials)}"
}

resource "aws_lambda_function" "rds-populate-lambda" {
    function_name   = "rds-populate"

    s3_bucket       = "${aws_s3_bucket.lambda_bucket.id}"
    s3_key          = "${aws_s3_bucket_object.lambda-rds-code.key}"

    handler         = "rdsData.lambda_handler"
    runtime         = "python3.6"

    timeout = 330
    memory_size = 1536

    environment {
        variables = {
            rds_cluster_arn = "${aws_rds_cluster.stock_rds_cluster.arn}",
            rds_secret_arn = "${aws_secretsmanager_secret.db-secret.arn}",
            database = "${aws_rds_cluster.stock_rds_cluster.database_name}"
        }
    }

    role = "${aws_iam_role.lambda_role.arn}"
}


resource "aws_lambda_function" "rds-update-lambda" {
    function_name   = "rds-update-data-daily"

    s3_bucket       = "${aws_s3_bucket.lambda_bucket.id}"
    s3_key          = "${aws_s3_bucket_object.lambda-rds-code.key}"

    handler         = "rdsData-daily.lambda_handler"
    runtime         = "python3.6"

    timeout = 330
    memory_size = 960

    environment {
        variables = {
            rds_cluster_arn = "${aws_rds_cluster.stock_rds_cluster.arn}",
            rds_secret_arn = "${aws_secretsmanager_secret.db-secret.arn}",
            database = "${aws_rds_cluster.stock_rds_cluster.database_name}"
        }
    }

    role = "${aws_iam_role.lambda_role.arn}"
}

resource "aws_lambda_permission" "rds-update" {
    statement_id    = "AllowCloudWatchInvoke"
    action          = "lambda:InvokeFunction"
    function_name   = "${aws_lambda_function.rds-update-lambda.arn}"
    principal       = "events.amazonaws.com"

    source_arn      = "${aws_cloudwatch_event_rule.rds-update-rule.arn}"
}


# data "aws_lambda_invocation" "load-data" {
#     depends_on = [
#         "aws_lambda_function.rds-populate-lambda",
#         "aws_rds_cluster.stock_rds_cluster"
#     ]

#     function_name = "${aws_lambda_function.rds-populate-lambda.function_name}"
#     input = <<JSON
# {
#     "key1": "value1",
#     "key2": "value2"
# }
# JSON
# }


