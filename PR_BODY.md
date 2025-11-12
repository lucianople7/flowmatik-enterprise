# fix(connector): fallback, timeout, structured logging and validations

## 📋 Resumen

Este PR reorganiza el conector CLI de Flowmatik AutoGen en una estructura de paquete `autogen/` y añade mejoras significativas en robustez, observabilidad y manejo de errores.

## ✨ Cambios Principales

### 1. Reorganización del Paquete
- **Nuevo**: Estructura `autogen/connectors/` para organizar conectores
- **Movido**: `flowmatik_connector.py` → `autogen/connectors/flowmatik_connector.py`
- **Añadido**: Script generador `tools/write_autogen_files.ps1` para regenerar la estructura

### 2. Mejoras Funcionales
- ✅ **Fallback integrado**: Funciona sin `mcp_autogen_bridge` usando implementación básica
- ✅ **Timeout configurable**: Variable de entorno `PROCESS_TIMEOUT` (default: 30s)
- ✅ **Logging estructurado**: JSON logs en stderr, respuesta JSON en stdout
- ✅ **Validaciones robustas**: Manejo de JSON inválido, errores de parsing, timeouts
- ✅ **Métricas de tiempo**: Campo `tiempo_procesamiento_segundos` en respuesta
- ✅ **Type hints**: Anotaciones completas para Python 3.9+

### 3. Mejoras Técnicas
- Separación clara de stdout (respuesta) y stderr (logs)
- Timestamps ISO8601 con 'Z' (UTC)
- Manejo seguro de excepciones con traceback
- ThreadPoolExecutor para timeout controlado

## 🧪 Cómo Probar

### Test Básico (PowerShell)
```powershell
$env:PROCESS_TIMEOUT = "60"
'{"tipo_tarea":"monetizacion","prioridad":"alta","contexto_ceo":"Generar ingresos en 48h"}' | python autogen/connectors/flowmatik_connector.py > resultado.json 2> logs.json
```

### Test Básico (Bash)
```bash
export PROCESS_TIMEOUT=60
echo '{"tipo_tarea":"monetizacion","prioridad":"alta","contexto_ceo":"Generar ingresos en 48h"}' | python autogen/connectors/flowmatik_connector.py > resultado.json 2> logs.json
```

### Verificar Resultado
- `resultado.json` contiene JSON válido con `"estado": "exito"`
- `logs.json` contiene logs estructurados con `"level": "INFO"`

### Test JSON Inválido
```powershell
'{"tipo_tarea":"test"' | python autogen/connectors/flowmatik_connector.py 2>&1
```
**Esperado**: Output con `"estado": "error"` y log ERROR en stderr

### Test Sin Bridge
```powershell
'{"tipo_tarea":"optimizacion","prioridad":"alta","contexto_ceo":"Test"}' | python autogen/connectors/flowmatik_connector.py
```
**Verificar**: `"modulo_usado": "implementacion_basica_integrada"` en el output

### Test Timeout
```bash
export PROCESS_TIMEOUT=1
# Simular tarea lenta (requiere implementación que tarde >1s)
echo '{"tipo_tarea":"general","prioridad":"baja","contexto_ceo":"Timeout test"}' | timeout 2 python autogen/connectors/flowmatik_connector.py
```

## ⚠️ Breaking Changes

**El archivo CLI del conector se ha movido de la raíz a `autogen/connectors/flowmatik_connector.py`**

### Actualización Requerida
- **Antes**: `python flowmatik_connector.py`
- **Después**: `python autogen/connectors/flowmatik_connector.py`

### Archivos Actualizados en Este PR
- ✅ `test_connector.ps1`
- ✅ `test_connector_timeout.ps1`
- ✅ `README_CONNECTOR.md`
- ✅ `.github/workflows/test-connector.yml`
- ✅ `create_pr.ps1`

**Nota**: Por favor busca en tu proyecto otras ocurrencias de `"flowmatik_connector.py"` y actualízalas en consecuencia.

**No hay cambios en la API o formato de entrada/salida**; solo cambió la ubicación del archivo.

## 📁 Archivos Modificados

### Nuevos
- `autogen/__init__.py`
- `autogen/connectors/__init__.py`
- `autogen/connectors/flowmatik_connector.py`
- `tools/write_autogen_files.ps1`
- `README_CONNECTOR.md`
- `REFERENCIAS_RESTANTES.md`

### Modificados
- `PR_BODY.md` (este archivo)
- `test_connector.ps1`
- `test_connector_timeout.ps1`
- `.github/workflows/test-connector.yml`
- `create_pr.ps1`

## 🔍 Formato de Input/Output

### Input (JSON)
```json
{
  "tipo_tarea": "monetizacion|optimizacion|general",
  "prioridad": "alta|media|baja",
  "contexto_ceo": "Descripción del contexto",
  "resultado_esperado": "Opcional",
  "restricciones": "Opcional"
}
```

### Output (stdout - JSON)
```json
{
  "estado": "exito|error",
  "resultados": {
    "tipo_tarea": "...",
    "prioridad": "...",
    "recomendaciones": [...],
    "roi_estimado": "...",
    "timeline_dias": 2
  },
  "modulo_usado": "mcp_autogen_bridge|implementacion_basica_integrada",
  "tiempo_procesamiento_segundos": 0.123,
  "timestamp": "2025-11-12T08:00:00Z"
}
```

### Logs (stderr - JSON líneas)
```json
{"timestamp": "2025-11-12T08:00:00Z", "level": "INFO", "message": "Startup", "data": {...}}
{"timestamp": "2025-11-12T08:00:01Z", "level": "ERROR", "message": "Input error", "data": {...}}
```

## 📝 Notas

- **Tests y CI**: Los tests unitarios y workflows de CI mejorados se propondrán en un PR separado para mantener este cambio enfocado
- **Fallback**: El fallback integrado proporciona funcionalidad básica sin requerir `mcp_autogen_bridge`
- **Logs estructurados**: Facilitan debugging y monitoreo en producción
- **Compatibilidad**: Python 3.9+ requerido (por type hints `tuple[...]`)

## 🚀 Próximos Pasos (Futuros PRs)

- [ ] Tests unitarios completos (invalid JSON, timeout, bridge present/absent, schema)
- [ ] Workflow de CI mejorado con más casos de prueba
- [ ] Documentación de migración para consumidores externos
- [ ] Considerar valores más cortos para `modulo_usado` ("bridge"/"fallback")
