# Pokemon TCG — TPI Programación III UTN FRC

Juego de cartas Pokemon TCG digital con partidas en tiempo real.
**Stack:** Java 23 · Spring Boot 3.x · Angular 21+ · PostgreSQL · WebSockets (STOMP/SockJS)

---

## Instalación (paso a paso)

### Paso 1 — Instalar las dependencias del sistema

Estas cuatro herramientas requieren instalación manual antes de cualquier otra cosa:

| Herramienta | Versión mínima | Descarga |
|---|---|---|
| Java JDK | 23 | [Eclipse Temurin 23](https://adoptium.net/temurin/releases/?version=23) |
| Maven | 3.9+ | [maven.apache.org](https://maven.apache.org/download.cgi) · [guía](https://maven.apache.org/install.html) |
| Node.js | 20+ | [nodejs.org](https://nodejs.org/) |
| PostgreSQL | 16+ | [postgresql.org](https://www.postgresql.org/download/) |

También necesitás:
- **Git** — [git-scm.com](https://git-scm.com/downloads)
- **IntelliJ IDEA** — [jetbrains.com/idea](https://www.jetbrains.com/idea/download/) (Community Edition alcanza)
- **Claude Code CLI** — `npm install -g @anthropic-ai/claude-code` (necesita cuenta en [claude.ai](https://claude.ai))

Verificá que quedaron bien antes de continuar:
```powershell
java -version   # openjdk version "23"
mvn -version    # Apache Maven 3.9.x
node -v         # v20.x o superior
psql --version  # psql (PostgreSQL) 16.x
```

---

### Paso 2 — Clonar el repositorio

```powershell
git clone https://github.com/113839EC/PokemonTCG.git
cd PokemonTCG
```

---

### Paso 3 — Ejecutar el script de setup

El script verifica las instalaciones, crea la base de datos, copia el template de `.mcp.json`, y configura las variables de entorno interactivamente:

```powershell
powershell -ExecutionPolicy Bypass -File setup.ps1
```

Al terminar el script, **cerrá y volvé a abrir la terminal** para que las variables de entorno surtan efecto.

---

### Paso 4 — Completar `.mcp.json` con tus credenciales

El script ya copió `mcp.example.json` como `.mcp.json`. Solo falta reemplazar tus datos de Jira:

```json
"JIRA_USERNAME": "tu-email@ejemplo.com",
"JIRA_API_TOKEN": "tu-token-aqui"
```

**Cómo obtener tu token de Jira:**
1. Entrá a [id.atlassian.com/manage-profile/security/api-tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
2. Creá un token nuevo con el nombre "PokemonTCG"
3. Copiá el valor y pegalo en el campo `JIRA_API_TOKEN`

**Cómo obtener tu GitHub Personal Access Token** (si el script lo pidió y no lo tenías):
1. GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate new token → scopes mínimos: `repo`, `read:org`
3. El token empieza con `ghp_`

---

### Paso 5 — Verificar que compila

```powershell
mvn clean compile
```

Si falla por versión de Java, asegurate de que `JAVA_HOME` apunta al JDK 23.

---

### Paso 6 — Abrir con Claude Code (opcional pero recomendado)

```powershell
claude
```

Si querés que el agente verifique que todo quedó bien:
```
verificá mi entorno con el agente setup-runner
```

---

## Comandos útiles

```powershell
mvn clean compile          # compilar
mvn test                   # correr tests
mvn verify                 # tests + reporte JaCoCo (en target/site/jacoco/index.html)
mvn package                # construir JAR
mvn spring-boot:run        # ejecutar la app (cuando esté configurado)
```

---

## Estructura del proyecto

```
PokemonTCG/
├── src/
│   ├── main/java/org/example/
│   │   ├── api/              # Controllers REST + WebSocket handlers
│   │   ├── application/      # Servicios y casos de uso
│   │   ├── domain/           # Game Engine (lógica pura sin Spring)
│   │   ├── infrastructure/   # JPA, repositorios, cliente pokemontcg.io
│   │   └── config/           # Configuración Spring (WebSocket, Security)
│   └── main/resources/
│       └── db/migration/     # Migraciones Flyway (V1__...sql a V6__...sql)
├── .claude/
│   └── agents/               # Agentes de IA especializados por dominio
├── .mcp.json                 # NO está en git — credenciales personales
├── mcp.example.json          # Template para crear .mcp.json
├── setup.ps1                 # Script de configuración del entorno local
├── pom.xml
└── README.md
```

---

## Agentes de Claude Code

Los agentes en `.claude/agents/` se activan automáticamente cuando abrís el proyecto con `claude`. Cada uno tiene contexto embebido del dominio que cubre.

| Agente | Cuándo se usa |
|---|---|
| `setup-runner` | Verificar y corregir la configuración del entorno local |
| `pokemon-rules` | Reglamento XY1, mecánicas del juego, validación de lógica |
| `backend-architect` | Spring Boot, Game Engine, patrones de diseño, WebSockets |
| `db-designer` | Esquema PostgreSQL, migraciones Flyway, queries |
| `test-coach` | JUnit, Mockito, JaCoCo, estrategia de cobertura |
| `frontend-dev` | Angular, WebSocket cliente, tablero de juego, drag & drop |
| `jira-pm` | Issues Jira, GitFlow, planificación del TPI |
| `openapi-designer` | Documentación Swagger/OpenAPI (entregable obligatorio) |
| `card-cache-sync` | Integración con pokemontcg.io v2, caché local XY1 |
| `security-reviewer` | Auditoría RNF-05: DTOs seguros, validación en backend |
| `deck-validator` | Validación de mazos (60 cartas, 4 copias, 1 AS TÁCTICO) |
| `agent-builder` | Crear o mejorar agentes del proyecto |

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
- **Swagger UI** (con la app corriendo): http://localhost:8080/swagger-ui.html
- **JaCoCo** (después de `mvn verify`): `target/site/jacoco/index.html`
