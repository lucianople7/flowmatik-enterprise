#!/usr/bin/env python3

"""

Conector CLI para Flowmatik AutoGen.

- Intenta usar mcp_autogen_bridge.process_task si está disponible.

- Si no, usa una implementación integrada (sin dependencias).

- Lee JSON desde stdin o desde el primer argumento.

- Ejecuta con timeout configurable vía PROCESS_TIMEOUT (segundos).

- Imprime JSON resultado en stdout y logs en stderr (JSON logs).

- Añade validaciones, métricas de tiempo y type hints.

"""



from __future__ import annotations



import sys

import json

import os

import time

import traceback

from datetime import datetime, timezone

from typing import Any, Dict, Optional

from concurrent.futures import ThreadPoolExecutor, TimeoutError



PROCESS_TIMEOUT: int = int(os.getenv("PROCESS_TIMEOUT", "30"))  # segundos por defecto





def now_iso_z() -> str:

    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")





# ---- Intentar importar bridge externo ----

try:

    from mcp_autogen_bridge import process_task as bridge_process_task  # type: ignore

    BRIDGE_AVAILABLE = True

except Exception:

    bridge_process_task = None

    BRIDGE_AVAILABLE = False





# ---- Logging estructurado (stdout reservado para la respuesta JSON) ----

def log_struct(level: str, message: str, data: Optional[Dict[str, Any]] = None) -> None:

    payload = {

        "timestamp": now_iso_z(),

        "level": level,

        "message": message,

    }

    if data is not None:

        payload["data"] = data

    # Enviar a stderr para no contaminar stdout (respuesta JSON)

    print(json.dumps(payload, ensure_ascii=False), file=sys.stderr)





# ---- Implementación integrada (fallback) ----

def integrated_process_task(task_data: Dict[str, Any]) -> Dict[str, Any]:

    """Implementación básica integrada, sin dependencias externas."""

    tipo_tarea = str(task_data.get("tipo_tarea", "analisis"))

    contexto = str(task_data.get("contexto_ceo", ""))

    prioridad = str(task_data.get("prioridad", "media"))



    # Lógica simple por tipo de tarea

    if any(k in tipo_tarea.lower() for k in ("monetiz", "monetización", "monetizacion")):

        recomendaciones = [

            "Crear plantilla descargable de estrategia de contenido (PDF) y venderla por $9 en redes sociales",

            "Ofrecer diagnóstico express (15-30 min) por pago anticipado vía PayPal/Stripe",

            "Automatizar generación de posts con un modelo liviano y monetizar con enlaces de afiliados"

        ]

        roi = "300%"

        timeline = 2

    elif "optimiz" in tipo_tarea.lower():

        recomendaciones = [

            "Batch + caching para reducir llamadas a APIs",

            "Sustituir APIs caras por modelos open-source y caching local",

            "Automatizar procesos recurrentes para ahorrar tiempo"

        ]

        roi = "80% ahorro estimado"

        timeline = 7

    else:

        recomendaciones = [

            "Definir la oferta mínima viable y el canal de venta",

            "Probar una oferta en 48h con la audiencia existente",

            "Medir conversión y escalar lo que funcione"

        ]

        roi = "variable"

        timeline = 3



    return {

        "estado": "exito",

        "resultados": {

            "tipo_tarea": tipo_tarea,

            "prioridad": prioridad,

            "contexto_analizado": (contexto[:200] + "...") if len(contexto) > 200 else contexto,

            "recomendaciones": recomendaciones,

            "roi_estimado": roi,

            "timeline_dias": timeline,

        },

        "modulo_usado": "mcp_autogen_bridge" if BRIDGE_AVAILABLE else "implementacion_basica_integrada",

        "timestamp": now_iso_z(),

    }





# ---- Wrapper seguro con timeout ----

def run_process_task(task_data: Dict[str, Any], timeout_seconds: int = PROCESS_TIMEOUT) -> Dict[str, Any]:

    """Ejecuta la función process_task (bridge si existe, sino integrado) con timeout."""

    fn = bridge_process_task if BRIDGE_AVAILABLE else integrated_process_task

    start = time.time()

    with ThreadPoolExecutor(max_workers=1) as ex:

        future = ex.submit(fn, task_data)

        try:

            result = future.result(timeout=timeout_seconds)

            elapsed = time.time() - start

            # Añadir métricas de tiempo si la respuesta es un dict

            if isinstance(result, dict):

                result.setdefault("tiempo_procesamiento_segundos", round(elapsed, 3))

            return result

        except TimeoutError:

            return {

                "estado": "error",

                "error": f"timeout de {timeout_seconds}s en process_task",

                "modulo_usado": fn.__name__,

                "timestamp": now_iso_z(),

            }

        except Exception as e:

            tb = traceback.format_exc()

            return {

                "estado": "error",

                "error": str(e),

                "traceback": tb,

                "modulo_usado": fn.__name__,

                "timestamp": now_iso_z(),

            }





# ---- Entrada / Salida y validaciones ----

def parse_input() -> tuple[Optional[Dict[str, Any]], Optional[str]]:

    raw = ""

    try:

        raw = sys.stdin.read()

        if not raw.strip():

            # Si no hay stdin, intentar argv[1]

            if len(sys.argv) >= 2:

                raw = sys.argv[1]

            else:

                return None, "No input: provide JSON via stdin or as first arg"

        # Limpiar potenciales escapes de PowerShell (comillas duplicadas)

        raw = raw.strip().strip("'\"")

        try:

            data = json.loads(raw)

            if not isinstance(data, dict):

                return None, "JSON must be an object/dict"

            return data, None

        except json.JSONDecodeError as e:

            return None, f"JSON decode error: {e}"

    except Exception as e:

        return None, f"Error leyendo input: {e}"





def main() -> int:

    log_struct("INFO", "Startup", {"PROCESS_TIMEOUT": PROCESS_TIMEOUT, "bridge_available": BRIDGE_AVAILABLE})



    task_data, err = parse_input()

    if err:

        out = {"estado": "error", "error": err, "timestamp": now_iso_z()}

        print(json.dumps(out, ensure_ascii=False))

        log_struct("ERROR", "Input error", {"error": err})

        return 1



    log_struct("INFO", "JSON leído desde stdin/arg", {"tamaño": len(json.dumps(task_data, ensure_ascii=False))})



    start = time.time()

    result = run_process_task(task_data, timeout_seconds=PROCESS_TIMEOUT)

    elapsed = time.time() - start



    # Asegurar formato mínimo de salida

    if not isinstance(result, dict):

        result = {"estado": "error", "error": "process_task returned non-dict", "timestamp": now_iso_z()}



    result.setdefault("timestamp", now_iso_z())

    result.setdefault("tiempo_procesamiento_segundos", round(elapsed, 3))



    print(json.dumps(result, ensure_ascii=False))

    log_struct("INFO", "Procesamiento completado", {"tiempo_segundos": round(elapsed, 3), "estado": result.get("estado")})

    return 0 if result.get("estado") == "exito" else 2





if __name__ == "__main__":

    sys.exit(main())

