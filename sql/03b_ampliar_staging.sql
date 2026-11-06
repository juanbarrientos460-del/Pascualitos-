/*
Pascualitos - 03b_ampliar_staging.sql
Ejecutar después de 03_migrar_datos.sql y antes de importar
data local pascualitos_staging_import.csv.

Se agregan columnas para conservar datos del Excel que no estaban
en el staging inicial. No publicar el CSV con nombres en GitHub.
*/
ALTER TABLE pascualitos_staging.base_datos_excel
    ADD COLUMN IF NOT EXISTS mes_origen VARCHAR(20),
    ADD COLUMN IF NOT EXISTS anio_origen INTEGER,
    ADD COLUMN IF NOT EXISTS unidades_producidas_minuto NUMERIC(12,2),
    ADD COLUMN IF NOT EXISTS unidad_por_display NUMERIC(12,2),
    ADD COLUMN IF NOT EXISTS display_por_paca NUMERIC(12,2),
    ADD COLUMN IF NOT EXISTS horas_no_trabajadas NUMERIC(8,2),
    ADD COLUMN IF NOT EXISTS tipo_paro_origen VARCHAR(150),
    ADD COLUMN IF NOT EXISTS tiempo_paro_total_horas NUMERIC(10,2),
    ADD COLUMN IF NOT EXISTS personal_involucrado_origen TEXT;

-- Verificar estructura ampliada:
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'pascualitos_staging'
  AND table_name = 'base_datos_excel'
ORDER BY ordinal_position;
