import importlib
from unittest.mock import MagicMock

import psycopg2
import pytest


@pytest.fixture
def ctx(monkeypatch):
    monkeypatch.setenv("DATABASE_URL", "postgres://u:p@localhost/db")
    pool = MagicMock()
    monkeypatch.setattr("psycopg2.pool.SimpleConnectionPool", lambda *a, **k: pool)
    import app as app_module
    importlib.reload(app_module)
    app_module.app.config["TESTING"] = True
    return app_module.app.test_client(), pool


def _cursor(pool):
    conn = pool.getconn.return_value
    return conn, conn.cursor.return_value.__enter__.return_value


def test_health(ctx):
    client, _ = ctx
    r = client.get("/health")
    assert r.status_code == 200 and r.get_json()["service"] == "ngo-service"


def test_create_ngo_missing_fields(ctx):
    client, _ = ctx
    assert client.post("/ngos", json={"name": "x"}).status_code == 400


def test_create_ngo_ok(ctx):
    client, pool = ctx
    _, cur = _cursor(pool)
    cur.fetchone.return_value = {"id": 1, "name": "A"}
    r = client.post("/ngos", json={"name": "A", "email": "a@a.org", "cause": "c", "city": "d"})
    assert r.status_code == 201


def test_create_ngo_duplicate_email(ctx):
    client, pool = ctx
    _, cur = _cursor(pool)
    cur.execute.side_effect = psycopg2.IntegrityError()
    r = client.post("/ngos", json={"name": "A", "email": "a@a.org", "cause": "c", "city": "d"})
    assert r.status_code == 409


def test_list_ngos(ctx):
    client, pool = ctx
    _, cur = _cursor(pool)
    cur.fetchall.return_value = [{"id": 1}]
    assert client.get("/ngos").get_json() == [{"id": 1}]
