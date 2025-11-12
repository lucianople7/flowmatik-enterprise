# Comando para Merge del PR

## ⚠️ IMPORTANTE: Ejecutar SOLO cuando CI esté verde

Verifica que todos los checks de CI pasen antes de ejecutar este comando.

## 🔍 Verificaciones Pre-Merge

### 1. Verificar estado de CI
```powershell
# Ver ejecuciones recientes
gh run list --repo lucianople7/flowmatik-enterprise --branch fix/connector-fallback-timeout-logging

# Ver detalles de la última ejecución
gh run view --web
```

### 2. Prueba Local Rápida (opcional pero recomendado)
```powershell
# Test básico del conector
$env:PROCESS_TIMEOUT="60"
'{"tipo_tarea":"monetizacion","prioridad":"alta","contexto_ceo":"Prueba pre-merge"}' | python autogen/connectors/flowmatik_connector.py 2>$null | ConvertFrom-Json | Select-Object estado, modulo_usado

# Verificar que el output tiene estado "exito"
```

### 3. Verificar que estás en la rama correcta
```powershell
git branch --show-current
# Debe mostrar: fix/connector-fallback-timeout-logging
```

## 🚀 Comando de Merge (Squash)

### Opción 1: Merge con squash (recomendado)
```powershell
gh pr merge `
  --repo lucianople7/flowmatik-enterprise `
  --head fix/connector-fallback-timeout-logging `
  --squash `
  --delete-branch `
  --subject "chore(autogen): move connector to autogen and add fallback" `
  --body-file PR_BODY.md
```

### Opción 2: Merge con merge commit (si prefieres mantener historial)
```powershell
gh pr merge `
  --repo lucianople7/flowmatik-enterprise `
  --head fix/connector-fallback-timeout-logging `
  --merge `
  --delete-branch `
  --subject "chore(autogen): move connector to autogen and add fallback" `
  --body-file PR_BODY.md
```

### Opción 3: Merge con rebase (historial lineal)
```powershell
gh pr merge `
  --repo lucianople7/flowmatik-enterprise `
  --head fix/connector-fallback-timeout-logging `
  --rebase `
  --delete-branch `
  --subject "chore(autogen): move connector to autogen and add fallback" `
  --body-file PR_BODY.md
```

## 📋 Después del Merge

### 1. Actualizar main local
```powershell
git checkout main
git pull origin main
```

### 2. Verificar que el merge fue exitoso
```powershell
git log --oneline -5
# Debe mostrar el commit de merge
```

### 3. Crear PR para eliminar archivo raíz (opcional)
```powershell
# Ejecutar el script preparado
.\scripts\remove_root_connector.ps1 -AutoCreatePR
```

## ✅ Checklist Pre-Merge

- [ ] CI está verde (todos los checks pasan)
- [ ] Prueba local del conector funciona
- [ ] Revisión del código completada
- [ ] Breaking changes documentados en PR_BODY.md
- [ ] No hay conflictos con main

## 🎯 Resumen del PR que se va a mergear

**Rama**: `fix/connector-fallback-timeout-logging`  
**Commits**: 9 commits (serán squashed en 1)  
**Archivos**: 
- Estructura `autogen/` completa
- Conector con fallback, timeout y logging
- Scripts y documentación actualizados
- Workflow de CI actualizado

**Breaking Changes**: Sí - archivo movido de raíz a `autogen/connectors/`

---

**Ejecuta el comando cuando CI esté verde** ✅

