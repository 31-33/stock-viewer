
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "Lambda-dashboard"

  dashboard_body = <<EOF
{
    "widgets": [
        {
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 6,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/Lambda", "Invocations", "FunctionName", "stockdata" ],
                    [ "...", "stocklist" ],
                    [ "...", "subscribe" ],
                    [ "...", "subscriptions" ]
                ],
                "region": "us-east-1"
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 0,
            "width": 6,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/Lambda", "Throttles", "FunctionName", "stockdata" ],
                    [ "...", "stocklist" ],
                    [ "...", "subscriptions" ],
                    [ "...", "subscribe" ]
                ],
                "region": "us-east-1"
            }
        },
        {
            "type": "metric",
            "x": 12,
            "y": 0,
            "width": 6,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/Lambda", "Errors", "FunctionName", "stockdata" ],
                    [ "...", "stocklist" ],
                    [ "...", "subscribe" ],
                    [ "...", "subscriptions" ]
                ],
                "region": "us-east-1"
            }
        },
        {
            "type": "metric",
            "x": 18,
            "y": 0,
            "width": 6,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/Lambda", "Duration", "FunctionName", "stockdata" ],
                    [ "...", "stocklist" ],
                    [ "...", "subscribe" ],
                    [ "...", "subscriptions" ]
                ],
                "region": "us-east-1"
            }
        }
    ]
}
 EOF
}


