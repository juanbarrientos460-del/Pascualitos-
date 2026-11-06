# PASCUALITOS — Base de datos de paros de producción

Proyecto de Bases de Datos I. Integrantes: Sebastian Ceballos Garzón y Juan Pablo Barrientos López.

## Objetivo
Diseñar e implementar una base de datos relacional en PostgreSQL para registrar producción y paros de las líneas de envasado de vinilos y témperas, reemplazando el libro Excel como fuente única de información.

## Requisitos
- PostgreSQL 14 o superior (recomendado).
- DBeaver Community o herramienta compatible.
- Acceso al repositorio GitHub.

## Estructura
- `docs/`: diagnóstico, MER, normalización, diccionario de datos y estrategia de migración.
- `sql/`: scripts SQL numerados para creación, catálogos, migración, consultas y pruebas.
- `img/`: diagramas y evidencias gráficas.
- `data/`: instrucciones para datos de carga. Los archivos fuente con datos personales no se publican.

## Reproducir desde cero en DBeaver
1. Crear una base de datos vacía llamada `pascualitos_db` en PostgreSQL.
2. Conectarse a esa base en DBeaver.
3. Abrir y ejecutar en orden:
   - `sql/01_crear_esquema.sql`
   - `sql/02_insertar_catalogos.sql`
   - Importar el CSV depurado a `pascualitos_staging.base_datos_excel` siguiendo `docs/estrategia_migracion.md`.
   - Ejecutar los controles de `sql/03_migrar_datos.sql`.
   - Cuando la transformación y anonimización estén validadas, cargar los registros finales.
   - Ejecutar `sql/04_consultas_negocio.sql`.
   - Ejecutar `sql/05_pruebas_restricciones.sql` en entorno de pruebas.
4. Verificar tablas bajo el esquema `pascualitos`.

## Privacidad y datos
El Excel contiene nombres de operarias y personal de mantenimiento. No publicar el XLSM, CSV original ni una tabla que permita reidentificar personas. La base utiliza códigos anónimos. Mantener la llave de reidentificación, si la empresa la necesita, fuera de este repositorio y con acceso restringido.

## Importante sobre migración
El script `03_migrar_datos.sql` crea staging y controles de calidad; no finge una carga histórica automática. La estructura de origen tiene filas/columnas heterogéneas, por lo que es obligatorio homologar campos y verificar los indicadores antes de poblar las tablas finales. Documentar diferencias y rechazos.

## Orden de scripts
| Archivo | Función |
|---|---|
| `01_crear_esquema.sql` | Crea esquema, nueve tablas, restricciones e índices. |
| `02_insertar_catalogos.sql` | Carga máquinas, turnos, códigos y subcódigos confirmados. |
| `03_migrar_datos.sql` | Crea staging y controles para la migración. |
| `04_consultas_negocio.sql` | Consultas de indicadores y análisis. |
| `05_pruebas_restricciones.sql` | Pruebas de integridad en transacción reversible. |

## Estado
La estructura SQL y los catálogos iniciales están documentados. La migración histórica requiere ejecutar el flujo local y adjuntar evidencia de integridad; no se declara completada hasta comparar origen y destino.
