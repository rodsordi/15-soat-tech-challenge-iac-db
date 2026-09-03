# 🐘 Passo 2: Banco de Dados RDS & Observabilidade (`15-soat-tech-challenge-iac-db`)

Este repositório é o **segundo passo** do provisionamento da infraestrutura na AWS. Ele provisiona o banco de dados relacional **AWS RDS PostgreSQL** integrado à VPC privada do EKS e implanta a stack de **Observabilidade** (Prometheus, Grafana, Loki e Jaeger) dentro do cluster.

---

## 📌 Pré-Requisito Obrigatório

> [!IMPORTANT]
> O **Passo 1 (`15-soat-tech-challenge-iac-k8s`)** DEVE ter sido concluído com sucesso antes de rodar este projeto!
> 
> Este repositório utiliza **Data Sources** do Terraform para descobrir automaticamente:
> - A VPC do EKS (`techchallenge-cluster-vpc`)
> - As subnets privadas com tag `kubernetes.io/role/internal-elb = 1`
> - O cluster EKS para autenticação do provider Kubernetes

---

## 🏛️ Arquitetura do Banco e Telemetria

```
                                 ┌───────────────────────────────────┐
                                 │   AWS RDS PostgreSQL (15.13)      │
                                 │   - Subnet Group Privado          │
                                 │   - Security Group (Porta 5432)   │
                                 │   - AWS Secrets Manager           │
                                 └──────────────▲────────────────────┘
                                                │ (Conexão Privada na VPC)
 ┌──────────────────────────────────────────────┴─────────────────────────────────┐
 │                            Cluster AWS EKS                                     │
 │                                                                                │
 │  ┌──────────────────────┐  ┌──────────────────────┐  ┌──────────────────────┐  │
 │  │ Keycloak (Auth Pod)  │  │ api-garage (App Pod) │  │ Prometheus (Métricas)│  │
 │  └──────────────────────┘  └──────────────────────┘  └──────────────────────┘  │
 │  ┌──────────────────────┐  ┌──────────────────────┐  ┌──────────────────────┐  │
 │  │ Grafana (Dashboards) │  │ Loki (Logs)          │  │ Jaeger (Tracing)     │  │
 │  └──────────────────────┘  └──────────────────────┘  └──────────────────────┘  │
 └────────────────────────────────────────────────────────────────────────────────┘
```

---

## ⚙️ Execução Passo a Passo do Terraform

Certifique-se de estar com as credenciais da sessão ativa no seu terminal (mesmas credenciais do Passo 1).

Dentro da pasta `15-soat-tech-challenge-iac-db`:

```bash
# 1. Inicializar os módulos e providers
terraform init

# 2. Validar a sintaxe
terraform validate

# 3. Visualizar o plano de execução
terraform plan

# 4. Aplicar e provisionar na AWS
terraform apply -auto-approve
```

> [!NOTE]
> A criação da instância do RDS PostgreSQL na AWS leva em média de **4 a 6 minutos**.

---

## 📊 Módulos e Recursos Provisionados

| Módulo | Recursos Criados |
| :--- | :--- |
| **`modules/rds`** | Instância **AWS RDS PostgreSQL** (versão suportada `15.13`, classe `db.t3.micro`, 20 GB `gp2`), DB Subnet Group vinculado às subnets privadas do EKS, Security Group liberando tráfego interno na porta 5432 e credenciais criptografadas no **AWS Secrets Manager** (`garage-db-credentials`). |
| **`modules/observability`** | Stack completa no Kubernetes: **Kube State Metrics**, **Loki** (logs centralizados), **Jaeger** (Distributed Tracing OTLP), **Prometheus** (raspagem de métricas de pods e nós) e **Grafana** com 4 dashboards pré-provisionados. |

---

## 🔍 Como Acessar a Observabilidade (Grafana & Prometheus)

Os serviços de observabilidade são expostos no cluster Kubernetes via `NodePort`:

| Serviço | Porta NodePort | Comando para Acesso Local (Port-Forward) |
| :--- | :---: | :--- |
| **Grafana** | `30300` | `kubectl -n garage port-forward svc/grafana 3000:3000` |
| **Prometheus** | `30909` | `kubectl -n garage port-forward svc/prometheus 9090:9090` |
| **Jaeger UI** | `31686` | `kubectl -n garage port-forward svc/jaeger 16686:16686` |
| **Loki** | `30310` | `kubectl -n garage port-forward svc/loki 3100:3100` |

* **Acesso ao Grafana no Navegador**: Acesse `http://localhost:3000` (Login anônimo de administrador já ativado).
* **Dashboards Disponíveis**:
  * Métricas de Aplicação e CPU/Memória
  * HPA Auto Scaling
  * Logs agregados via Loki
  * Traces distribuídos via Jaeger

---

## 🎯 O que esperar após o Passo 2:

Assim que o RDS PostgreSQL estiver com status `Available`:
1. O pod do **Keycloak** (`kubectl -n garage get pods -l app=keycloak`) conseguirá conectar no banco de dados e passará para o status **`Running` (1/1)**.
2. A base de dados estará pronta para receber o tráfego da API e da Lambda.

---

## ⚠️ Cuidados com o AWS Learner Lab

> [!WARNING]
> - Quando a sessão do Learner Lab expira (timer 0:00), a AWS **NÃO desliga instâncias RDS**. Elas continuarão consumindo créditos do seu saldo de US$ 50/100.
> - Ao final dos testes do dia, execute `terraform destroy -auto-approve` para encerrar o banco e preservar os créditos do laboratório.
