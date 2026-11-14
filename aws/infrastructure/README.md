\# infrastructure/



Provisioning is currently CLI-based — see `../deployment/deploy.sh`.



\## Manual console steps the script doesn't cover



1\. ALB + target group (target type `ip`, port 8000, health check `/health`)

2\. Security groups: ALB → 443 from internet; ECS tasks → 8000 from ALB only;

&#x20;  RDS → 5432 from ECS tasks only

3\. ACM certificate for HTTPS on the ALB

4\. EventBridge Scheduler rule → run the training task nightly



\## Planned Terraform layout (see README roadmap)



terraform/

├── modules/    # network, s3, rds, ecs, iam

└── envs/       # dev, prod — same modules, different sizing



Replace ACCOUNT\_ID / REGION / bucket placeholders in `../iam/\*.json` and

`../deployment/task-definition.json` before applying.

