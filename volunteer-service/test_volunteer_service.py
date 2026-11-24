import importlib
from unittest.mock import MagicMock

import pytest


@pytest.fixture
def ctx(monkeypatch):
    monkeypatch.setenv("AWS_DYNAMODB_TABLE", "T")
    monkeypatch.setenv("AWS_DEFAULT_REGION", "us-east-1")
    table = MagicMock()
    resource = MagicMock()
    resource.Table.return_value = table
    monkeypatch.setattr("boto3.resource", lambda *a, **k: resource)
    import app as app_module
    importlib.reload(app_module)
    app_module.app.config["TESTING"] = True
    return app_module.app.test_client(), table


def test_health(ctx):
    client, _ = ctx
    assert client.get("/health").get_json()["service"] == "volunteer-service"


def test_register_missing_fields(ctx):
    client, _ = ctx
    assert client.post("/volunteers", json={"name": "x"}).status_code == 400


def test_register_ok(ctx):
    client, table = ctx
    r = client.post("/volunteers", json={"name": "A", "email": "a@a.org", "ngo_id": 1})
    assert r.status_code == 201 and table.put_item.called


def test_register_dynamo_error(ctx):
    client, table = ctx
    table.put_item.side_effect = Exception("boom")
    r = client.post("/volunteers", json={"name": "A", "email": "a@a.org", "ngo_id": 1})
    assert r.status_code == 500


def test_list_by_ngo(ctx):
    client, table = ctx
    table.scan.return_value = {"Items": [{"volunteer_id": "1"}]}
    assert client.get("/volunteers/1").get_json() == [{"volunteer_id": "1"}]
