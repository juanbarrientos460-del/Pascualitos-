# Desnormalización intencional: decisiones y justificación

El esquema está en 3FN/BCNF salvo las tres decisiones de esta página. Cada una se tomó por una razón de datos concreta, tiene un mecanismo que la base de datos usa para impedir incoherencias, y se puede probar con un caso de prueba.

## 1. Criterio aplicado

Un atributo redundante solo se acepta si cumple **las tres condiciones**:

1. **Razón de negocio o de datos** que la normalización pura no resuelve (un dato opcional o un valor histórico), y no una simple comodidad en las consultas.
2. **Consistencia garantizada por la base de datos** (FK compuesta o CHECK), de modo que la redundancia no pueda contradecirse.
3. **Documentada y probada** (esta página y `06_pruebas_restricciones.sql`).

---

## 2. Decisiones aceptadas

### D1. `PARO.codigo` junto a `PARO.subcodigo_id`

| Aspecto | Detalle |
|---|---|
| **Qué viola** | 3FN: `subcodigo_id → codigo` (cada subcódigo pertenece a un solo código), pero `subcodigo_id` no es llave de `PARO`. |
| **Diseño totalmente normalizado** | `PARO` solo guardaría `subcodigo_id`, y el código se obtendría con un JOIN a `SUBCODIGO_PARO`. |
| **Por qué no funciona aquí** | Muchos paros **no tienen subcódigo** (el "(en blanco)" de los gráficos del P-MTO-22). Sin subcódigo no hay de dónde deducir el código, y el paro quedaría sin causa. |
| **Alternativa descartada** | Crear un subcódigo "sin especificar" para cada uno de los 18 códigos. Contamina el catálogo, cambia el significado de "(en blanco)" que usa el negocio, y exige que todo código admita subcódigo. |
| **Beneficio adicional** | La consulta más frecuente (participación por código) agrupa directamente por `PARO.codigo`, sin JOIN. |
| **Control** | FK compuesta `(codigo, subcodigo_id) → SUBCODIGO_PARO(codigo, subcodigo_id)`, que exige un `UNIQUE (codigo, subcodigo_id)` en `SUBCODIGO_PARO`. Cuando `subcodigo_id` es NULL la FK compuesta no se evalúa, y `codigo` sigue protegido por su propia FK a `CODIGO_PARO`. |
| **Riesgo residual** | Ninguno de coherencia: la base rechaza un subcódigo que no corresponde al código. |

```sql
ALTER TABLE subcodigo_paro
  ADD CONSTRAINT uq_subcodigo_codigo UNIQUE (codigo, subcodigo_id);

ALTER TABLE paro
  ADD CONSTRAINT fk_paro_subcodigo
  FOREIGN KEY (codigo, subcodigo_id)
  REFERENCES subcodigo_paro (codigo, subcodigo_id);
```

### D2. `PARO.ejecutor_tipo` junto a `PARO.persona_id`

| Aspecto | Detalle |
|---|---|
| **Qué viola** | 3FN: `persona_id → rol`, y `ejecutor_tipo` equivale al rol cuando hay persona. |
| **Diseño totalmente normalizado** | Solo `persona_id`, con el tipo deducido de `PERSONA.rol`. |
| **Por qué no funciona aquí** | El Excel registra el tipo (operarios / personal de mantenimiento / en blanco) **sin necesidad de un nombre**. En los gráficos del código 05 hay paros con tipo conocido y persona desconocida. |
| **Control** | FK compuesta `(persona_id, ejecutor_tipo) → PERSONA(persona_id, rol)` más un CHECK que obliga a informar el tipo cuando hay persona. |
| **Riesgo residual** | Ninguno de coherencia. |
| **Condición de revisión** | ⚠️ Si al revisar el Excel real se comprueba que **nunca** hay nombre del ejecutor, se elimina `persona_id` de `PARO` y esta desviación desaparece. |

```sql
ALTER TABLE persona
  ADD CONSTRAINT uq_persona_rol UNIQUE (persona_id, rol);

ALTER TABLE paro
  ADD CONSTRAINT fk_paro_persona_rol
  FOREIGN KEY (persona_id, ejecutor_tipo)
  REFERENCES persona (persona_id, rol),
  ADD CONSTRAINT ck_paro_ejecutor
  CHECK (persona_id IS NULL OR ejecutor_tipo IS NOT NULL);
```

### D3. `REGISTRO_PRODUCCION.meta_por_hora`

| Aspecto | Detalle |
|---|---|
| **Qué viola** | 3FN/BCNF en sentido lógico: la meta parece depender de (máquina, referencia), no del registro. |
| **Diseño totalmente normalizado** | Una tabla `META(maquina, referencia, meta_por_hora)` y un JOIN para obtenerla. |
| **Por qué no funciona aquí** | La meta es un **valor histórico**. Si en 2025 cambia la meta de una referencia, los indicadores de 2024 no deben recalcularse con la meta nueva. Una tabla de metas sin vigencia lo haría; con vigencia (fecha de inicio y fin) se vuelve más compleja que el problema. |
| **Control** | `CHECK (meta_por_hora > 0)`; el valor se guarda tal como se registró en el formato "hora a hora". |
| **Riesgo residual** | Dos registros de la misma máquina y referencia pueden tener metas distintas. Eso es **correcto**: refleja que la meta cambió. |

```sql
ALTER TABLE registro_produccion
  ADD CONSTRAINT ck_meta_positiva CHECK (meta_por_hora > 0);
```

---

## 3. Estructura derivada opcional (no es una tabla base)

| Elemento | Cuándo se usa | Control |
|---|---|---|
| Vista materializada `mv_productividad_mensual` (máquina, año, mes, productividad) | Solo si la consulta mensual tarda demasiado con el volumen real | Se refresca después de cada carga con `REFRESH MATERIALIZED VIEW`. No se escribe a mano, así que no puede divergir de las tablas base |

Se documenta como opcional porque con el volumen del Excel (cuatro máquinas, datos de 2024 y parte de 2025) una vista normal debería bastar.

---

## 4. Desnormalizaciones consideradas y rechazadas

| Candidato | Por qué se rechazó |
|---|---|
| Guardar `% productividad` en el registro | Se calcula desde los paros y las horas; guardarlo permite que no coincida con ellos. Es el indicador que ve la alta dirección |
| Guardar `mes` y `año` | `EXTRACT` es barato y un índice sobre `fecha` sirve para filtros por rango |
| Guardar el total de minutos de paro en `REGISTRO_PRODUCCION` | Quedaría desactualizado al modificar o borrar paros; se obtiene con `SUM` en una vista |
| Guardar la descripción del código en `PARO` | Reintroduce la dependencia parcial y el problema de nombres distintos del código 10 |
| Guardar el nombre de máquina o referencia en el registro | Reintroduce los alias ("Maq #2", "Vinilos_2") |
| Subcódigo "sin especificar" por cada código | Ver D1 |

---

## 5. Pruebas que evidencian los controles

Estos casos van en `sql/06_pruebas_restricciones.sql`, cada uno con el error esperado (aquí se muestra el de PostgreSQL).

```sql
-- P1 (D1): subcódigo 3.2 asignado a un paro de código 01 -> RECHAZADO
-- Error esperado: 23503 foreign_key_violation (fk_paro_subcodigo)
INSERT INTO paro (registro_id, codigo, subcodigo_id, minutos)
VALUES (1, 1, /* id del subcódigo 3.2 */ 20, 15);

-- P2 (D1): paro con código y sin subcódigo -> ACEPTADO
INSERT INTO paro (registro_id, codigo, subcodigo_id, minutos)
VALUES (1, 16, NULL, 10);

-- P3 (D2): persona de MANTENIMIENTO registrada como ejecutor OPERARIO -> RECHAZADO
-- Error esperado: 23503 foreign_key_violation (fk_paro_persona_rol)
INSERT INTO paro (registro_id, codigo, minutos, persona_id, ejecutor_tipo)
VALUES (1, 5, 10, /* id de una persona de mantenimiento */ 7, 'OPERARIO');

-- P4 (D2): persona sin tipo informado -> RECHAZADO
-- Error esperado: 23514 check_violation (ck_paro_ejecutor)
INSERT INTO paro (registro_id, codigo, minutos, persona_id)
VALUES (1, 5, 10, 7);

-- P5 (D3): meta no positiva -> RECHAZADO
-- Error esperado: 23514 check_violation (ck_meta_positiva)
UPDATE registro_produccion SET meta_por_hora = 0 WHERE registro_id = 1;
```

---

## 6. Resumen para el PDF

| ID | Columna | Dependencia | Justificación breve | Control |
|---|---|---|---|---|
| D1 | `paro.codigo` | `subcodigo_id → codigo` | El subcódigo es opcional; sin él no se puede deducir el código | FK compuesta |
| D2 | `paro.ejecutor_tipo` | `persona_id → rol` | El Excel registra el tipo sin nombre | FK compuesta + CHECK |
| D3 | `registro_produccion.meta_por_hora` | (máquina, referencia) → meta | Valor histórico que no debe cambiar retroactivamente | CHECK |

**Mensaje clave para la sustentación:** no se desnormalizó por rendimiento ni por comodidad, sino porque la normalización pura pierde información (subcódigo opcional, tipo sin nombre, meta histórica). En los tres casos la base de datos impide que la redundancia se contradiga.
