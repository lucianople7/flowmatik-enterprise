## Qué incluye

- Reemplazo/añadido de `flowmatik_connector.py` con:
  - Fallback integrado cuando `mcp_autogen_bridge` no está disponible
  - Timeout configurable vía variable de entorno `PROCESS_TIMEOUT`
  - Logging estructurado en JSON (stderr)
  - Validaciones robustas de input
  - Métricas de tiempo de procesamiento
  - Timestamps ISO8601 con 'Z'

- Añadido `README_CONNECTOR.md` (conciso) con:
  - Uso rápido (PowerShell y Bash)
  - Ejemplos de input/output
  - Instrucciones de validación
  - Troubleshooting básico

## Cómo probar localmente

### 1. Test básico con timeout

**PowerShell:**
```powershell
$env:PROCESS_TIMEOUT = "60"
'{"tipo_tarea":"monetizacion","prioridad":"alta","contexto_ceo":"Generar ingresos en 48h","resultado_esperado":"3 flujos automatizados","restricciones":"Sin Docker"}' | python autogen/connectors/flowmatik_connector.py > resultado.json 2> logs.json
```

**Bash:**
```bash
export PROCESS_TIMEOUT=60
echo '{"tipo_tarea":"monetizacion","prioridad":"alta","contexto_ceo":"Generar ingresos en 48h","resultado_esperado":"3 flujos automatizados","restricciones":"Sin Docker"}' | python autogen/connectors/flowmatik_connector.py > resultado.json 2> logs.json
```

**Verificar:**
- `resultado.json` contiene JSON válido con `"estado": "exito"`
- `logs.json` contiene logs estructurados con `"level": "INFO"`

### 2. Test JSON inválido

```powershell
'{"tipo_tarea":"test"' | python autogen/connectors/flowmatik_connector.py 2>&1
```

**Esperado:**
- Output con `"estado": "error"`
- Log ERROR en stderr con detalles del error

### 3. Test sin mcp_autogen_bridge

```powershell
'{"tipo_tarea":"optimizacion","prioridad":"alta","contexto_ceo":"Test","resultado_esperado":"Success","restricciones":"None"}' | python autogen/connectors/flowmatik_connector.py
```

**Verificar:**
- `"modulo_usado": "implementacion_basica_integrada"` en el output
- Recomendaciones específicas según tipo de tarea

### 4. Test timeout (Unix/Linux)

```bash
export PROCESS_TIMEOUT=1
# Simular tarea lenta (requiere implementación que tarde >1s)
echo '{"tipo_tarea":"general","prioridad":"baja","contexto_ceo":"Timeout test","resultado_esperado":"Should timeout","restricciones":"None"}' | timeout 2 python autogen/connectors/flowmatik_connector.py
```

**Nota:** Timeout con `signal.SIGALRM` solo funciona en Unix/Linux. En Windows, el timeout se aplica a nivel de aplicación.

### 5. Separar stdout y stderr

**PowerShell:**
```powershell
$output = '{"tipo_tarea":"test","prioridad":"baja","contexto_ceo":"Test","resultado_esperado":"Success","restricciones":"None"}' | python autogen/connectors/flowmatik_connector.py 2>&1
$resultado = $output | Where-Object { $_ -notmatch '"level"' }
$logs = $output | Where-Object { $_ -match '"level"' }
Write-Host "Resultado:" -ForegroundColor Green
$resultado
Write-Host "`nLogs:" -ForegroundColor Yellow
$logs
```

**Bash:**
```bash
resultado=$(echo '{"tipo_tarea":"test"}' | python autogen/connectors/flowmatik_connector.py 2>/dev/null)
logs=$(echo '{"tipo_tarea":"test"}' | python autogen/connectors/flowmatik_connector.py 2>&1 | grep '"level"')
echo "Resultado: $resultado"
echo "Logs: $logs"
```

## ⚠️ Breaking Changes

El archivo CLI del conector se ha movido de la raíz del repositorio a `autogen/connectors/flowmatik_connector.py`.

**Actualización requerida:**
- Si tienes scripts que usan: `python flowmatik_connector.py`
- Cámbialos a: `python autogen/connectors/flowmatik_connector.py`

Este PR actualiza las referencias principales en tests y documentación, pero por favor busca en tu proyecto otras ocurrencias de `"flowmatik_connector.py"` y actualízalas en consecuencia.

**Nota:** No hay cambios en la API o formato de entrada/salida del conector; solo cambió la ubicación del archivo.

## Notas

- Tests y CI (`.github/workflows/test-connector.yml` y `test_connector_timeout.ps1`) se propondrán en un PR separado para mantener este cambio pequeño y fácil de revisar.
- El fallback integrado proporciona funcionalidad básica sin requerir `mcp_autogen_bridge`.
- Los logs estructurados facilitan debugging y monitoreo en producción.
