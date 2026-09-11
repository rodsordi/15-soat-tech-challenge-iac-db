# 🐘 Banco de Dados RDS PostgreSQL (`15-soat-tech-challenge-iac-db`)

Repositório de **Infraestrutura como Código (IaC)** responsável pelo provisionamento e governança do banco de dados relacional gerenciado **AWS RDS PostgreSQL** (com gerenciamento e rotação de segredos via **AWS Secrets Manager**), integrado diretamente à VPC privada do cluster Kubernetes **AWS EKS**.

---

## 🎯 1. Descrição do Propósito

Este repositório atende ao pilar fundamental de persistência de dados de negócio da solução:
* **Persistência de Dados Confiável e Segura**: Criação de instância de banco de dados PostgreSQL na versão estável **15.13** totalmente isolada nas subnets privadas da VPC do EKS, com credenciais rotativas gerenciadas pelo AWS Secrets Manager e liberação de porta exclusiva (5432) para a rede interna.
* **Observabilidade Centralizada**: A telemetria, monitoramento de infraestrutura, logs e traces distribuídos são centralizados via **New Relic One** (implantado pelo repositório [`15-soat-tech-challenge-iac-k8s`](https://github.com/rodsordi/15-soat-tech-challenge-iac-k8s) através do New Relic Kubernetes Bundle com OpenTelemetry).

---

## 💻 2. Tecnologias Utilizadas

* **Infraestrutura como Código**: Terraform 1.6+ (com HCL e descoberta dinâmica via Data Sources).
* **Banco de Dados Gerenciado**: Amazon Relational Database Service (AWS RDS PostgreSQL 15.13, classe `db.t3.micro`, armazenamento 20 GB `gp2`).
* **Gerenciamento de Segredos**: AWS Secrets Manager (`garage-db-credentials`).
* **Rede & Segurança do Banco**: AWS DB Subnet Group privado e Security Groups restritos ao CIDR da VPC (`10.0.0.0/16`).
* **Observabilidade & Telemetria**: New Relic One (APM, OTLP Traces, K8s Metrics & Logging).

---

## 🏛️ 3. Diagrama da Arquitetura do Repositório

```mermaid
graph TD
    subgraph EKSVPC [AWS VPC do Cluster 10.0.0.0/16]
        subgraph PrivateSubnets [Subnets Privadas de Dados]
            DBSubnetGroup[AWS DB Subnet Group]
            RDS[(AWS RDS PostgreSQL 15.13<br/>garage-postgres-db)]
            SecretsManager[AWS Secrets Manager:<br/>garage-db-credentials]
            
            DBSubnetGroup --> RDS
            SecretsManager -.->|Gera e armazena credenciais| RDS
        end

        subgraph EKSWorkloads [Cluster EKS - Namespace: garage]
            App[api-garage Pods]
            
            App -->|Porta 5432 JDBC / Flyway Migrations| RDS
        end
    end

    subgraph ObservabilidadeSaaS [Plataforma de Observabilidade Centralizada]
        NewRelic[(New Relic One SaaS<br/>APM, Traces OTLP, Logs & K8s Events)]
        App -.->|OTLP Telemetry /v1/metrics & /v1/traces| NewRelic
    end
```

---

## ⚙️ 4. Passos para Execução e Deploy

> [!CAUTION]
> **DIRETRIZ MANDATÓRIA DE DEVSECOPS: NUNCA MAPEAR DADOS SENSÍVEIS NO CÓDIGO FONTE**
> É **estritamente proibido** comitar senhas mestras de banco de dados (`db_password`), tokens ou credenciais da AWS em arquivos `.tf`, `.tfvars`, `.yaml` ou scripts.
> Todas as credenciais de banco de dados e chaves da AWS **devem ser configuradas exclusivamente nos Segredos da Pipeline (GitHub Actions Secrets)** e no **AWS Secrets Manager**, sendo injetadas de forma dinâmica e segura.

### 4.1. Pré-Requisito Obrigatório
> [!IMPORTANT]
> O **Passo 1 (`15-soat-tech-challenge-iac-k8s`)** deve estar aplicado. Este repositório descobre automaticamente a VPC `techchallenge-cluster-vpc` e o cluster Kubernetes em execução.


### 4.2. Comandos do Terraform
Com as credenciais ativas do AWS Learner Lab no terminal:

```bash
# 1. Inicializar providers
terraform init

# 2. Validar sintaxe
terraform validate

# 3. Planejar as alterações
terraform plan

# 4. Provisionar na AWS (leva cerca de 4 a 6 minutos para criação do RDS)
terraform apply -auto-approve
```

---

## 📑 5. Link para o Swagger e Postman das APIs

As APIs que consomem este banco de dados estão mapeadas e documentadas no **AWS API Gateway**:

### 🌐 Endpoints de Documentação e Saúde:
* **Swagger UI (Consumo das APIs com persistência no RDS)**:
  ```
  https://6t8e18w3f8.execute-api.us-east-1.amazonaws.com/api/swagger-ui/index.html
  ```
* **OpenAPI 3 JSON Spec**:
  ```
  https://6t8e18w3f8.execute-api.us-east-1.amazonaws.com/api/v3/api-docs
  ```

### 📬 Exemplo de Requisição (Verificação de Conexão com o Banco de Dados):

```bash
curl --location 'https://6t8e18w3f8.execute-api.us-east-1.amazonaws.com/api/actuator/health'
```

**Resposta confirmando conexão com o RDS PostgreSQL**:
```json
{
  "status": "UP",
  "components": {
    "db": {
      "status": "UP",
      "details": {
        "database": "PostgreSQL",
        "validationQuery": "isValid()"
      }
    }
  }
}
```
