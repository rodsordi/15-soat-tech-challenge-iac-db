# 🐘 IaC Database & Observability (`15-soat-tech-challenge-iac-db`)

Este repositório é dedicado ao provisionamento isolado do banco de dados relacional **AWS RDS PostgreSQL** e da stack completa de **Observabilidade**.

---

## 🛠️ Módulos do Terraform (`modules/`)

| Módulo | Descrição |
| :--- | :--- |
| **`modules/rds`** | Instância gerenciada AWS RDS PostgreSQL (`db.t3.micro`), Security Group com liberação para a VPC do EKS (`10.0.0.0/16`), gerador aleatório de senhas e integração com o **AWS Secrets Manager** (`garage-db-credentials`). |
| **`modules/observability`** | Stack de telemetria completa (Prometheus, Grafana, Jaeger, Loki e Kube-State-Metrics). |

---

## ⚙️ Execução Local do Terraform

```bash
terraform init
terraform plan -var-file="terraform.tfvars.example"
terraform apply -auto-approve
```

---

## 🤖 Automação via GitHub Actions

Pipeline automatizada configurada em `.github/workflows/terraform.yml`. Secrets necessárias:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_SESSION_TOKEN`
- `AWS_REGION`
