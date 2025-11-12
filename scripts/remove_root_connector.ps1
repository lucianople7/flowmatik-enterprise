#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Script para crear PR que elimina flowmatik_connector.py de la raíz.

.DESCRIPTION
    Este script automatiza la creación de un PR para eliminar el archivo
    flowmatik_connector.py de la raíz después de que el conector fue movido
    a autogen/connectors/flowmatik_connector.py.

.PARAMETER AutoCreatePR
    Si se especifica, crea el PR automáticamente usando gh CLI.

.EXAMPLE
    .\scripts\remove_root_connector.ps1
    
.EXAMPLE
    .\scripts\remove_root_connector.ps1 -AutoCreatePR
#>

param(
    [switch]$AutoCreatePR
)

$ErrorActionPreference = "Stop"

Write-Host "🧹 Preparando eliminación de flowmatik_connector.py de la raíz..." -ForegroundColor Cyan

# Verificar que estamos en un repositorio git
if (-not (Test-Path ".git")) {
    Write-Error "No se encontró un repositorio git. Ejecuta este script desde la raíz del repositorio."
    exit 1
}

# Verificar que estamos en main y está actualizado
$currentBranch = git branch --show-current
if ($currentBranch -ne "main") {
    Write-Host "⚠️  No estás en la rama main. Cambiando a main..." -ForegroundColor Yellow
    git checkout main
    if ($LASTEXITCODE -ne 0) {
        Write-Error "No se pudo cambiar a main. Asegúrate de que no hay cambios sin commitear."
        exit 1
    }
}

Write-Host "📥 Actualizando main desde remoto..." -ForegroundColor Cyan
git pull origin main
if ($LASTEXITCODE -ne 0) {
    Write-Warning "Hubo un problema al hacer pull. Continuando..."
}

# Verificar que el archivo existe
if (-not (Test-Path "flowmatik_connector.py")) {
    Write-Host "✅ El archivo flowmatik_connector.py ya no existe en la raíz." -ForegroundColor Green
    Write-Host "   No es necesario crear este PR." -ForegroundColor Yellow
    exit 0
}

# Verificar que el nuevo archivo existe
if (-not (Test-Path "autogen/connectors/flowmatik_connector.py")) {
    Write-Error "El archivo autogen/connectors/flowmatik_connector.py no existe."
    Write-Error "Asegúrate de que el PR anterior está mergeado."
    exit 1
}

# Buscar referencias residuales
Write-Host "🔍 Buscando referencias residuales..." -ForegroundColor Cyan
$references = Get-ChildItem -Recurse -File -Exclude __pycache__,*.pyc,backup_refs,venv | 
    Select-String -Pattern 'flowmatik_connector\.py' | 
    Where-Object { $_.Path -notmatch 'autogen/connectors|backup_refs|PR_REVIEW|RESUMEN_COMPLETO|PR_REMOVE_ROOT' }

if ($references) {
    Write-Host "⚠️  Se encontraron referencias al archivo:" -ForegroundColor Yellow
    $references | Format-Table Path,LineNumber,Line -AutoSize
    $response = Read-Host "¿Continuar de todas formas? (s/N)"
    if ($response -ne "s" -and $response -ne "S") {
        Write-Host "Operación cancelada." -ForegroundColor Yellow
        exit 0
    }
} else {
    Write-Host "✅ No se encontraron referencias residuales críticas." -ForegroundColor Green
}

# Crear rama
$branchName = "chore/remove-root-connector"
Write-Host "🌿 Creando rama: $branchName" -ForegroundColor Cyan
git checkout -b $branchName
if ($LASTEXITCODE -ne 0) {
    Write-Error "No se pudo crear la rama. Puede que ya exista."
    exit 1
}

# Eliminar archivo
Write-Host "🗑️  Eliminando flowmatik_connector.py..." -ForegroundColor Cyan
git rm flowmatik_connector.py
if ($LASTEXITCODE -ne 0) {
    Write-Error "No se pudo eliminar el archivo."
    exit 1
}

# Commit
Write-Host "💾 Creando commit..." -ForegroundColor Cyan
git commit -m "chore: remove deprecated root flowmatik_connector.py after move to autogen/"
if ($LASTEXITCODE -ne 0) {
    Write-Error "No se pudo crear el commit."
    exit 1
}

# Push
Write-Host "📤 Haciendo push..." -ForegroundColor Cyan
git push -u origin $branchName
if ($LASTEXITCODE -ne 0) {
    Write-Error "No se pudo hacer push."
    exit 1
}

Write-Host "✅ Rama creada y pusheada exitosamente." -ForegroundColor Green

# Crear PR si se solicita
if ($AutoCreatePR) {
    if (Get-Command gh -ErrorAction SilentlyContinue) {
        Write-Host "🚀 Creando PR automáticamente..." -ForegroundColor Cyan
        $prBody = @"
Este PR elimina el archivo obsoleto \`flowmatik_connector.py\` de la raíz después de que el conector fue movido a \`autogen/connectors/flowmatik_connector.py\` en el PR anterior.

## Verificaciones
- ✅ PR anterior mergeado
- ✅ No hay referencias residuales críticas
- ✅ Nuevo archivo existe en autogen/connectors/

## Cambios
- Eliminado: \`flowmatik_connector.py\` (raíz)

El archivo original está preservado en el historial de Git.
"@
        
        $prBody | Out-File -FilePath "pr_body_temp.md" -Encoding utf8
        gh pr create `
            --base main `
            --head $branchName `
            --title "chore: remove deprecated root flowmatik_connector.py" `
            --body-file "pr_body_temp.md"
        
        Remove-Item "pr_body_temp.md" -ErrorAction SilentlyContinue
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ PR creado exitosamente." -ForegroundColor Green
        } else {
            Write-Warning "No se pudo crear el PR automáticamente. Créalo manualmente."
        }
    } else {
        Write-Host "⚠️  GitHub CLI (gh) no está instalado. Crea el PR manualmente:" -ForegroundColor Yellow
        Write-Host "   https://github.com/lucianople7/flowmatik-enterprise/pull/new/$branchName" -ForegroundColor Cyan
    }
} else {
    Write-Host ""
    Write-Host "📋 Próximos pasos:" -ForegroundColor Cyan
    Write-Host "   1. Abre el PR en GitHub:" -ForegroundColor White
    Write-Host "      https://github.com/lucianople7/flowmatik-enterprise/pull/new/$branchName" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   2. O usa gh CLI:" -ForegroundColor White
    Write-Host "      gh pr create --base main --head $branchName --title 'chore: remove deprecated root flowmatik_connector.py' --body-file PR_REMOVE_ROOT_CONNECTOR.md" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "✅ Listo!" -ForegroundColor Green

