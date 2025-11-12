# Referencias Restantes a `flowmatik_connector.py`

## 📋 Resumen de Búsqueda

Se encontraron referencias en varios archivos. Categorizadas por prioridad:

## 🔴 **ALTA PRIORIDAD - Actualizar antes de merge**

### 1. `.github/workflows/test-connector.yml`
**Líneas afectadas:** 7, 11, 36, 40, 46, 50

**Problemas:**
- Path trigger en línea 7 y 11: `'flowmatik_connector.py'` → debería ser `'autogen/connectors/flowmatik_connector.py'`
- 4 invocaciones de Python con path antiguo (líneas 36, 40, 46, 50)

**Acción requerida:**
```yaml
# Cambiar paths trigger:
paths:
  - 'autogen/connectors/flowmatik_connector.py'

# Cambiar invocaciones:
python autogen/connectors/flowmatik_connector.py
```

### 2. `create_pr.ps1`
**Líneas afectadas:** 9, 10

**Problema:**
- Verificación del path antiguo en línea 9: `Test-Path "flowmatik_connector.py"`

**Acción requerida:**
```powershell
# Cambiar verificación:
if (-not (Test-Path "autogen/connectors/flowmatik_connector.py")) {
```

## 🟡 **MEDIA PRIORIDAD - Considerar actualizar**

### 3. `tools/write_autogen_files.ps1`
**Líneas afectadas:** 10, 73, 75, 80

**Estado:** 
- Este script menciona el path pero es para referencias/documentación
- Puede quedar como está ya que es un script generador

**Acción:** Opcional - actualizar comentarios si se desea

### 4. `flowmatik_connector.py` (archivo en raíz)
**Estado:**
- Este es el archivo antiguo que ya no se usa
- **Recomendación:** Eliminarlo o moverlo a `backup_refs/` después del merge

## 🟢 **BAJA PRIORIDAD - Documentación/Histórico**

### 5. `PR_REVIEW.md`
**Estado:** Documentación de revisión, puede quedar como está

### 6. `RESUMEN_COMPLETO_FLOWMATIK_AUTOGEN.md`
**Estado:** Documentación histórica, puede quedar como está

### 7. `backup_refs/`
**Estado:** Backups, no requieren actualización

## ✅ **YA ACTUALIZADOS**

- ✅ `test_connector.ps1`
- ✅ `test_connector_timeout.ps1`
- ✅ `README_CONNECTOR.md`
- ✅ `PR_BODY.md`

## 🎯 **Acciones Recomendadas**

### Antes del merge:
1. **Actualizar `.github/workflows/test-connector.yml`** (crítico para CI)
2. **Actualizar `create_pr.ps1`** (si se sigue usando)

### Después del merge:
3. Considerar eliminar o mover `flowmatik_connector.py` de la raíz
4. Actualizar documentación histórica si es necesario

## 📝 **Comandos para Actualizar**

### Actualizar workflow:
```powershell
# Backup
Copy-Item .github\workflows\test-connector.yml backup_refs\test-connector.yml

# Reemplazar paths
(Get-Content .github\workflows\test-connector.yml -Raw) `
  -replace "'flowmatik_connector.py'", "'autogen/connectors/flowmatik_connector.py'" `
  -replace 'python flowmatik_connector.py', 'python autogen/connectors/flowmatik_connector.py' |
  Set-Content .github\workflows\test-connector.yml -Encoding utf8
```

### Actualizar create_pr.ps1:
```powershell
# Backup
Copy-Item create_pr.ps1 backup_refs\create_pr.ps1

# Reemplazar
(Get-Content create_pr.ps1 -Raw) `
  -replace 'Test-Path "flowmatik_connector.py"', 'Test-Path "autogen/connectors/flowmatik_connector.py"' |
  Set-Content create_pr.ps1 -Encoding utf8
```

