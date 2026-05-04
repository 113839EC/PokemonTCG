# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

```bash
mvn clean compile          # compile
mvn package                # build JAR to target/
mvn exec:java -Dexec.mainClass="org.example.Main"  # run
mvn test                   # run tests (none yet)
```

## Project Overview

Maven project targeting **Java 23**. Coordinates: `org.example:Pokemon:1.0-SNAPSHOT`.

Entry point: `src/main/java/org/example/Main.java` — currently a placeholder. All application code lives under the `org.example` package.

No external dependencies are declared in `pom.xml` yet.