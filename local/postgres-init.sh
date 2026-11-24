#!/bin/sh
# Cria os dois bancos independentes e aplica os scripts de cada serviço.
set -e
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d postgres \
  -c "CREATE DATABASE ngo_db;" \
  -c "CREATE DATABASE donation_db;"
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d ngo_db      -f /sql/ngo.sql
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d donation_db -f /sql/donation.sql
