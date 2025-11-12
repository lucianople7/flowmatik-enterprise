# Script de prueba para flowmatik_connector.py en PowerShell

# Método 1: Usar comillas simples para envolver el JSON
Write-Host "`n=== Método 1: Comillas simples ===" -ForegroundColor Cyan
python autogen/connectors/flowmatik_connector.py '{"task":"Optimizar generación de imágenes para marketing","context":"Presupuesto limitado, calidad profesional, enfoque internacional"}'

# Método 2: Usar comillas dobles escapadas
Write-Host "`n=== Método 2: Comillas dobles escapadas ===" -ForegroundColor Cyan
python autogen/connectors/flowmatik_connector.py "{\"task\":\"Optimizar generación de imágenes para marketing\",\"context\":\"Presupuesto limitado, calidad profesional, enfoque internacional\"}"

# Método 3: Desde archivo JSON
Write-Host "`n=== Método 3: Desde archivo JSON ===" -ForegroundColor Cyan
$jsonContent = @"
{
    "task": "Optimizar generación de imágenes para marketing",
    "context": "Presupuesto limitado, calidad profesional, enfoque internacional"
}
"@
$jsonContent | python autogen/connectors/flowmatik_connector.py

# Método 4: Usar ConvertTo-Json de PowerShell
Write-Host "`n=== Método 4: ConvertTo-Json ===" -ForegroundColor Cyan
$taskObj = @{
    task = "Optimizar generación de imágenes para marketing"
    context = "Presupuesto limitado, calidad profesional, enfoque internacional"
}
$jsonString = $taskObj | ConvertTo-Json -Compress
python autogen/connectors/flowmatik_connector.py $jsonString

