# 1. One-pager comparing ALB vs API Gateway vs CloudFront-only for this small service.

For small service with Docker container and one /healthz endpoint:

## ALB (Application Load Balancer)
- Good for container service behind ECS or EC2.
- Supports HTTP/HTTPS and WebSocket.
- Auto scales with targets.
- Low latency, easy to use with AWS WAF for security.
- Little caching, for static assets better use CloudFront.
- Cost: pay per hour for ALB and LCU units.

## API Gateway
- Good for serverless APIs with request limits, authorization, throttling.
- Fully managed, scales automatically.
- Latency little higher because API Gateway process requests.
- Can use WAF and stage cache, but too much for small service.
- Cost: pay per million requests and data transfer.

## CloudFront-only
- Best for static files (CSS, JS, images).
- Caches on edge, reduce load on origin.
- For /healthz endpoint need origin like ALB or S3.
- Very low latency for cached content.
- Cost: pay for data transfer and requests, no compute cost.

### Summary:
For small container service with one health endpoint, ALB is simplest and works well. Use CloudFront for static assets. API Gateway is too much for this case.

---

# 2. Default autoscaling policy and caching strategy for static assets.

There are no autoscaling settings for this application, but you can configure an autoscaling group based on changes in metrics (CPU, for example)

Caching Strategy for Static Assets - CloudFront distribution in front of S3 bucket (or ALB origin):
- Default TTL: 24h for CSS/JS/images.
- Cache static content aggressively (immutable versions with hash in filenames).
- Dynamic API (/healthz) set Cache-Control: no-cache.

Example headers for static assets:
Cache-Control: public, max-age=86400, immutable

---

# 3. Daily budget guardrail with alert thresholds and a simple pipeline toggle to pause prod deploys.

- Budget alert via AWS Budget / CloudWatch:
    - Daily cost threshold: $5/day (example)
    - Alert triggers SNS notification or Lambda function.
- Pipeline toggle for prod deploys:
    - Add a flag in pipeline (e.g., PROD_DEPLOY_ENABLED=true/false)
    - Pipeline step before deploy:
       if [ "$PROD_DEPLOY_ENABLED" != "true" ]; then
         echo "Prod deploy paused due to budget guardrail"
         exit 0
       fi
- Optional: Integrate Lambda that disables CodePipeline execution automatically if daily cost > threshold.

