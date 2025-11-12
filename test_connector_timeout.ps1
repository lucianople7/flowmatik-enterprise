# Script de prueba para flowmatik_connector.py con timeout y logging

Write-Host "`n=== TEST 1: Connector sin timeout ===" -ForegroundColor Cyan
'{"tipo_tarea":"monetizacion","prioridad":"alta","contexto_ceo":"Test sin timeout","resultado_esperado":"Funciona","restricciones":"Ninguna"}' | python autogen/connectors/flowmatik_connector.py 2>&1 | Select-Object -First 5

Write-Host "`n=== TEST 2: Connector con timeout (60s) ===" -ForegroundColor Cyan
$env:PROCESS_TIMEOUT = "60"
'{"tipo_tarea":"optimizacion","prioridad":"alta","contexto_ceo":"Test con timeout","resultado_esperado":"Funciona","restricciones":"Ninguna"}' | python autogen/connectors/flowmatik_connector.py 2>&1 | Select-Object -First 5

Write-Host "`n=== TEST 3: Verificar logs en stderr ===" -ForegroundColor Cyan
$result = '{"tipo_tarea":"general","prioridad":"baja","contexto_ceo":"Test logs","resultado_esperado":"Ver logs","restricciones":"Ninguna"}' | python autogen/connectors/flowmatik_connector.py 2>&1
$stdout = $result | Where-Object { $_ -notmatch '"level"' }
$stderr = $result | Where-Object { $_ -match '"level"' }
Write-Host "STDOUT (resultado):" -ForegroundColor Green
$stdout
Write-Host "`nSTDERR (logs):" -ForegroundColor Yellow
$stderr

Write-Host "`n=== TEST 4: JSON inválido (debe fallar gracefully) ===" -ForegroundColor Cyan
'{"tipo_tarea":"test"' | python autogen/connectors/flowmatik_connector.py 2>&1 | Select-Object -First 3

Write-Host "`n=== TEST 5: Validar métricas de tiempo ===" -ForegroundColor Cyan
$output = '{"tipo_tarea":"monetizacion","prioridad":"alta","contexto_ceo":"Test métricas","resultado_esperado":"Ver tiempo","restricciones":"Ninguna"}' | python autogen/connectors/flowmatik_connector.py 2>&1
$output | ConvertFrom-Json | Select-Object -Property estado, tiempo_procesamiento_segundos, modulo_usado

Write-Host "`n✅ Tests completados" -ForegroundColor Green

