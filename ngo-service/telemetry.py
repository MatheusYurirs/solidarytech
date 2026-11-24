import os
import logging

from opentelemetry import trace
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
from opentelemetry.instrumentation.flask import FlaskInstrumentor
from opentelemetry.instrumentation.psycopg2 import Psycopg2Instrumentor

log = logging.getLogger(__name__)


def setup_telemetry(app, service_name):
    """Configura o OpenTelemetry pro app Flask e e pro psycopg2.
    Sem OTEL_EXPORTER_OTLP_ENDPOINT definida, o serviço continua funcionando
    normalmente, só sem exportar nada (igual nos serviços em Go)."""
    if not os.getenv("OTEL_EXPORTER_OTLP_ENDPOINT"):
        log.info("OpenTelemetry: endpoint não definido; exportação desativada")
        return

    resource = Resource.create({"service.name": service_name})
    provider = TracerProvider(resource=resource)
    provider.add_span_processor(BatchSpanProcessor(OTLPSpanExporter()))
    trace.set_tracer_provider(provider)

    FlaskInstrumentor().instrument_app(app, excluded_urls="health")
    Psycopg2Instrumentor().instrument()

    log.info("OpenTelemetry: exportação OTLP/HTTP configurada")
