"""Comprueba la entrega simulada desde la red interna de Docker.

Monitoreo exige app, Kibana y dos targets UP. Seguridad exige que
Elasticsearch rechace una petición sin contraseña.
"""

import json
import os
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path


def get(url):
    with urllib.request.urlopen(url, timeout=5) as response:
        return response.read().decode("utf-8")


app = os.getenv("LAB_APP_URL", "http://flask_service:8000")
prometheus = os.getenv("LAB_PROM_URL", "http://prometheus:9090")
kibana = os.getenv("LAB_KIBANA_URL", "http://kibana:5601")
elasticsearch = os.getenv("LAB_ES_URL", "http://elasticsearch:9200")

if len(sys.argv) != 2 or sys.argv[1] not in ("monitoreo", "seguridad"):
    raise SystemExit("Uso: verificar.py monitoreo|seguridad")

if sys.argv[1] == "monitoreo":
    expected = Path("app/home.txt").read_text(encoding="utf-8")
    for attempt in range(30):
        try:
            assert get(f"{app}/health").strip() == "ok"
            assert get(app + "/") == expected
            data = json.loads(get(f"{prometheus}/api/v1/query?query=up"))
            up = {row["metric"]["job"] for row in data["data"]["result"] if row["value"][1] == "1"}
            assert {"flask_service", "prometheus"} <= up
            get(f"{kibana}/api/status")
            print("Entrega comprobada: mensaje publicado, app y Kibana listos, targets UP.")
            break
        except (AssertionError, KeyError, OSError, ValueError):
            if attempt == 29:
                raise SystemExit("La entrega o el monitoreo no están listos.")
            time.sleep(5)
else:
    try:
        get(elasticsearch + "/")
    except urllib.error.HTTPError as error:
        if error.code != 401:
            raise SystemExit(f"Elasticsearch respondió {error.code}, se esperaba 401.")
        print("Seguridad comprobada: Elasticsearch exige autenticación.")
    else:
        raise SystemExit("Elasticsearch permite acceso sin contraseña.")
