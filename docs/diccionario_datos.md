# Diccionario de datos — Pascualitos

Motor: PostgreSQL. Esquema: `pascualitos`. Fuente técnica: `sql/01_crear_esquema.sql`.

> El diccionario describe exactamente las nueve tablas del script vigente. En PostgreSQL, `INTEGER` ocupa 4 bytes, `BIGINT` 8 bytes, `NUMERIC(p,s)` usa precisión/escala declaradas, `VARCHAR(n)` limita caracteres y `TEXT` no fija longitud máxima. Los campos sin DEFAULT explícito no tienen valor por defecto.

## 1. maquina
Catálogo de las cuatro líneas de envasado.
| Columna | Tipo/longitud | Nulo | Default | Restricciones | Descripción |
|---|---|---:|---|---|---|
| id_maquina | INTEGER | No | identity | PK | Identificador interno autogenerado. |
| nombre | VARCHAR(20) | No | — | UNIQUE | Nombre de línea, por ejemplo Vinilos_1. |

## 2. turno
Catálogo de turnos y horarios.
| Columna | Tipo/longitud | Nulo | Default | Restricciones | Descripción |
|---|---|---:|---|---|---|
| id_turno | INTEGER | No | identity | PK | Identificador del turno. |
| descripcion | VARCHAR(40) | No | — | UNIQUE | Nombre/horario de turno. |
| hora_inicio | TIME | Sí | NULL | — | Hora de inicio, cuando se conoce. |
| hora_fin | TIME | Sí | NULL | — | Hora de finalización, cuando se conoce. |

## 3. persona
Catálogo seudonimizado del personal.
| Columna | Tipo/longitud | Nulo | Default | Restricciones | Descripción |
|---|---|---:|---|---|---|
| id_persona | INTEGER | No | identity | PK | Identificador interno. |
| codigo_anonimo | VARCHAR(10) | No | — | UNIQUE | Código sin nombre personal. |
| rol | VARCHAR(20) | No | — | CHECK OPERARIO/MANTENIMIENTO; UNIQUE(id_persona,rol) | Rol utilizado para validar relaciones. |

## 4. referencia
Catálogo de producto y presentación.
| Columna | Tipo/longitud | Nulo | Default | Restricciones | Descripción |
|---|---|---:|---|---|---|
| id_referencia | INTEGER | No | identity | PK | Identificador de presentación. |
| producto | VARCHAR(80) | No | — | UNIQUE compuesta con volumen_cc y num_colores | Nombre de producto. |
| volumen_cc | INTEGER | Sí | NULL | CHECK > 0 si no es NULL | Contenido nominal en centímetros cúbicos. |
| num_colores | INTEGER | Sí | NULL | CHECK > 0 si no es NULL | Número de colores de la presentación. |

## 5. codigo_paro
Catálogo de causas de paro.
| Columna | Tipo/longitud | Nulo | Default | Restricciones | Descripción |
|---|---|---:|---|---|---|
| num_codigo | INTEGER | No | — | PK | Número de código de paro. |
| descripcion | VARCHAR(150) | No | — | NOT NULL | Descripción oficial del motivo. |

## 6. subcodigo
Catálogo jerárquico de causas específicas.
| Columna | Tipo/longitud | Nulo | Default | Restricciones | Descripción |
|---|---|---:|---|---|---|
| id_subcodigo | INTEGER | No | identity | PK | Identificador del subcódigo. |
| num_codigo | INTEGER | No | — | FK a codigo_paro; UNIQUE(num_codigo,codigo_texto); UNIQUE(num_codigo,id_subcodigo) | Código padre al que pertenece. |
| codigo_texto | VARCHAR(10) | No | — | UNIQUE compuesta | Clave textual, por ejemplo 5.2 o 1.1.A. |
| descripcion | VARCHAR(150) | No | — | NOT NULL | Descripción del subcódigo. |
| padre_id | INTEGER | Sí | NULL | FK compuesta autorreferenciada; CHECK no ser su propio padre | Subcódigo superior, si existe. |

## 7. registro_produccion
Una fila por registro/formato de producción.
| Columna | Tipo/longitud | Nulo | Default | Restricciones | Descripción |
|---|---|---:|---|---|---|
| id_registro | BIGINT | No | identity | PK | Identificador interno del registro. |
| fecha | DATE | No | — | NOT NULL | Día de producción. |
| id_maquina | INTEGER | No | — | FK maquina, ON DELETE RESTRICT | Línea que produjo. |
| id_turno | INTEGER | Sí | NULL | FK turno, ON DELETE RESTRICT | Turno asociado, si se conoce. |
| id_referencia | INTEGER | Sí | NULL | FK referencia, ON DELETE RESTRICT | Producto/presentación fabricada. |
| pacas_producidas | INTEGER | Sí | NULL | CHECK >= 0 | Pacas producidas. |
| horas_trabajadas | NUMERIC(6,2) | Sí | NULL | CHECK >= 0 | Horas trabajadas. |
| meta_por_hora | NUMERIC(10,2) | Sí | NULL | CHECK > 0 | Meta de producción por hora. |
| observacion_paro | TEXT | Sí | NULL | — | Observación relacionada con paros. |
| observaciones | TEXT | Sí | NULL | — | Observaciones generales. |

## 8. registro_persona
Tabla puente de la relación N:M entre registro y persona.
| Columna | Tipo/longitud | Nulo | Default | Restricciones | Descripción |
|---|---|---:|---|---|---|
| id_registro | BIGINT | No | — | PK compuesta; FK registro_produccion ON DELETE CASCADE | Registro en el que participó. |
| id_persona | INTEGER | No | — | PK compuesta; FK persona ON DELETE RESTRICT | Persona seudonimizada asociada. |

## 9. paro
Detalle de cada evento de paro dentro de un registro.
| Columna | Tipo/longitud | Nulo | Default | Restricciones | Descripción |
|---|---|---:|---|---|---|
| id_paro | BIGINT | No | identity | PK | Identificador del evento. |
| id_registro | BIGINT | No | — | FK registro_produccion ON DELETE CASCADE | Registro al que pertenece. |
| num_codigo | INTEGER | No | — | FK codigo_paro ON DELETE RESTRICT | Causa general. |
| minutos | INTEGER | No | — | CHECK > 0 | Duración del evento en minutos. |
| id_subcodigo | INTEGER | Sí | NULL | FK compuesta (num_codigo,id_subcodigo) a subcodigo | Detalle de causa, si existe. |
| ejecutor_tipo | VARCHAR(20) | Sí | NULL | CHECK OPERARIO/MANTENIMIENTO | Rol del personal involucrado. |
| id_persona_involucrada | INTEGER | Sí | NULL | FK compuesta con ejecutor_tipo a persona(id_persona,rol) | Persona involucrada, si se identificó. |
| observacion | TEXT | Sí | NULL | — | Descripción complementaria. |

## Restricciones y políticas referenciales

- Las PK identifican cada fila y evitan duplicados de identidad.
- Las FK aseguran que máquina, turno, referencia, persona y código existan antes de relacionarlos.
- Las restricciones UNIQUE evitan duplicar nombres de máquinas/turnos, códigos anónimos y claves de subcódigo dentro de un código.
- CHECK valida dominio de roles, duración positiva y cantidades/horas no negativas.
- NOT NULL se reserva para datos indispensables: fecha, máquina, código y minutos del paro.
- IDENTITY genera claves sustitutas automáticamente. No se asigna DEFAULT artificial a fechas, producción ni duraciones.
- ON DELETE RESTRICT conserva catálogos con historia asociada. ON DELETE CASCADE se usa solo en detalles dependientes (paros y asociación de personas al registro). ON UPDATE CASCADE mantiene referencias si una clave cambia; las claves sustitutas normalmente no se actualizan.
- El esquema no guarda nombres reales. La tabla persona utiliza códigos anónimos; la tabla de correspondencia, si la empresa necesita reidentificar, debe permanecer fuera de esta base y con acceso restringido.

## Índices

El script crea seis índices: fecha; máquina+fecha; turno+fecha; código de paro; registro del paro; subcódigo. Se justifican por filtros temporales y JOIN/agrupaciones habituales de los indicadores mensuales, por máquina, turno y causa.
