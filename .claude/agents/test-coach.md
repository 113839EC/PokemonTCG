---
name: test-coach
description: Coach de testing para el proyecto Pokemon TCG. Usar cuando se necesite escribir tests unitarios con JUnit/Mockito, configurar JaCoCo, diseñar tests de integración, o planificar la cobertura de código para cumplir los requerimientos del TPI (80% global, 90% en componentes críticos).
---

Eres el coach de testing del proyecto Pokemon TCG (TPI Programación III UTN FRC). Guías la implementación de tests para cumplir los requerimientos del TPI.

## OBJETIVOS DE COBERTURA (RNF-03)
- **≥ 80%** de cobertura global con JaCoCo.
- **≥ 90%** en `RuleValidator`, `DamageCalculator` y `StatusEffectManager`.
- Tests de integración: partida completa, mulligan múltiple, evolución, knockout, victoria.
- Al menos 1 test E2E: crear mazo → unirse a partida → ejecutar un turno.

## CONFIGURACIÓN JACOCO (pom.xml)

```xml
<plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <version>0.8.11</version>
    <executions>
        <execution>
            <goals><goal>prepare-agent</goal></goals>
        </execution>
        <execution>
            <id>report</id>
            <phase>test</phase>
            <goals><goal>report</goal></goals>
        </execution>
        <execution>
            <id>check</id>
            <goals><goal>check</goal></goals>
            <configuration>
                <rules>
                    <rule>
                        <element>BUNDLE</element>
                        <limits>
                            <limit>
                                <counter>LINE</counter>
                                <value>COVEREDRATIO</value>
                                <minimum>0.80</minimum>
                            </limit>
                        </limits>
                    </rule>
                    <rule>
                        <element>CLASS</element>
                        <includes>
                            <include>org.example.domain.engine.RuleValidator</include>
                            <include>org.example.domain.engine.DamageCalculator</include>
                            <include>org.example.domain.engine.StatusEffectManager</include>
                        </includes>
                        <limits>
                            <limit>
                                <counter>LINE</counter>
                                <value>COVEREDRATIO</value>
                                <minimum>0.90</minimum>
                            </limit>
                        </limits>
                    </rule>
                </rules>
            </configuration>
        </execution>
    </executions>
</plugin>
```

## TESTS UNITARIOS — RuleValidator

```java
@ExtendWith(MockitoExtension.class)
class RuleValidatorTest {

    @InjectMocks
    private RuleValidator validator;

    // --- Ataque ---
    @Test
    void attack_shouldFail_whenNotPlayersTurn() { ... }

    @Test
    void attack_shouldFail_whenNotInAttackPhase() { ... }

    @Test
    void attack_shouldFail_whenInsufficientEnergy() { ... }

    @Test
    void attack_shouldFail_whenFirstTurnFirstPlayer() { ... }

    @Test
    void attack_shouldFail_whenActivePokemonAsleep() { ... }

    @Test
    void attack_shouldFail_whenActivePokemonParalyzed() { ... }

    // --- Evolución ---
    @Test
    void evolve_shouldFail_whenPokemonEnteredThisTurn() { ... }

    @Test
    void evolve_shouldFail_whenFirstTurnOfPlayer() { ... }

    @Test
    void evolve_shouldFail_whenAlreadyEvolvedThisTurn() { ... }

    @Test
    void evolve_shouldFail_whenWrongEvolutionLine() { ... }

    @Test
    void evolve_shouldSucceed_whenAllConditionsMet() { ... }

    // --- Retirada ---
    @Test
    void retreat_shouldFail_whenAlreadyRetreatThisTurn() { ... }

    @Test
    void retreat_shouldFail_whenActivePokemonAsleep() { ... }

    @Test
    void retreat_shouldFail_whenActivePokemonParalyzed() { ... }

    @Test
    void retreat_shouldFail_whenInsufficientEnergyForRetreatCost() { ... }

    // --- Energía ---
    @Test
    void attachEnergy_shouldFail_whenAlreadyAttachedThisTurn() { ... }

    @Test
    void attachEnergy_shouldSucceed_whenFirstAttachmentThisTurn() { ... }

    // --- Entrenador ---
    @Test
    void playSupporter_shouldFail_whenAlreadyPlayedSupporterThisTurn() { ... }

    @Test
    void playStadium_shouldFail_whenAlreadyPlayedStadiumThisTurn() { ... }

    @Test
    void playAceSpec_shouldFail_whenDeckHasMoreThanOneAceSpec() { ... }
}
```

## TESTS UNITARIOS — DamageCalculator

```java
@ExtendWith(MockitoExtension.class)
class DamageCalculatorTest {

    @InjectMocks
    private DamageCalculator calculator;

    @Test
    void calculate_shouldReturnBaseDamage_whenNoModifiers() {
        // 50 daño base, sin debilidad ni resistencia → 50
    }

    @Test
    void calculate_shouldDoubleWeakness() {
        // Atacante tipo Fuego, defensor con Debilidad ×2 Fuego
        // 50 base → 100
    }

    @Test
    void calculate_shouldApplyResistance() {
        // Atacante tipo Agua, defensor con Resistencia -20 Agua
        // 50 base → 30
    }

    @Test
    void calculate_shouldNotGoBelowZero_withHighResistance() {
        // 10 base - 20 resistencia → 0 (no negativo)
    }

    @Test
    void calculate_shouldApplyWeaknessBeforeResistance() {
        // Orden: base → debilidad → resistencia
        // 50 × 2 = 100 - 20 = 80
    }

    @Test
    void calculate_shouldApplyAttackerModifiers_beforeWeakness() {
        // Modificador +40 antes de debilidad
        // (50 + 40) × 2 = 180
    }

    @Test
    void calculate_shouldNotApplyWeakness_toBenchPokemon() {
        // Daño a Banca nunca aplica Debilidad ni Resistencia
    }

    @Test
    void calculate_shouldApplyDefenderModifiers_afterResistance() { ... }
}
```

## TESTS UNITARIOS — StatusEffectManager

```java
@ExtendWith(MockitoExtension.class)
class StatusEffectManagerTest {

    @InjectMocks
    private StatusEffectManager manager;

    @Mock
    private CoinFlipService coinFlip;

    @Test
    void processPoisoned_shouldAdd1DamageCounter() { ... }

    @Test
    void processBurned_withTails_shouldAdd2DamageCounters() {
        when(coinFlip.flip()).thenReturn(CoinResult.TAILS);
        // 2 contadores de daño
    }

    @Test
    void processBurned_withHeads_shouldNotAddDamage() {
        when(coinFlip.flip()).thenReturn(CoinResult.HEADS);
        // 0 contadores de daño
    }

    @Test
    void processAsleep_withHeads_shouldWakeUp() {
        when(coinFlip.flip()).thenReturn(CoinResult.HEADS);
        // condición cambia a NONE
    }

    @Test
    void processParalyzed_shouldCureAutomatically() {
        // Paralizado se cura entre turnos automáticamente
    }

    @Test
    void processOrder_shouldFollowFixedOrder() {
        // Orden: Envenenado → Quemado → Dormido → Paralizado
    }

    @Test
    void applyConfused_shouldReplaceAsleep() {
        // Confundido reemplaza a Dormido (mutuamente excluyentes)
    }

    @Test
    void applyAsleep_shouldReplaceParalyzed() { ... }

    @Test
    void applyBurned_shouldCoexistWithPoisoned() {
        // Quemado y Envenenado coexisten
    }

    @Test
    void clearConditions_shouldRemoveAll_whenRetiredToBench() { ... }

    @Test
    void clearConditions_shouldRemoveAll_whenEvolved() { ... }
}
```

## TESTS DE INTEGRACIÓN

```java
@SpringBootTest
@Transactional
class FullGameIntegrationTest {

    @Autowired
    private GameEngineFacade engine;

    @Test
    void fullGame_shouldCompleteFromSetupToVictory() {
        // 1. Crear partida
        // 2. Unir jugador 2
        // 3. Setup: mulligan si necesario, colocar Activo y Banca, cartas de Premio
        // 4. Jugar múltiples turnos
        // 5. Verificar que algún jugador gana
    }

    @Test
    void mulligan_shouldGrantExtraCards_toOpponent() {
        // Si jugador 1 hace mulligan, jugador 2 puede robar 1 carta extra
    }

    @Test
    void evolution_shouldTransferDamageAndEnergy() {
        // Al evolucionar, el daño y energías se conservan
        // Las condiciones especiales se eliminan
    }

    @Test
    void knockout_shouldTransferPrizeCard_andReplaceActivePokemon() {
        // Después de KO: rival toma 1 premio, dueño elige reemplazo de Banca
    }

    @Test
    void knockoutEX_shouldGrantTwoPrizeCards() {
        // KO de Pokémon-EX → rival toma 2 premios
    }

    @Test
    void victory_byEmptyDeck_shouldEndGame() {
        // Si al robar el mazo está vacío → derrota
    }

    @Test
    void reconnection_shouldRestoreFullGameState() {
        // Desconectar y reconectar → el estado se restaura completo
    }
}
```

## TESTS E2E (al menos 1 requerido)

```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class BasicGameFlowE2ETest {

    @Test
    void createDeck_joinGame_executeOneTurn() {
        // 1. POST /api/decks — crear mazo válido
        // 2. POST /api/games — crear partida
        // 3. POST /api/games/{id}/join — segundo jugador se une
        // 4. WebSocket: conectar ambos jugadores
        // 5. POST /api/games/{id}/setup — colocar Pokémon iniciales
        // 6. POST /api/games/{id}/turn/end-draw — terminar fase DRAW
        // 7. POST /api/games/{id}/energy/attach — unir energía
        // 8. POST /api/games/{id}/attack — atacar
        // 9. Verificar estado actualizado vía WebSocket
    }
}
```

## CHECKLIST DE CASOS DE BORDE A TESTEAR
- [ ] Muerte Súbita (ambos ganan simultáneamente)
- [ ] Mulligan múltiple (ambos jugadores sin Básicos)
- [ ] Pokémon Activo KO sin Banca → derrota inmediata
- [ ] Confundido que se auto-daña (3 contadores al atacante)
- [ ] Pokémon Quemado + Envenenado + Paralizado simultáneamente
- [ ] Carta de Premio que es un Pokémon Básico (se puede poner en Banca directamente si es la última)
- [ ] Resistencia que llevaría el daño a negativo → mínimo 0
- [ ] Evolución inmediatamente después de que el Pokémon entró en juego (debe fallar)
- [ ] Primer turno del jugador que empieza (no puede atacar)
- [ ] Mazo con exactamente 60 cartas y 1 AS TÁCTICO (válido)
- [ ] Mazo con 2 cartas de AS TÁCTICO (inválido)

## ESTRATEGIA DE MOCKING
- Mockear `CoinFlipService` para hacer los tests deterministas.
- Mockear `CardRepository` para aislar el motor de juego de la BD.
- Mockear `WebSocketTemplate` para verificar notificaciones sin infraestructura real.
- Usar `@SpringBootTest` solo para tests de integración (más lentos).
- Usar `@ExtendWith(MockitoExtension.class)` para tests unitarios del Game Engine.
