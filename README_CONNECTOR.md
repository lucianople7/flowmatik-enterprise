# Flowmatik Connector — Uso rápido

Resumen
- Conector CLI para Flowmatik AutoGen.
- Lee JSON desde stdin o desde el primer argumento.
- Usa mcp_autogen_bridge si está disponible; si no, fallback integrado.
- Timeout configurable via PROCESS_TIMEOUT (segundos).
- Salida: JSON en stdout; logs estructurados (JSON) en stderr.

Uso (PowerShell)
$env:PROCESS_TIMEOUT = "60"
'{"tipo_tarea":"monetizacion","prioridad":"alta","contexto_ceo":"Generar ingresos en 48h"}' | python flowmatik_connector.py > resultado.json 2> logs.json

Uso (bash)
PROCESS_TIMEOUT=60 echo '{"tipo_tarea":"monetizacion","prioridad":"alta","contexto_ceo":"Generar ingresos en 48h"}' | python3 flowmatik_connector.py > resultado.json 2> logs.json

Formato de input/output
- Input: JSON object con campos recomendados: tipo_tarea, prioridad, contexto_ceo, resultado_esperado, restricciones.
- Output (stdout): JSON con campo "estado" (exito/error), "resultados", "modulo_usado", "tiempo_procesamiento_segundos" y "timestamp".
- Logs (stderr): líneas JSON con {timestamp, level, message, data}.

Validaciones y troubleshooting
- JSON inválido -> stdout: estado:error; stderr: log ERROR.
- Sin mcp_autogen_bridge -> modulo_usado: implementacion_basica_integrada.
- Forzar timeout: fijar PROCESS_TIMEOUT y simular tarea lenta; la salida indicará timeout.
- Para depurar, redirige stderr a un archivo y revisa las líneas JSON.

Notas
- Este README es una referencia rápida. Tests y CI están en un PR separado.
