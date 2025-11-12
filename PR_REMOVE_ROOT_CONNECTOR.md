# PR: Eliminar `flowmatik_connector.py` de la raíz

## 📋 Descripción

Este PR elimina el archivo `flowmatik_connector.py` de la raíz del repositorio después de que el conector fue movido a `autogen/connectors/flowmatik_connector.py` en el PR anterior.

## 🎯 Objetivo

- Eliminar el archivo obsoleto `flowmatik_connector.py` de la raíz
- Mantener el repositorio limpio y evitar confusión sobre qué archivo usar
- Completar la migración iniciada en el PR anterior

## ⚠️ Requisitos Previos

**Este PR debe crearse DESPUÉS de que se mergee:**
- `fix/connector-fallback-timeout-logging`

## 📝 Comandos para Crear Este PR

### Paso 1: Asegurar que main está actualizado
```powershell
git checkout main
git pull origin main
```

### Paso 2: Crear rama nueva
```powershell
git checkout -b chore/remove-root-connector
```

### Paso 3: Eliminar el archivo
```powershell
git rm flowmatik_connector.py
```

### Paso 4: Commit
```powershell
git commit -m "chore: remove deprecated root flowmatik_connector.py after move to autogen/"
```

### Paso 5: Push y crear PR
```powershell
git push -u origin chore/remove-root-connector
```

### Paso 6: Crear PR (con gh CLI)
```powershell
gh pr create `
  --base main `
  --head chore/remove-root-connector `
  --title "chore: remove deprecated root flowmatik_connector.py" `
  --body-file PR_REMOVE_ROOT_CONNECTOR.md
```

### Paso 6 (alternativa): Crear PR manualmente
Abrir en el navegador:
```
https://github.com/lucianople7/flowmatik-enterprise/pull/new/chore/remove-root-connector
```

## ✅ Verificaciones

Antes de crear este PR, verificar:

1. ✅ El PR `fix/connector-fallback-timeout-logging` está mergeado en `main`
2. ✅ Todos los scripts y workflows usan `autogen/connectors/flowmatik_connector.py`
3. ✅ No hay referencias activas a `flowmatik_connector.py` en la raíz

## 🔍 Búsqueda de Referencias Residuales

Antes de eliminar, ejecutar:

```powershell
# Buscar referencias al archivo en la raíz
Get-ChildItem -Recurse -File | 
  Select-String -Pattern 'flowmatik_connector\.py' | 
  Where-Object { $_.Path -notmatch 'autogen/connectors|backup_refs|PR_REVIEW|RESUMEN_COMPLETO' } |
  Format-Table Path,LineNumber,Line -AutoSize
```

Si solo aparece en `flowmatik_connector.py` mismo, es seguro eliminarlo.

## 📋 Checklist Pre-Merge

- [ ] PR anterior (`fix/connector-fallback-timeout-logging`) está mergeado
- [ ] Verificación de referencias residuales completada
- [ ] CI pasa correctamente
- [ ] No hay dependencias activas del archivo en la raíz

## 🚀 Notas

- Este es un PR de limpieza post-migración
- No hay cambios funcionales, solo eliminación de archivo obsoleto
- El archivo original está preservado en el historial de Git
- Los backups están en `backup_refs/` si se necesitan

