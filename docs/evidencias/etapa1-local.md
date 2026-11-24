# Evidência Etapa 1 — Fundação local
- `docker compose up -d --build`: 2 Postgres + DynamoDB local + 3 serviços sobem saudáveis.
- `/health` nos 3 serviços = ok. POST/GET validados em ngo (8081), donation (8082, status APPROVED) e volunteer (8083).
- Testes: ngo 5/5, volunteer 5/5 (pytest), donation 6/6 (go test). flake8, bandit e go vet limpos.
- Imagens: donation 45.8MB (Go, alpine), ngo 218MB, volunteer 253MB (python slim). Todas rodam como usuário não-root.
