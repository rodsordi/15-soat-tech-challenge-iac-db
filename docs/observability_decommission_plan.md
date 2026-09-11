# Plano de Implementação: Descomissionamento da Stack Legada de Observabilidade e Padronização no New Relic

## Contexto e Motivação

Atualmente, coexistem duas abordagens de observabilidade no ecossistema:
1. **New Relic (Oficial do Projeto)**:
   - Provisionado em `15-soat-tech-challenge-iac-k8s` (`modules/observability-newrelic`) via Helm.
   - Fornece monitoramento centralizado de nós, pods, logs, eventos de cluster, APM e alertas NRQL.
   - Aplicação Spring Boot (`api-garage`) instrumentada nativamente para envio OTLP ao New Relic.
2. **Stack Local In-Cluster (Legada / Redundante)**:
   - Provisionada em `15-soat-tech-challenge-iac-db` (`modules/observability`), contendo **Prometheus, Grafana, Loki, Jaeger e Kube-State-Metrics**.
   - Viola o Princípio da Responsabilidade Única (SRP) por estar hospedada no repositório de banco de dados (`iac-db`).
   - Consome ~1 GB a 1.5 GB de RAM e concorre por CPU com a aplicação e com o Keycloak nos nós de trabalho.

---

## Proposta de Solução

Descomissionar completamente a stack local do repositório `15-soat-tech-challenge-iac-db` e limpar os recursos no cluster Kubernetes, consolidando o **New Relic One** como o único painel de observabilidade (*Single Pane of Glass*).

---

## Alterações Propostas

### Repositório `15-soat-tech-challenge-iac-db`

#### [MODIFY] `main.tf`
- Remover o bloco `module "observability"`.
- O repositório passará a ser 100% focado no provisionamento do banco relacional **AWS RDS PostgreSQL** (`module "rds"`).

#### [MODIFY] `providers.tf`
- Remover o provedor `kubernetes` e o data source `aws_eks_cluster_auth`, mantendo apenas o data source `aws_eks_cluster` para obtenção da VPC ID e subnets do RDS.

#### [MODIFY] `variables.tf`
- Remover a variável obsoleta `namespace_name`.

#### [DELETE] Pastas e Arquivos Legados:
- `modules/observability/` (`main.tf`, `variables.tf`, `outputs.tf`)
- `grafana/` (dashboards e datasources locais)
- `prometheus/` (configurações locais de scrape)

#### [MODIFY] `README.md`
- Atualizar a documentação e diagrama arquitetural:
  - Remover referências ao Grafana, Prometheus, Loki e Jaeger.
  - Documentar que a observabilidade é centralizada via **New Relic** no repositório `15-soat-tech-challenge-iac-k8s`.

---

## Plano de Verificação

### 1. Validação Local do Terraform
- Executar `terraform fmt -check` e `terraform validate` no diretório `15-soat-tech-challenge-iac-db`.
- Executar `terraform plan` para garantir que apenas os recursos de observabilidade sejam marcados para destruição, mantendo o banco de dados RDS (`module.rds`) intacto.

### 2. Validação no Cluster Kubernetes (EKS)
- Aplicar a limpeza via Terraform / kubectl:
  - Verificar que os pods `prometheus`, `grafana`, `jaeger`, `loki` e `kube-state-metrics` foram removidos.
  - Verificar que os pods vitais da aplicação (`api-garage`, `keycloak`, `keycloak-db`) e do New Relic continuam **1/1 Running**.
  - Testar o health check via API Gateway (`https://6t8e18w3f8.execute-api.us-east-1.amazonaws.com/api/actuator/health`) confirmando `HTTP 200 UP`.
