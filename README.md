# Pokemon TCG — TPI Programación III UTN FRC

Juego de cartas Pokemon TCG digital con partidas en tiempo real.
**Stack:** Java 23 · Spring Boot 3.x · Angular 21+ · PostgreSQL · WebSockets (STOMP/SockJS)

---

## Requisitos previos

Instalá todo esto antes de clonar el proyecto.

### 1. Java 23 JDK

Descargá e instalá [Eclipse Temurin 23](https://adoptium.net/temurin/releases/?version=23) (recomendado) o cualquier JDK 23.

Verificá que quedó bien:
```
java -version
# debe mostrar: openjdk version "23"
```

### 2. Maven 3.9+

Descargá desde [maven.apache.org](https://maven.apache.org/download.cgi) y seguí la [guía de instalación](https://maven.apache.org/install.html).

Verificá:
```
mvn -version
# debe mostrar: Apache Maven 3.9.x
```

### 3. Node.js 20+

Descargá desde [nodejs.org](https://nodejs.org/). Necesario para los servidores MCP (herramientas de Claude Code).

Verificá:
```
node -v   # v20.x o superior
npm -v    # incluido con Node
```

### 4. PostgreSQL 16+

Descargá e instalá desde [postgresql.org](https://www.postgresql.org/download/).

Durante la instalación:
- Puerto: `5432` (default)
- Usuario superadmin: `postgres`
- Anotá la contraseña que le ponés

Luego creá la base de datos del proyecto. Abrí una terminal y ejecutá:

```
psql -U postgres -c "CREATE DATABASE pokemon_tcg;"
```

Verificá que se creó:
```
psql -U postgres -c "\l" | grep pokemon_tcg
```

### 5. Git

Si no lo tenés: [git-scm.com](https://git-scm.com/downloads)

```
git --version
```

### 6. IntelliJ IDEA (recomendado)

[jetbrains.com/idea](https://www.jetbrains.com/idea/download/) — Community Edition es suficiente.
Configurá el SDK del proyecto apuntando al JDK 23 instalado en el paso 1.

### 7. Claude Code CLI

Necesario para usar los agentes del proyecto (asistentes de IA especializados).

```
npm install -g @anthropic-ai/claude-code
```

Verificá:
```
claude --version
```

Necesitás una cuenta en [claude.ai](https://claude.ai) y seguir el proceso de login con `claude`.

---

## Clonar y configurar el proyecto

### 1. Clonar el repositorio

```
git clone https://github.com/113839EC/PokemonTCG.git
cd PokemonTCG
```

### 2. Verificar que Maven puede compilar

```
mvn clean compile
```

Si falla por versión de Java, asegurate de que `JAVA_HOME` apunta al JDK 23.

### 3. Crear el archivo `.mcp.json` (configuración local de Claude Code)

Este archivo **no está en el repositorio** porque contiene credenciales personales. Cada uno lo crea en la raíz del proyecto.

Creá el archivo `PokemonTCG/.mcp.json` con este contenido (reemplazando los valores):

```json
{
  "mcpServers": {
    "jetbrains": {
      "command": "npx",
      "args": ["-y", "@jetbrains/mcp-proxy"]
    },
    "postgres": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-postgres",
        "postgresql://localhost:5432/pokemon_tcg"
      ]
    },
    "jira": {
      "command": "npx",
      "args": ["-y", "mcp-atlassian"],
      "env": {
        "JIRA_URL": "https://pokemontcg.atlassian.net",
        "JIRA_USERNAME": "TU_EMAIL@ejemplo.com",
        "JIRA_API_TOKEN": "TU_TOKEN_DE_JIRA"
      }
    }
  }
}
```

**Cómo obtener tu token de Jira:**
1. Entrá a [id.atlassian.com/manage-profile/security/api-tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
2. Creá un nuevo token con el nombre "PokemonTCG"
3. Copiá el token y pegalo en el campo `JIRA_API_TOKEN`

### 4. Configurar variables de entorno

El archivo `.claude/settings.json` usa estas variables de entorno para los MCPs de GitHub y PostgreSQL.

**En Windows (PowerShell como administrador, permanente):**
```powershell
[System.Environment]::SetEnvironmentVariable("GITHUB_PERSONAL_ACCESS_TOKEN", "ghp_TU_TOKEN_AQUI", "User")
[System.Environment]::SetEnvironmentVariable("DATABASE_URL", "postgresql://postgres:TU_CONTRASEÑA@localhost:5432/pokemon_tcg", "User")
```

Cerrá y volvé a abrir la terminal para que las variables surtan efecto.

**Cómo obtener tu GitHub Personal Access Token:**
1. GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate new token → clásico
3. Scopes mínimos: `repo`, `read:org`
4. Copiá el token (empieza con `ghp_`)

**Verificar que las variables están:**
```powershell
echo $env:DATABASE_URL
echo $env:GITHUB_PERSONAL_ACCESS_TOKEN
```

---

## Comandos útiles

```bash
# Compilar
mvn clean compile

# Ejecutar tests (cuando haya tests implementados)
mvn test

# Generar reporte de cobertura JaCoCo
mvn verify
# El reporte queda en: target/site/jacoco/index.html

# Construir JAR ejecutable
mvn package

# Ejecutar la app (cuando esté configurado el main)
mvn spring-boot:run
```

---

## Estructura del proyecto

```
PokemonTCG/
├── src/
│   ├── main/java/org/example/
│   │   ├── api/          # Controllers REST + WebSocket
│   │   ├── application/  # Servicios y casos de uso
│   │   ├── domain/       # Game Engine (lógica pura sin Spring)
│   │   ├── infrastructure/ # JPA, repositorios, cliente externo
│   │   └── config/       # Configuración Spring (WebSocket, Security)
│   └── main/resources/
│       └── db/migration/ # Migraciones Flyway (V1 a V6)
├── .claude/
│   └── agents/           # Agentes de IA especializados por dominio
├── .mcp.json             # NO en git — configuración local de MCPs
├── pom.xml
└── README.md
```

---

## Agentes de Claude Code

El proyecto incluye agentes especializados en `.claude/agents/`. Cuando abrís el proyecto con `claude` en la terminal, estos agentes se activan automáticamente según el contexto.

| Agente | Cuándo se usa |
|---|---|
| `pokemon-rules` | Reglamento XY1, mecánicas del juego |
| `backend-architect` | Spring Boot, Game Engine, patrones de diseño |
| `db-designer` | Esquema PostgreSQL, migraciones Flyway |
| `test-coach` | JUnit, Mockito, JaCoCo, cobertura de tests |
| `frontend-dev` | Angular, WebSocket cliente, tablero de juego |
| `jira-pm` | Issues Jira, GitFlow, planificación |
| `openapi-designer` | Documentación Swagger/OpenAPI |
| `card-cache-sync` | Integración pokemontcg.io v2 |
| `security-reviewer` | Auditoría RNF-05, DTOs seguros |
| `deck-validator` | Validación de mazos, DeckBuilder |
| `agent-builder` | Crear/mejorar agentes |

Para usar Claude Code en el proyecto:
```
cd PokemonTCG
claude
```

---

## Workflow GitFlow

```
main        → código en producción (no pushear directo)
develop     → rama de integración principal
feature/*   → nueva funcionalidad (salir de develop)
release/*   → preparación de entrega
hotfix/*    → correcciones urgentes en producción
```

Formato de branches: `feature/TCG-15-implement-damage-calculator`

---

## Links del proyecto

- **Repo:** https://github.com/113839EC/PokemonTCG
- **Jira:** https://pokemontcg.atlassian.net
- **API de cartas:** https://pokemontcg.io (set xy1, 146 cartas)
- **Documentación Swagger** (cuando esté corriendo): http://localhost:8080/swagger-ui.html
