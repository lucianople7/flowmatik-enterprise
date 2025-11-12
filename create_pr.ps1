# Script para crear el PR automáticamente
# Uso: .\create_pr.ps1

$ErrorActionPreference = "Stop"

Write-Host "🚀 Creando PR para flowmatik_connector..." -ForegroundColor Cyan

# Verificar que estamos en el directorio correcto
if (-not (Test-Path "flowmatik_connector.py")) {
    Write-Host "❌ Error: No se encuentra flowmatik_connector.py" -ForegroundColor Red
    Write-Host "   Ejecuta este script desde el directorio flowmatik-enterprise" -ForegroundColor Yellow
    exit 1
}

# Verificar que git está disponible
try {
    git --version | Out-Null
} catch {
    Write-Host "❌ Error: git no está disponible" -ForegroundColor Red
    exit 1
}

# Verificar que estamos en un repo git
if (-not (Test-Path ".git")) {
    Write-Host "❌ Error: No es un repositorio git" -ForegroundColor Red
    exit 1
}

# Paso 1: Asegurarse en main y actualizar
Write-Host "`n📥 Actualizando main..." -ForegroundColor Yellow
try {
    git checkout main
    git pull origin main
} catch {
    Write-Host "⚠️  Advertencia: No se pudo actualizar main (puede ser normal si no hay cambios)" -ForegroundColor Yellow
}

# Paso 2: Crear rama
$branchName = "fix/connector-fallback-timeout-logging"
Write-Host "`n🌿 Creando rama: $branchName..." -ForegroundColor Yellow

# Verificar si la rama ya existe
$existingBranch = git branch --list $branchName
if ($existingBranch) {
    Write-Host "⚠️  La rama $branchName ya existe. Cambiando a ella..." -ForegroundColor Yellow
    git checkout $branchName
} else {
    git checkout -b $branchName
}

# Paso 3: Añadir archivos
Write-Host "`n📝 Añadiendo archivos..." -ForegroundColor Yellow

# Verificar si flowmatik_connector.py tiene cambios
$connectorStatus = git status --porcelain flowmatik_connector.py
if ($connectorStatus) {
    git add flowmatik_connector.py
    Write-Host "   ✅ flowmatik_connector.py añadido" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  flowmatik_connector.py no tiene cambios" -ForegroundColor Yellow
}

# Verificar si README_CONNECTOR.md existe y tiene cambios
if (Test-Path "README_CONNECTOR.md") {
    $readmeStatus = git status --porcelain README_CONNECTOR.md
    if ($readmeStatus) {
        git add README_CONNECTOR.md
        Write-Host "   ✅ README_CONNECTOR.md añadido" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  README_CONNECTOR.md no tiene cambios" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ⚠️  README_CONNECTOR.md no existe" -ForegroundColor Yellow
}

# Paso 4: Commit
Write-Host "`n💾 Creando commit..." -ForegroundColor Yellow
$commitMessage = "fix(connector): fallback integrado, timeout y logging estructurado"
git commit -m $commitMessage

# Paso 5: Push
Write-Host "`n📤 Subiendo rama..." -ForegroundColor Yellow
try {
    git push -u origin $branchName
    Write-Host "   ✅ Rama subida exitosamente" -ForegroundColor Green
} catch {
    Write-Host "❌ Error al subir la rama: $_" -ForegroundColor Red
    Write-Host "`n💡 Puedes subirla manualmente con:" -ForegroundColor Yellow
    Write-Host "   git push -u origin $branchName" -ForegroundColor Cyan
    exit 1
}

# Paso 6: Crear PR con gh CLI (si está disponible)
Write-Host "`n🔗 Creando Pull Request..." -ForegroundColor Yellow
try {
    if (Get-Command gh -ErrorAction SilentlyContinue) {
        if (Test-Path "PR_BODY.md") {
            gh pr create --base main --title "fix(connector): fallback, timeout, structured logging and validations" --body-file PR_BODY.md
            Write-Host "   ✅ PR creado exitosamente" -ForegroundColor Green
        } else {
            gh pr create --base main --title "fix(connector): fallback, timeout, structured logging and validations" --body "Ver PR_BODY.md para detalles"
            Write-Host "   ✅ PR creado (sin body file)" -ForegroundColor Green
        }
    } else {
        Write-Host "   ⚠️  GitHub CLI (gh) no está instalado" -ForegroundColor Yellow
        Write-Host "`n💡 Abre el PR manualmente en GitHub:" -ForegroundColor Yellow
        Write-Host "   https://github.com/lucianople7/flowmatik-enterprise/compare/main...$branchName" -ForegroundColor Cyan
        Write-Host "`n   O usa el contenido de PR_BODY.md para la descripción del PR" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ⚠️  No se pudo crear el PR automáticamente" -ForegroundColor Yellow
    Write-Host "`n💡 Abre el PR manualmente:" -ForegroundColor Yellow
    Write-Host "   https://github.com/lucianople7/flowmatik-enterprise/compare/main...$branchName" -ForegroundColor Cyan
}

Write-Host "`n✅ Proceso completado!" -ForegroundColor Green
Write-Host "`n📋 Resumen:" -ForegroundColor Cyan
Write-Host "   - Rama: $branchName" -ForegroundColor White
Write-Host "   - Commit: $commitMessage" -ForegroundColor White
Write-Host "   - Archivos: flowmatik_connector.py, README_CONNECTOR.md" -ForegroundColor White

