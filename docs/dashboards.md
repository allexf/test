SLO №1 — Availability 99.9% (monthly)
aws cloudwatch create-service-level-objective \
  --region $REGION \
  --name "api-availability-99-9" \
  --description "Monthly availability 99.9% for API via ALB" \
  --sli '{
    "comparisonOperator": "GreaterThan",
    "metricThreshold": 0,
    "metricDataQueries": [
      {
        "id": "errors",
        "metricStat": {
          "metric": {
            "namespace": "AWS/ApplicationELB",
            "metricName": "HTTPCode_Target_5XX_Count",
            "dimensions": {
              "LoadBalancer": "'$ALB_NAME'"
            }
          },
          "period": 60,
          "stat": "Sum"
        }
      }
    ]
  }' \
  --goal '{
    "attainmentGoal": 99.9,
    "interval": {
      "type": "MONTHLY"
    }
  }'

SLO №2 — P95 latency ≤ 300 ms  /healthz
aws cloudwatch create-service-level-objective \
  --region $REGION \
  --name "healthz-latency-p95-300ms" \
  --description "P95 latency <= 300ms via ALB" \
  --sli '{
    "comparisonOperator": "LessThan",
    "metricThreshold": 0.3,
    "metricDataQueries": [
      {
        "id": "latency",
        "metricStat": {
          "metric": {
            "namespace": "AWS/ApplicationELB",
            "metricName": "TargetResponseTime",
            "dimensions": {
              "LoadBalancer": "'$ALB_NAME'"
            }
          },
          "period": 60,
          "stat": "p95"
        }
      }
    ]
  }' \
  --goal '{
    "attainmentGoal": 99.0,
    "interval": {
      "type": "MONTHLY"
    }
  }'

Alert: SLO burn rate (CloudWatch native)
aws cloudwatch put-metric-alarm \
  --region $REGION \
  --alarm-name "slo-burnrate-critical" \
  --metric-name BurnRate \
  --namespace AWS/CloudWatchSLO \
  --statistic Average \
  --period 300 \
  --threshold 2 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 1 \
  --alarm-actions arn:aws:sns:eu-north-1:ACCOUNT_ID:ALERT_TOPIC

Alert: 5-minute error rate > 2%
aws cloudwatch put-metric-alarm \
  --region $REGION \
  --alarm-name "alb-error-rate-gt-2pct" \
  --comparison-operator GreaterThanThreshold \
  --threshold 0.02 \
  --evaluation-periods 1 \
  --metrics '[
    {
      "Id": "errors",
      "MetricStat": {
        "Metric": {
          "Namespace": "AWS/ApplicationELB",
          "MetricName": "HTTPCode_Target_5XX_Count",
          "Dimensions": [
            { "Name": "LoadBalancer", "Value": "'$ALB_NAME'" }
          ]
        },
        "Period": 300,
        "Stat": "Sum"
      },
      "ReturnData": false
    },
    {
      "Id": "requests",
      "MetricStat": {
        "Metric": {
          "Namespace": "AWS/ApplicationELB",
          "MetricName": "RequestCount",
          "Dimensions": [
            { "Name": "LoadBalancer", "Value": "'$ALB_NAME'" }
          ]
        },
        "Period": 300,
        "Stat": "Sum"
      },
      "ReturnData": false
    },
    {
      "Id": "error_rate",
      "Expression": "errors / requests",
      "Label": "ErrorRate",
      "ReturnData": true
    }
  ]' \
  --alarm-actions arn:aws:sns:eu-north-1:ACCOUNT_ID:ALERT_TOPIC

Alert: Daily cost threshold
aws budgets create-budget \
  --account-id ACCOUNT_ID \
  --budget '{
    "BudgetName": "daily-cost-alert",
    "BudgetLimit": {
      "Amount": "20",
      "Unit": "USD"
    },
    "TimeUnit": "DAILY",
    "BudgetType": "COST"
  }' \
  --notifications-with-subscribers '[
    {
      "Notification": {
        "NotificationType": "ACTUAL",
        "ComparisonOperator": "GREATER_THAN",
        "Threshold": 100
      },
      "Subscribers": [
        {
          "SubscriptionType": "SNS",
          "Address": "arn:aws:sns:eu-north-1:ACCOUNT_ID:ALERT_TOPIC"
        }
      ]
    }
  ]'

