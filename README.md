# Terraform + AWS EC2 + GLPI (Free Tier)

Professional-grade Infrastructure as Code project using **Terraform** to provision an **Amazon Linux 2023 EC2 instance** and automatically deploy **GLPI** through a **Docker Compose** setup.  
Fully compatible with the **AWS Free Tier**.

---

##  Prerequisites

1. **Install Terraform**
   - [Download Terraform](https://developer.hashicorp.com/terraform/downloads)
   - Verify installation:
     ```bash
     terraform -version
     ```

2. **Install AWS CLI**
   - [Download AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
   - Verify installation:
     ```bash
     aws --version
     ```

3. **Configure AWS credentials**
   ```bash
   aws configure
   AWS Access Key ID: <your_access_key>
   AWS Secret Access Key: <your_secret_key>
   Default region name: us-east-1
   Default output format: json
   ```
4. **Verify AWS connection**
   ```bash
   aws sts get-caller-identity
   ```
5. **Deployment**
   - Initialize and apply the Terraform configuration:
   ```bash
   terraform init
   terraform validate
   terraform plan -var-file="live/dev/main.tfvars"
   terraform apply -var-file="live/dev/main.tfvars"
   ```
6. **Cleanup (⚠️ WARNING)**  
   This command **destroys all AWS resources** created by this Terraform configuration — including the EC2 instance, IAM roles, security groups, and volumes.  
   Use it **only when you are certain you no longer need the environment**.
   ```bash
   terraform destroy -var-file="live/dev/main.tfvars"
   ```
## PROJECT STRUCTURE**
 ```bash
   terraform/
   ├─ main.tf           → Root orchestrator
   ├─ variables.tf      → Global variables
   ├─ locals.tf         → Naming and tagging conventions
   ├─ modules/          → Reusable modules (ec2, iam-ssm, sg-http)
   ├─ user_data/        → Initialization scripts (glpi.sh)
   └─ live/dev/         → Environment parameters (.tfvars)
    ```