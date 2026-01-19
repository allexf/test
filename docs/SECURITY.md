# 1. IAM least privilege. GitHub OIDC to AWS.

IAM least privilege - must be configured with the minimum necessary privileges, mandatory two-factor authentication and password policies (minimum password complexity, regular password changes, prohibition of multiple versions of previous passwords)

GitHub OIDC to AWS - configured via Terraform

---

# 2. Secrets in AWS Secrets Manager or Azure Key Vault.

All secrets should be stored in Secrets in AWS Secrets Manager or Azure Key Vault, or Hashicorp Vault on-premises (as an alternative to cloud technologies). Passwords are obtained when running applications in environments or during build (secrets required for the build) and are not stored in built application images or source code.

---

# 3. Image scan in CI with Trivy or equivalent.

Built images must undergo a check for known vulnerabilities. This can be implemented as a separate blocking step after image build (for example, Trivy) or using the built-in AWS ECR tool.

---

# 4. HTTPS everywhere. redirect 80 → 443. secure headers at CDN or load balancer.

For AWS, it's easiest to issue a TLS certificate for free through the AWS certificate manager. Auto-renewal is also configured there; it's best to use DNS domain ownership verification. TLS termination can be configured on the load balancer, along with an additional rule for port forwarding from port 80 to 443.

