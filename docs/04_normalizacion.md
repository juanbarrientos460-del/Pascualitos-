MAQUINA(maquina_id PK, nombre UNIQUE)
TURNO(turno_id PK, nombre, hora_inicio, hora_fin)
REFERENCIA(referencia_id PK, nombre UNIQUE, unidades_por_display, display_por_paca)
PERSONA(persona_id PK, codigo_anonimo UNIQUE, rol CHECK(OPERARIO|MANTENIMIENTO), activo)
CODIGO_PARO(codigo PK, descripcion UNIQUE, admite_subcodigo)
SUBCODIGO_PARO(subcodigo_id PK, codigo FK, clave, descripcion,
               padre_id FK→self, UNIQUE(codigo,clave), UNIQUE(codigo,subcodigo_id))
REGISTRO_PRODUCCION(registro_id PK, maquina_id FK, turno_id FK, referencia_id FK,
               fecha, horas_trabajadas, meta_por_hora, pacas_producidas,
               UNIQUE(maquina_id, fecha, turno_id, referencia_id))
REGISTRO_PERSONA(registro_id FK, persona_id FK, PK(registro_id, persona_id))
PARO(paro_id PK, registro_id FK, codigo FK, subcodigo_id NULL, minutos CHECK(>0),
     ejecutor_tipo NULL, persona_id FK NULL, observacion,
     FK compuesta (codigo, subcodigo_id) → SUBCODIGO_PARO(codigo, subcodigo_id))
