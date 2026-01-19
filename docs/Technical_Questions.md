Q1 • K8s Networking
From pod-A you see.
● http://www.demo.domain.tv/ → Failure
● http://backend.demo.domain.tv/api/v1/health → Failure
● http://backend-domdomain-demo.backend.svc.cluster.local:4000/api/
v1/health → Success
● http://frontend-domdomain-demo.frontend.svc.cluster.local:3000/ →
Success
Why does this happen? Constraint. not DNS-related.

Answer: 

The problem may be related to either the fact that the load balancer (ingress) is unavailable for requests from the pod (probably network filtering), or a problem with the load balancer (ingress) itself (probably an incorrectly configured target group).



Q2 • Overlapping Networks
What are overlapping networks, and the most cost-effective way to remove them in a
multi-VPC?

Answer:

Overlapping networks are VPCs or subnets with intersecting IP ranges, which break connectivity when using VPC Peering, Transit Gateway, or VPN, because routers cannot distinguish the identical IPs.

Most cost-effective solution:
- Plan correct, non-overlapping CIDR blocks from the start.
- If possible, recreate overlapping VPCs with new CIDRs and migrate resources. This avoids expensive workarounds.

Temporary or alternative solutions:
- Use NAT or IP translation via Transit Gateway or NAT Gateway to “mask” overlapping IPs.
- This avoids migrating resources but incurs ongoing costs.
- Also, a very extreme option is point-to-point routing to hosts if the IP addresses of the hosts do not intersect.

Bottom line: Fixing the CIDR plan is cheaper in the long run; NAT/translation is a temporary or stopgap solution when migration is too costly or disruptive.


Q3 • Rollback • Production K8s
Design a rollback strategy for production Kubernetes. how to balance speed, reliability, and data
consistency.

Answer:

Key Principles
- Speed: Rollback should be fast to minimize downtime. Use Kubernetes Deployment rollback or tools like Argo Rollouts / Helm / Flux for automation.
- Reliability: Ensure new/old pods are healthy before traffic switch. Use readiness/liveness probes and health checks.
- Data consistency:
    - Avoid destructive DB migrations on production.
    - Use backward-compatible database schemas.
    - If schema rollback isn’t possible, rollback the app only, not data.

Rollback Approaches
A. Deployment rollback
kubectl rollout undo deployment/<deployment-name>
- Pros: fast, built-in.
- Cons: DB schema changes may cause incompatibility.
B. Blue-Green / Canary Deployments
- Blue-Green: Two environments (v1-blue, v2-green). Switch traffic instantly; rollback is immediate. Great for speed & reliability.
- Canary: Deploy new version to a small % of users, monitor, gradually increase traffic. Rollback affects only a portion of users → safer.
C. Helm rollback
helm rollback <release> <revision>
- Pros: handles complex dependencies.

Balancing Speed, Reliability, and Data
- Speed: Use Blue-Green deployments or Deployment rollback. This allows for an instant traffic switch, minimizing downtime.
- Reliability: Combine Canary deployments with health checks and readiness/liveness probes. This approach limits the impact if something goes wrong.
- Data consistency: Apply backward-compatible database migrations. This ensures that rolling back the application does not break existing data.

Best Practices
- Monitoring & Alerts: Prometheus/Grafana, SLO/SLA → immediate reaction.
- Smoke tests after rollback → confirm service health.
- API & data versioning → old clients still work.
- Backups for stateful services → snapshots if rollback affects DB.



Q4 • Logging Architecture
Why is sending logs directly from pods to the log server a bad idea. when does a log aggregator
help, and when can it be skipped.

Answer:

Why sending logs directly from Pods to a log server is a bad idea
- Network load
    If every Pod sends logs directly, traffic can spike, especially under high load.
    This can overload the log server and network.
- Reliability
    If a Pod crashes or restarts, logs can be lost without an intermediate buffer.
    Losing logs can make debugging very hard.
- Scalability
    In clusters with hundreds or thousands of Pods, direct connections to a single log server do not scale.
    The log server easily becomes a bottleneck.
- Format handling and filtering
    A log server would have to parse and filter many different log formats from different applications.
    Without a centralized aggregator, this is cumbersome.

When a log aggregator is helpful

A log aggregator (like Fluentd, Logstash) collects logs from Pods and:
- Buffers logs, preventing loss if a Pod crashes.
- Converts logs into a consistent format and filters unnecessary messages.
- Sends logs to centralized storage or cloud services (ELK, CloudWatch, Splunk).
- Scales independently of the number of Pods.

Use a log aggregator when:
- The cluster is medium or large (dozens+ of Pods).
- Centralized log analysis and search is needed.
- Logs need to be stored long-term or for auditing purposes.

When a log aggregator can be skipped
- Small cluster, few Pods, low log volume.
- Logs are needed only locally for debugging.
- Direct Pod → log server connection doesn’t overload network or server.


Q5 • Autoscaling Strategy
Why use Cluster Autoscaler if you have Karpenter. when is Karpenter not a good fit.

Answer:

Cluster Autoscaler works at the node group or Auto Scaling Group level. It scales entire groups of nodes and uses predefined instance types.

This provides:
- Predictable nodes
- A simple cost model
- Full compatibility with managed Kubernetes clusters

For this reason, Cluster Autoscaler is often chosen when:
- Maximum stability is required
- There are strict compliance requirements
- Managed node groups are used (EKS, AKS, GKE)

Karpenter provides flexibility and speed, but with trade-offs
Karpenter works directly with the cloud provider API and creates nodes based on actual pod requirements. It can dynamically choose instance type, size, availability zone, and capacity type.
Advantages:
- Faster reaction to load
- Better pod bin-packing
- Often lower cost through Spot instances and right-sizing
However:
- The logic is more complex
- Behavior is less deterministic
- Requires careful constraint configuration

When Karpenter is not a good fit
Karpenter is not well suited if:
- Strict compliance or security requirements
    A tightly controlled list of allowed instance types
    Formal approval for each configuration
- Complex networking or storage constraints
    Custom CNI
    Strong binding to specific nodes or availability zones
- Small clusters
    Node autoscaling provides little value
    Karpenter overhead outweighs benefits
- Limited team experience
    Misconfigured constraints can cause unexpected costs
    Harder to debug compared to Cluster Autoscaler

Q6 • Certificates for Private Services
How to get public TLS for internal-only services on private IPs like 10.0.27.99. give two
methods and trade-offs.

Answer:

Method 1: Public DNS name with DNS-01 challenge
How it works
1. Create a public DNS name, for example:
internal-api.example.com
2. The hostname does not need to resolve to a public IP.
3. Obtain a certificate using a DNS-01 challenge (Let’s Encrypt, etc.).
4. Add a TXT record:
_acme-challenge.internal-api.example.com
to the public DNS zone.
5. The service remains private, resolving internally to:
internal-api.example.com → 10.0.27.99

Pros
- Valid public TLS trusted by all clients
- Service remains fully private
- Works well for Kubernetes and internal APIs
- Easy to automate with cert-manager

Cons
- Requires control over a public DNS zone
- DNS-01 is more complex than HTTP-01
- DNS access must be well secured

Method 2: TLS termination via a public proxy or ingress
How it works
1. Deploy a public entry point:
    Load balancer (ALB/NLB)
    API Gateway
    Reverse proxy
2. Issue a public TLS certificate on the proxy.
3. Forward traffic to the internal service over private networking:
    Proxy (TLS) → internal service (HTTP or private TLS)
4. The internal service itself never becomes publicly accessible.

Pros
- Simpler operational model
- No DNS-01 challenge required
- Centralized certificate management
- Suitable for partner or B2B access

Cons
- Service is no longer strictly internal
- Additional network hop and latency
- Extra infrastructure cost
- Public endpoint must be secured
