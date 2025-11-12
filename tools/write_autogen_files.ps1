#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Genera automaticamente la estructura del paquete autogen y sus archivos.

.DESCRIPTION
    Este script regenera los archivos del paquete autogen:
    - autogen/__init__.py
    - autogen/connectors/__init__.py
    - autogen/connectors/flowmatik_connector.py

    Opcionalmente crea una rama nueva y hace commit local (no hace push por seguridad).

.PARAMETER BranchName
    Nombre de la rama a crear si se usa -CreateBranch. Por defecto: "chore/autogen-generate-files"

.PARAMETER CommitMessage
    Mensaje del commit. Por defecto: "chore(autogen): generate autogen package files"

.PARAMETER CreateBranch
    Si se especifica, crea una nueva rama antes de generar los archivos.

.EXAMPLE
    .\tools\write_autogen_files.ps1
    
.EXAMPLE
    .\tools\write_autogen_files.ps1 -CreateBranch -BranchName "chore/regenerate-autogen"
#>

param(
    [string]$BranchName = "chore/autogen-generate-files",
    [string]$CommitMessage = "chore(autogen): generate autogen package files",
    [switch]$CreateBranch
)

# Verificar que estamos en un repositorio git
if (-not (Test-Path ".git")) {
    Write-Error "No se encontro un repositorio git. Ejecuta este script desde la raiz del repositorio."
    exit 1
}

# Crear rama si se solicita
if ($CreateBranch) {
    Write-Host "Creando rama: $BranchName" -ForegroundColor Cyan
    git checkout -b $BranchName 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "La rama $BranchName ya existe o hubo un error. Continuando..."
    }
}

# Crear estructura de directorios
Write-Host "Creando estructura de directorios..." -ForegroundColor Cyan
New-Item -Path "autogen\connectors" -ItemType Directory -Force | Out-Null

# 1. autogen/__init__.py
$autogenInit = @'
# autogen package

__all__ = ["connectors", "agents", "config"]
'@
$autogenInit | Out-File -FilePath "autogen\__init__.py" -Encoding utf8 -NoNewline
Write-Host "[OK] Creado: autogen\__init__.py" -ForegroundColor Green

# 2. autogen/connectors/__init__.py
$connectorsInit = @'
# autogen.connectors package

__all__ = ["flowmatik_connector"]
'@
$connectorsInit | Out-File -FilePath "autogen\connectors\__init__.py" -Encoding utf8 -NoNewline
Write-Host "[OK] Creado: autogen\connectors\__init__.py" -ForegroundColor Green

# 3. autogen/connectors/flowmatik_connector.py
# Copiar desde el archivo existente si esta disponible
$connectorPath = "autogen\connectors\flowmatik_connector.py"

if (Test-Path $connectorPath) {
    Write-Host "[OK] Archivo ya existe: $connectorPath" -ForegroundColor Green
} else {
    $rootConnector = "flowmatik_connector.py"
    if (Test-Path $rootConnector) {
        Copy-Item -Path $rootConnector -Destination $connectorPath -Force
        Write-Host "[OK] Copiado desde raiz: $connectorPath" -ForegroundColor Green
    } else {
        Write-Warning "No se encontro el archivo fuente. El archivo $connectorPath debe crearse manualmente."
    }
}

Write-Host ""
Write-Host "Archivos generados exitosamente." -ForegroundColor Cyan

# Stage and commit
Write-Host ""
Write-Host "Anadiendo archivos al staging..." -ForegroundColor Cyan
git add autogen 2>&1 | Out-Null

$status = git status --porcelain
if ($status) {
    Write-Host ""
    Write-Host "Archivos en staging:" -ForegroundColor Yellow
    $status | ForEach-Object { Write-Host "  $_" }
    
    Write-Host ""
    Write-Host "Creando commit..." -ForegroundColor Cyan
    git commit -m $CommitMessage 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Commit creado exitosamente con mensaje: $CommitMessage" -ForegroundColor Green
    } else {
        Write-Warning "El commit fallo. Revisa 'git status' para mas detalles."
    }
} else {
    Write-Host "No hay cambios para commitear." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Listo. Revisa 'git status' y si quieres hacer push ejecuta:" -ForegroundColor Cyan
if ($CreateBranch) {
    $pushCmd = "git push -u origin $BranchName"
    Write-Host "  $pushCmd" -ForegroundColor White
} else {
    $currentBranch = git branch --show-current
    $pushCmd = "git push -u origin $currentBranch"
    Write-Host "  $pushCmd" -ForegroundColor White
}
