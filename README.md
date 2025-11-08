# 🚀 Terraform + AWS EC2 + GLPI (Free Tier)

Proyecto educativo para practicar infraestructura como código con **Terraform** en **AWS Free Tier**, creando una instancia **EC2 t2.micro** con **Amazon Linux 2023** y desplegando **GLPI** automáticamente mediante **Docker Compose**.

---

## 🧰 Requisitos previos

1. **Instalar Terraform**
    - [Descarga Terraform](https://developer.hashicorp.com/terraform/downloads)
    - Verifica:
      ```bash
      terraform -version
      ```

2. **Instalar AWS CLI**
    - [Descarga AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
    - Verifica:
      ```bash
      aws --version
      ```

3. **Configurar credenciales AWS**
   ```bash
   aws configure
AWS Access Key ID: <tu_access_key>
AWS Secret Access Key: <tu_secret_key>
Default region name: us-east-1
Default output format: json

4. Verificar conexión
aws sts get-caller-identity

5. (Opcional) Ver los outputs nuevamente
terraform output

6. Destruir la infraestructura (cuando termines)
terraform destroy