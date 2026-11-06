# Datos de migración

Los archivos CSV de trabajo se deben mantener localmente y no subir al repositorio público porque el Excel contiene nombres de operarias y personal de mantenimiento.

Flujo recomendado:
1. Crear una copia de trabajo del Excel original.
2. Exportar la hoja `Base De Datos` a CSV UTF-8.
3. Homologar columnas en una copia depurada y mapearlas a `pascualitos_staging.base_datos_excel`.
4. Importar mediante DBeaver (clic derecho sobre la tabla staging → Import Data → CSV).
5. Ejecutar `sql/03_migrar_datos.sql` para controles de calidad.
6. Antes de insertar en tablas definitivas, reemplazar nombres por códigos anónimos. No almacenar la tabla de correspondencia en este repositorio.
7. Guardar evidencias agregadas (conteos y sumas), nunca listados de nombres personales.

No se incluye aquí el Excel ni el CSV por privacidad y tamaño. La importación debe realizarse desde el equipo del proyecto.
