"""App de prueba del laboratorio.

Cada visita suma una métrica y envía un log. Prometheus lee /metrics;
Kibana muestra los logs que Logstash guarda en Elasticsearch.
"""

import json
import os
import urllib.request
from datetime import datetime, timezone
from pathlib import Path

from flask import Flask, Response, request
from prometheus_client import CONTENT_TYPE_LATEST, Counter, generate_latest

# Crea la app y un contador separado por ruta, método y estado HTTP.
app = Flask(__name__)
requests_total = Counter(
    "http_requests_total",
    "Peticiones HTTP atendidas por la aplicación de laboratorio",
    ["method", "path", "status"],
)


# Prepara un evento con fecha y lo envía a Logstash en formato JSON.
# Si Logstash aún no responde, la app sigue funcionando.
def send_log(level: str, message: str, status: int) -> None:
    event = {
        "@timestamp": datetime.now(timezone.utc).isoformat(),
        "level": level,
        "message": message,
        "service": "flask_service",
        "path": request.path,
        "status": status,
    }
    print(json.dumps(event), flush=True)
    payload = json.dumps(event).encode("utf-8")
    req = urllib.request.Request(
        os.environ.get("LOGSTASH_URL", "http://logstash:8080"),
        data=payload,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        urllib.request.urlopen(req, timeout=1).close()
    except Exception as exc:
        print(f"Logstash no disponible todavía: {exc}", flush=True)


# Después de cada petición real, suma el contador y registra INFO o ERROR.
# Las rutas internas /metrics y /health no se cuentan.
@app.after_request
def record_request(response):
    if request.path not in ("/metrics", "/health"):
        requests_total.labels(request.method, request.path, str(response.status_code)).inc()
        level = "ERROR" if response.status_code >= 500 else "INFO"
        send_log(level, f"{request.method} {request.path} respondió {response.status_code}", response.status_code)
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["Referrer-Policy"] = "no-referrer"
    response.headers["Cache-Control"] = "no-store"
    return response


# Rutas de práctica: / responde bien y /error produce un fallo intencional.
@app.get("/")
def home():
    # Jenkins publica un mensaje en el volumen compartido; antes se usa el inicial.
    published = Path("/release/home.txt")
    source = published if published.is_file() else Path("/app/home.txt")
    return Response(source.read_text(encoding="utf-8"), mimetype="text/plain")


@app.get("/error")
def sample_error():
    return Response("Error de prueba: se generó un log ERROR.\n", status=500, mimetype="text/plain")


# Rutas internas: Docker usa /health y Prometheus consulta /metrics.
@app.get("/health")
def health():
    return "ok\n"


@app.get("/metrics")
def metrics():
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)


# Inicia el servidor cuando se ejecuta este archivo dentro del contenedor.
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
