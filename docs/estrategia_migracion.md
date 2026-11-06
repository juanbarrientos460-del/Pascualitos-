# Estrategia de migración del Excel a PostgreSQL

## Fuente y alcance
La fuente principal es la hoja `Base De Datos` del libro `SEGUIMIENTO TEMPERAS Y VINILOS Actividad.xlsm`. La hoja presenta 58 columnas y filas históricas desde 2022 hasta marzo de 2025. El libro también incluye catálogos, subcódigos, hojas auxiliares y tablas dinámicas.

## Estrategia
1. Conservar el XLSM original sin modificaciones.
2. Crear copia de trabajo y exportar la hoja de datos a CSV UTF-8.
3. Importar a `pascualitos_staging.base_datos_excel`, no directamente a tablas finales.
4. Homologar máquinas, turnos, referencias, códigos y subcódigos con los catálogos aprobados.
5. Revisar las filas con campos incompletos y las posibles filas duplicadas. No eliminar duplicados solo por coincidencia de valores: validar si son eventos distintos.
6. Seudonimizar operarias y personal de mantenimiento antes de cargar `persona`. Los nombres no se guardan en la base analítica ni en GitHub.
7. Insertar primero catálogos; después registros de producción y asociaciones de persona; por último, eventos de paro.
8. Comparar conteos y sumas por período/máquina entre origen y destino.

## Advertencias de calidad
- El Excel tiene filas con estructura irregular y datos repartidos en varias columnas de códigos/duración. Debe verificarse el significado de cada columna antes de convertirla en evento `paro`.
- El catálogo TABLA CODIGOS muestra códigos 01 a 17, mientras el libro también contiene el código 18. Se conserva 18 como dato del libro, pendiente de aprobación formal del negocio.
- No se debe interpretar un campo vacío como cero.
- No se debe interpretar automáticamente la etiqueta `[19] No aplica` como un código de paro real: no representa un evento de paro.
- Las filas duplicadas requieren revisión manual y trazabilidad.

## Evidencia de integridad
Documentar en un acta de migración:
- cantidad de filas importadas a staging;
- cantidad de registros insertados;
- cantidad de eventos de paro insertados;
- filas rechazadas y motivo;
- suma de pacas por mes y máquina en origen/destino;
- suma de minutos de paro por código en origen/destino;
- conteo de valores sin homologación;
- consulta de huérfanos (debe devolver cero filas).

La carga se considera validada solo cuando las diferencias se expliquen y documenten. La mera ejecución del importador no demuestra integridad.
