# Checklist — repo `solidarytech` (código, infra, pipelines, documentos)

Os manifestos Kubernetes, ArgoCD e observabilidade estão no checklist do repo `solidarytech-gitops`.
Requisito do PDF só conta se estiver demonstrado no vídeo ou no relatório: guarde prints em `docs/evidencias/`.

## ✅ Feito

**Etapa 1 — Fundação local**
- [x] Dockerfiles multi-stage, usuário não-root (`*-service/Dockerfile`)
- [x] `docker-compose.yml` (2 Postgres + DynamoDB local), testado ponta a ponta
- [x] Testes unitários (ngo 5, volunteer 5, donation 6) e lint (flake8, bandit, go vet)
- [x] Instrumentação OpenTelemetry nos 3 serviços (`telemetry.py`, `telemetry.go`)
- [x] Bugs do código fornecido corrigidos: `go.mod` inválido, import sem uso, import do boto3, libs com CVE (detalhes em `docs/evidencias/etapa1-local.md`)

**Etapa 2 — Terraform**
- [x] Módulos `network`, `eks`, `rds`, `dynamodb`, `sqs`, `ecr` e a composição `platform` (`infra/terraform/modules/`)
- [x] Tags FinOps obrigatórias com validação no código (Project, Environment, CostCenter)
- [x] Ambientes `primary` (us-east-1) e `standby` (us-west-2) (`infra/terraform/envs/`)
- [x] Scripts: `infra-up.sh`, `dr-standby-up.sh`, `check-tags.sh`, `setup-backend.sh`
- [x] `terraform validate` e `fmt` OK nos dois ambientes (**nada foi aplicado na AWS ainda**)

## 🔲 Falta

**Antes de tudo**
- [ ] Renovar a sessão do AWS Academy (`aws configure`)
- [ ] `terraform plan` real do primary e revisão
- [ ] `bash scripts/infra-up.sh primary` (apply; avisar o grupo, gasta crédito)
- [ ] Confirmar que a versão do EKS (hoje `1.33`, em `modules/eks/variables.tf`) está em standard support

**Etapa 3 — CI/CD DevSecOps (PDF p.3)**
- [ ] 3 workflows em `.github/workflows/` (base: `entregues-fase-4/.../workflows`):
  test → lint → SAST/SCA → build → Trivy → push no ECR
  - Python: flake8, bandit, Trivy fs. Go: golangci-lint, gosec, Trivy fs
  - Falhar em vulnerabilidade CRITICAL
- [ ] Último passo do CI: atualizar a tag da imagem no repo `solidarytech-gitops`
- [ ] Secrets do GitHub (credenciais do Academy mudam a cada sessão) e token de escrita no repo gitops
- [ ] Script único de subida, no estilo `run-all.sh` da Fase 4

**Etapa 4 — Observabilidade (PDF p.3–4)**
- [ ] Conta New Relic e secret da license key (base: `setup-newrelic.sh` da Fase 4)
- [ ] Confirmar traces distribuídos e Service Map no New Relic

**Etapa 5 — SRE (PDF p.4)**
- [ ] `docs/sre/`: ≥2 SLIs e SLOs do `donation-service` (latência e taxa de erro), mais definição de SLA
- [ ] Parágrafo de MTTR para o relatório

**Etapa 6 — FinOps (PDF p.4)**
- [ ] `docs/finops/`: forecast mensal de custo e ≥1 recomendação de otimização
- [ ] Rodar `bash scripts/check-tags.sh` e salvar o print das tags

**Etapa 7 — ITSM/AIOps (PDF p.5)**
- [ ] Ativar Applied Intelligence no New Relic
- [ ] `docs/itsm/`: desenho do ciclo de vida do incidente (detecção, alerta, resposta, post-mortem, comunicação)

**Etapa 8 — DR (PDF p.5)**
- [ ] `docs/dr/`: PCN executivo com RTO e RPO das doações
- [ ] Subir o standby (`bash scripts/dr-standby-up.sh`) ou mostrar o `plan`, com evidência
- [ ] Runbook de failover (promover a réplica do RDS e apontar o app)

**Etapa 9 — Entrega (PDF p.6–7)**
- [ ] Vídeo de até 20 min: pitch executivo + demo técnica
- [ ] Relatório PDF: nomes, RMs, usernames, links e as seções SRE, FinOps, Segurança/DR e ITSM/AIOps
- [ ] `terraform destroy` ao final, para não gastar crédito

## Regras
1. Sem `kubectl apply` manual e sem recurso criado no console: tudo via Terraform e GitOps.
2. Não commitar `.env`, `.secrets/`, `backend.tf`, `*.tfstate`, chaves ou tokens.
3. Sem IAM Role ou Policy no Terraform (Academy): usar a LabRole.
4. Avisar o grupo antes de `apply` ou `destroy`.

## Rodar local
```bash
docker compose up -d --build     # localhost:8081 (ngo), 8082 (donation), 8083 (volunteer)
curl localhost:8082/health
docker compose down -v

cd ngo-service && pip install -r requirements.txt -r requirements-dev.txt && pytest
cd donation-service && go test ./...
```
