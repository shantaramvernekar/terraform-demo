# Terraform Demo: AWS S3 Bucket

This repository provides a commented Terraform example that creates a secure Amazon S3 bucket while demonstrating core concepts you should know for a senior DevOps interview: backends, state management, workspaces, modules, scaling patterns, performance, and operational hygiene.

## Repository layout

- `main.tf` – root module showing provider configuration, remote backend, workspaces, and how to call a reusable module.
- `variables.tf` – input variables with sensible defaults and documentation.
- `modules/s3_bucket` – module that creates an S3 bucket with versioning, encryption, lifecycle rules, and optional access logging.

## Getting started

1. Install Terraform >= 1.5 and configure AWS credentials (for example via `~/.aws/credentials`).
2. Replace the placeholder backend values in `main.tf` with your S3 bucket and DynamoDB table for state and locking.
3. Initialize Terraform:
   ```bash
   terraform init
   ```
4. (Optional) Create an isolated workspace per environment:
   ```bash
   terraform workspace new dev
   terraform workspace select dev
   ```
5. Review the plan, then apply:
   ```bash
   terraform plan -out plan.tfplan
   terraform apply plan.tfplan
   ```

## Key Terraform concepts to review

### State management and backends
- **Remote backend**: The `s3` backend keeps state in an S3 bucket, enabling collaboration and recovery. The optional DynamoDB table adds **state locking** to prevent concurrent writes.
- **Workspace-aware keys**: For multi-environment setups, append `${terraform.workspace}` to the backend `key` (e.g., `key = "s3-demo/${terraform.workspace}/terraform.tfstate"`).
- **Security**: `encrypt = true` ensures the state file is encrypted at rest; use bucket policies/IAM to restrict access.

### Workspaces and environment isolation
- Workspaces let you reuse the same configuration for `dev`, `qa`, or `prod` by changing the active workspace.
- The root module appends the workspace suffix to `base_bucket_name`, avoiding bucket name collisions across environments.

### Modules and composition
- The S3 bucket logic lives in `modules/s3_bucket`, keeping the root module lightweight and reusable.
- Inputs such as `enable_access_logging` and `enable_lifecycle_rules` let you toggle features without editing code—useful for **scaling configuration** across teams.

### Scaling and performance considerations
- **Parallelism**: Use `terraform apply -parallelism=N` to tune API concurrency when creating many resources.
- **Plan files**: Save a plan (`terraform plan -out`) to shorten applies and provide an auditable artifact.
- **Module versioning**: When modules live in separate repos or registries, pin versions to avoid drift and support safe rollouts.
- **Drift detection**: Regularly run `terraform plan` (ideally via CI) to detect configuration drift early.

### Backups and disaster recovery
- Enable S3 versioning (already configured) so state buckets and data buckets can recover deleted/changed objects.
- Export state using `terraform state pull` for incident response, and consider periodic state backups.

### Testing and policy guardrails
- Use `terraform validate` and `terraform fmt` for static checks.
- Add **policy as code** (Sentinel/Open Policy Agent) to enforce tagging, encryption, and networking rules before apply.

### Collaboration tips
- Keep **variables** and **locals** descriptive to make intent clear.
- Use **tags** for ownership, cost allocation, and compliance. The example merges shared tags with per-environment values.
- Document workspace, backend, and input expectations so teammates can reproduce your setup.

## Clean-up

To avoid charges, remove the resources when you are finished:
```bash
terraform destroy
```

## Next steps for deeper learning
- Add more modules (VPC, IAM roles, EKS, RDS) and wire them together to practice dependency management.
- Experiment with **data sources** to pull existing infrastructure details into your plans.
- Integrate Terraform with CI/CD to practice remote plans, approvals, and cost estimation.
