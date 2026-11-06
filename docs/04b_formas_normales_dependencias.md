# Qué elimina cada forma normal y por qué

Complemento de `04_normalizacion_evidencia.md` (que contiene los datos de ejemplo paso a paso). Este documento responde de forma directa al requisito: **para cada forma normal, qué dependencia o anomalía se elimina y por qué.**

## 1. Resumen

| Forma normal | Condición que exige | Dependencia o anomalía que se elimina | Por qué importa en este negocio |
|---|---|---|---|
| **1FN** | Valores atómicos, sin grupos repetitivos | Grupo repetitivo `Código1…Código18` y `Subcódigo1/3/5`; valores compuestos ("8 hrs", "6am-2pm (Turno 1)") | Un código nuevo obligaba a modificar la estructura; no se podía sumar ni filtrar por tipo de dato |
| **2FN** | Sin dependencias parciales de la llave | `código → descripción`, `subcódigo → descripción`, `referencia → presentación`, `turno → horario`, y (máquina, fecha, turno, referencia) → datos de producción | La producción se repetía en cada paro e inflaba las sumas; renombrar un código exigía editar miles de filas |
| **3FN** | Sin dependencias transitivas | `registro → operaria → rol/nombre`; atributos calculables (horas sin trabajar, tiempo faltante, % productividad, tipo de paro, mes y año) | Nombres de personas escritos de varias formas; indicadores almacenados que pueden contradecir los paros reales |
| **BCNF** | Todo determinante es llave candidata | No requirió descomponer más; se verificó tabla por tabla | Garantiza que las llaves únicas alternativas (nombre de máquina, descripción de código) no generen anomalías |

---

## 2. Primera forma normal (1FN)

**Violaciones en el Excel**

1. Grupo repetitivo: 18 columnas de código y 3 de subcódigo para un mismo concepto (el paro).
2. Valores no atómicos: "8 hrs", "47 pacas", "6am-2pm (Turno 1)", "[19] No aplica".

**Anomalías que causaban**

- *Inserción:* agregar el código 19 exige añadir una columna.
- *Redundancia:* en cada fila, la mayoría de las 18 celdas de código contienen 0.
- *Pérdida de información:* con un solo `Subcódigo5` no se pueden guardar dos paros 05 distintos en el mismo registro.

**Qué se hizo y por qué**

- Una **fila por paro** (`codigo`, `minutos`), porque el paro es el hecho que se mide y no una columna.
- `subcodigo` como atributo del paro, porque el "1/3/5" solo indicaba a qué código pertenecía.
- Valores numéricos limpios, porque así se pueden sumar y restringir con CHECK.

---

## 3. Segunda forma normal (2FN)

Aplica cuando la llave es compuesta: cada atributo debe depender de **toda** la llave.

| Dependencia parcial | Anomalía que causa | Se elimina con |
|---|---|---|
| (máquina, fecha, turno, referencia) → operaria, horas, meta, pacas | Con 3 paros, las pacas aparecen 3 veces; `SUM(pacas)` da 943 en lugar de 574 en el ejemplo | `REGISTRO_PRODUCCION` |
| código → descripción | Cambiar el nombre del código 10 exige editar muchas filas; ya hay dos nombres distintos del código 10 | `CODIGO_PARO` |
| (código, subcódigo) → descripción | No se puede crear un subcódigo sin un paro que lo use | `SUBCODIGO_PARO` |
| referencia → unidades por display, display por paca | Presentación del producto repetida en cada paro | `REFERENCIA` |
| turno → hora de inicio, hora de fin | Horario escrito de formas distintas | `TURNO` |
| fecha → día, mes, año | Atributos derivados guardados | Se eliminan; se calculan con `EXTRACT` |

**Por qué:** una dependencia parcial significa que el mismo dato se guarda varias veces, y cada copia puede quedar distinta. Separarlo deja cada hecho en un único lugar.

---

## 4. Tercera forma normal (3FN)

Un atributo no clave no puede depender de otro atributo no clave.

| Dependencia transitiva | Anomalía que causa | Se elimina con |
|---|---|---|
| registro → operaria → rol, nombre | "Natalia P." y "Natalia Pérez" cuentan como personas distintas; el rol se repite | `PERSONA` |
| Varias líderes por hoja | Un campo único `operaria` no alcanza | `REGISTRO_PERSONA` (N:M) |
| horas sin trabajar, tiempo faltante, % productividad | Se calculan a partir de los paros: si se guardan pueden contradecirlos | Se eliminan; se calculan en **vistas** |
| código → tipo de paro / "[19] No aplica" | Valor deducible del código; el 19 es ficticio | Se eliminan; sin filas en `PARO` = no aplica |
| máquina escrita como "Maq #2" o "Vinilos_2" | Alias de la misma máquina | `MAQUINA` con nombre único |

**Por qué:** si un dato se puede deducir de otro que no es la llave, guardarlo permite que ambos se contradigan. Para los indicadores que la dirección revisa cada mes, esa contradicción sería un error visible.

---

## 5. Forma normal de Boyce-Codd (BCNF)

**Qué elimina en general:** anomalías que sobreviven a la 3FN cuando una relación tiene varias llaves candidatas que se solapan, o cuando un determinante no es llave.

**Resultado en este proyecto:** no hizo falta descomponer más. Se verificó que en cada tabla todo determinante es llave candidata:

| Tabla | Llaves candidatas | Determinantes |
|---|---|---|
| MAQUINA | `maquina_id`, `nombre` | Ambos son llaves |
| CODIGO_PARO | `codigo`, `descripcion` | Ambos son llaves |
| SUBCODIGO_PARO | `subcodigo_id`, (`codigo`, `clave`) | Ambos son llaves |
| REGISTRO_PRODUCCION | `registro_id`, (`maquina_id`, `fecha`, `turno_id`, `referencia_id`) | Ambos son llaves |
| REGISTRO_PERSONA | (`registro_id`, `persona_id`) | Solo la llave |

Las llaves únicas alternativas se aseguran con `UNIQUE`. Además, no existen dependencias multivaluadas independientes, por lo que el esquema también cumple **4FN**.

---

## 6. Desviaciones deliberadas en `PARO`

Estas dos columnas violan estrictamente la 3FN y se mantienen a propósito.

| Columna | Dependencia | Por qué se conserva | Cómo se controla |
|---|---|---|---|
| `codigo` junto a `subcodigo_id` | `subcodigo_id → codigo` (cada subcódigo pertenece a un solo código) | Muchos paros **no tienen subcódigo** (el "(en blanco)" de los gráficos); en ese caso el código no se puede deducir. Además permite agrupar paros por código sin pasar por `SUBCODIGO_PARO` | FK compuesta (`codigo`, `subcodigo_id`) → `SUBCODIGO_PARO(codigo, subcodigo_id)`: impide combinaciones incoherentes |
| `ejecutor_tipo` junto a `persona_id` | `persona_id → rol` | El Excel registra el tipo (operarios / mantenimiento) aunque no haya nombre | CHECK de coherencia con el rol cuando hay persona. Si el Excel nunca trae el nombre, se elimina `persona_id` de `PARO` y la desviación desaparece |
| `meta_por_hora` en `REGISTRO_PRODUCCION` | (máquina, referencia) → meta | Es un valor histórico: cambiar la meta de 2025 no debe alterar los indicadores de 2024 | Se documenta como dato del evento, no del catálogo |

---

## 7. Preguntas probables en la sustentación

| Pregunta | Respuesta corta |
|---|---|
| ¿Por qué no basta con dejar el Excel en una tabla? | La estructura permite anomalías de inserción, actualización y borrado; el ejemplo de las pacas (943 vs 574) lo demuestra |
| ¿Qué dependencia parcial eliminaron y cómo la detectan? | (máquina, fecha, turno, referencia) → pacas: dependen de parte de la llave de la tabla 1FN, no del código de paro |
| ¿Por qué `PARO` guarda `codigo` si ya tiene el subcódigo? | Porque el subcódigo es opcional; la FK compuesta evita incoherencias |
| ¿Qué cambió entre 3FN y BCNF? | Nada: se verificó que todo determinante es llave candidata |
| ¿Por qué no se guarda el % de productividad? | Es calculable desde los paros y las horas; guardarlo permite contradicciones. Se obtiene con una vista |
