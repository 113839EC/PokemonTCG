# setup.ps1 — Configuracion del entorno local para Pokemon TCG
# Ejecutar una sola vez despues de clonar el repositorio:
#   powershell -ExecutionPolicy Bypass -File setup.ps1

$ErrorActionPreference = "Continue"

function Write-OK   { param($msg) Write-Host "  [OK] $msg" -ForegroundColor Green }
function Write-FAIL { param($msg) Write-Host  " [FAIL] $msg" -ForegroundColor Red }
function Write-INFO { param($msg) Write-Host  " [INFO] $msg" -ForegroundColor Cyan }
function Write-WARN { param($msg) Write-Host  " [WARN] $msg" -ForegroundColor Yellow }

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   Pokemon TCG — Setup del entorno local   " -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$allGood = $true

# ------------------------------------------------------------
# 1. Verificar Java 23
# ------------------------------------------------------------
Write-Host "Verificando Java..." -ForegroundColor White
try {
    $javaVersion = (java -version 2>&1 | Select-String "version").ToString()
    if ($javaVersion -match '"23') {
        Write-OK "Java 23 encontrado: $javaVersion"
    } elseif ($javaVersion -match '"') {
        Write-WARN "Java encontrado pero no es version 23: $javaVersion"
        Write-WARN "Instalar JDK 23 desde: https://adoptium.net/temurin/releases/?version=23"
        $allGood = $false
    }
} catch {
    Write-FAIL "Java no encontrado. Instalar desde: https://adoptium.net/temurin/releases/?version=23"
    $allGood = $false
}

# ------------------------------------------------------------
# 2. Verificar Maven
# ------------------------------------------------------------
Write-Host "Verificando Maven..." -ForegroundColor White
try {
    $mvnVersion = (mvn -version 2>&1 | Select-Object -First 1).ToString()
    if ($mvnVersion -match "Apache Maven 3\.[9-9]" -or $mvnVersion -match "Apache Maven [4-9]") {
        Write-OK "Maven encontrado: $mvnVersion"
    } else {
        Write-WARN "Maven encontrado pero puede ser antiguo: $mvnVersion"
        Write-WARN "Recomendado Maven 3.9+: https://maven.apache.org/download.cgi"
    }
} catch {
    Write-FAIL "Maven no encontrado. Instalar desde: https://maven.apache.org/download.cgi"
    $allGood = $false
}

# ------------------------------------------------------------
# 3. Verificar Node.js
# ------------------------------------------------------------
Write-Host "Verificando Node.js..." -ForegroundColor White
try {
    $nodeVersion = (node -v 2>&1).ToString().Trim()
    $nodeMajor = [int]($nodeVersion -replace 'v(\d+).*', '$1')
    if ($nodeMajor -ge 20) {
        Write-OK "Node.js encontrado: $nodeVersion"
    } else {
        Write-WARN "Node.js $nodeVersion es antiguo. Se necesita v20+: https://nodejs.org/"
        $allGood = $false
    }
} catch {
    Write-FAIL "Node.js no encontrado. Instalar desde: https://nodejs.org/"
    $allGood = $false
}

# ------------------------------------------------------------
# 4. Verificar PostgreSQL y crear la base de datos
# ------------------------------------------------------------
Write-Host "Verificando PostgreSQL..." -ForegroundColor White
try {
    $psqlVersion = (psql --version 2>&1).ToString()
    Write-OK "PostgreSQL cliente encontrado: $psqlVersion"

    Write-INFO "Intentando crear la base de datos 'pokemon_tcg'..."
    $createDbResult = (psql -U postgres -c "SELECT 1 FROM pg_database WHERE datname='pokemon_tcg'" 2>&1)

    if ($createDbResult -match "1 row") {
        Write-OK "Base de datos 'pokemon_tcg' ya existe"
    } else {
        $result = (psql -U postgres -c "CREATE DATABASE pokemon_tcg;" 2>&1)
        if ($result -match "CREATE DATABASE" -or $result -match "already exists") {
            Write-OK "Base de datos 'pokemon_tcg' creada correctamente"
        } else {
            Write-WARN "No se pudo crear la BD automaticamente. Ejecutar manualmente:"
            Write-WARN "  psql -U postgres -c `"CREATE DATABASE pokemon_tcg;`""
            Write-WARN "Resultado: $result"
        }
    }
} catch {
    Write-FAIL "PostgreSQL no encontrado o no accesible. Instalar desde: https://www.postgresql.org/download/"
    Write-WARN "Despues de instalar, ejecutar: psql -U postgres -c `"CREATE DATABASE pokemon_tcg;`""
    $allGood = $false
}

# ------------------------------------------------------------
# 5. Crear .mcp.json desde el template si no existe
# ------------------------------------------------------------
Write-Host "Configurando .mcp.json..." -ForegroundColor White
$mcpTarget = Join-Path $PSScriptRoot ".mcp.json"
$mcpExample = Join-Path $PSScriptRoot "mcp.example.json"

if (Test-Path $mcpTarget) {
    Write-OK ".mcp.json ya existe — no se sobreescribe"
} elseif (Test-Path $mcpExample) {
    Copy-Item $mcpExample $mcpTarget
    Write-OK ".mcp.json creado desde mcp.example.json"
    Write-WARN "IMPORTANTE: Editar .mcp.json y reemplazar:"
    Write-WARN "  - TU_EMAIL@ejemplo.com  con tu email de Atlassian"
    Write-WARN "  - TU_TOKEN_DE_JIRA  con tu API token de https://id.atlassian.com/manage-profile/security/api-tokens"
} else {
    Write-WARN "mcp.example.json no encontrado. Crear .mcp.json manualmente segun el README."
}

# ------------------------------------------------------------
# 6. Verificar variable GITHUB_PERSONAL_ACCESS_TOKEN
# ------------------------------------------------------------
Write-Host "Verificando variables de entorno..." -ForegroundColor White
$ghToken = [System.Environment]::GetEnvironmentVariable("GITHUB_PERSONAL_ACCESS_TOKEN", "User")
if ($ghToken -and $ghToken.Length -gt 10) {
    Write-OK "GITHUB_PERSONAL_ACCESS_TOKEN configurado"
} else {
    Write-WARN "GITHUB_PERSONAL_ACCESS_TOKEN no configurado."
    Write-WARN "Obtener en: GitHub -> Settings -> Developer settings -> Personal access tokens"
    $token = Read-Host "  Pegar token de GitHub (Enter para omitir)"
    if ($token.Trim() -ne "") {
        [System.Environment]::SetEnvironmentVariable("GITHUB_PERSONAL_ACCESS_TOKEN", $token.Trim(), "User")
        Write-OK "GITHUB_PERSONAL_ACCESS_TOKEN guardado como variable de usuario"
    } else {
        Write-WARN "Omitido. Configurar manualmente antes de usar el MCP de GitHub."
    }
}

# ------------------------------------------------------------
# 7. Verificar variable DATABASE_URL
# ------------------------------------------------------------
$dbUrl = [System.Environment]::GetEnvironmentVariable("DATABASE_URL", "User")
if ($dbUrl -and $dbUrl.StartsWith("postgresql://")) {
    Write-OK "DATABASE_URL configurado: $($dbUrl.Substring(0, [Math]::Min(30, $dbUrl.Length)))..."
} else {
    Write-WARN "DATABASE_URL no configurado."
    $dbPass = Read-Host "  Contrasena de PostgreSQL (usuario 'postgres') — Enter para usar sin contrasena"
    if ($dbPass.Trim() -ne "") {
        $url = "postgresql://postgres:$($dbPass.Trim())@localhost:5432/pokemon_tcg"
    } else {
        $url = "postgresql://postgres@localhost:5432/pokemon_tcg"
    }
    [System.Environment]::SetEnvironmentVariable("DATABASE_URL", $url, "User")
    Write-OK "DATABASE_URL guardado: $url"
}

# ------------------------------------------------------------
# 8. Verificar Claude Code CLI
# ------------------------------------------------------------
Write-Host "Verificando Claude Code..." -ForegroundColor White
try {
    $claudeVersion = (claude --version 2>&1).ToString()
    Write-OK "Claude Code encontrado: $claudeVersion"
} catch {
    Write-WARN "Claude Code no encontrado. Instalar con: npm install -g @anthropic-ai/claude-code"
    Write-WARN "Luego ejecutar 'claude' para hacer login."
}

# ------------------------------------------------------------
# Resumen final
# ------------------------------------------------------------
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
if ($allGood) {
    Write-Host "  Setup completo. Podes empezar con:" -ForegroundColor Green
    Write-Host "    mvn clean compile" -ForegroundColor White
    Write-Host "    claude" -ForegroundColor White
} else {
    Write-Host "  Hay dependencias faltantes (ver FAIL arriba)." -ForegroundColor Yellow
    Write-Host "  Instalar lo que falta y volver a ejecutar setup.ps1" -ForegroundColor Yellow
}
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "IMPORTANTE: Cerrar y reabrir la terminal para que" -ForegroundColor Yellow
Write-Host "las variables de entorno surtan efecto." -ForegroundColor Yellow
Write-Host ""
