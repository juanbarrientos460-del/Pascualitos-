/*
Pascualitos - 04_consultas_negocio.sql
Ejecutar después de crear esquema, cargar catálogos y migrar datos.
Rangos de fechas de ejemplo: modificar según el período requerido.
*/
SET search_path TO pascualitos, public;

-- 1. Producción mensual por máquina.
SELECT m.nombre AS maquina,
       DATE_TRUNC('month', r.fecha)::date AS mes,
       SUM(r.pacas_producidas) AS pacas
FROM registro_produccion r
JOIN maquina m ON m.id_maquina = r.id_maquina
WHERE r.fecha >= DATE '2022-01-01' AND r.fecha < DATE '2026-01-01'
GROUP BY m.nombre, DATE_TRUNC('month', r.fecha)
ORDER BY mes, maquina;

-- 2. Cumplimiento porcentual de la meta por máquina/mes.
-- Fórmula: pacas reales / (meta por hora * horas trabajadas) * 100.
-- Validar que meta_por_hora esté expresada en pacas/hora antes de reportar.
SELECT m.nombre AS maquina,
       DATE_TRUNC('month', r.fecha)::date AS mes,
       ROUND(100.0 * SUM(r.pacas_producidas) /
         NULLIF(SUM(r.meta_por_hora * r.horas_trabajadas), 0), 2) AS cumplimiento_pct
FROM registro_produccion r
JOIN maquina m ON m.id_maquina = r.id_maquina
WHERE r.fecha >= DATE '2022-01-01' AND r.fecha < DATE '2026-01-01'
  AND r.pacas_producidas IS NOT NULL
  AND r.meta_por_hora IS NOT NULL
  AND r.horas_trabajadas IS NOT NULL
GROUP BY m.nombre, DATE_TRUNC('month', r.fecha)
ORDER BY mes, maquina;

-- 3. Comparativo anual de pacas por máquina.
SELECT m.nombre AS maquina, EXTRACT(YEAR FROM r.fecha)::int AS anio,
       SUM(r.pacas_producidas) AS pacas
FROM registro_produccion r
JOIN maquina m ON m.id_maquina = r.id_maquina
GROUP BY m.nombre, EXTRACT(YEAR FROM r.fecha)
ORDER BY anio, maquina;

-- 4. Participación porcentual de cada código según minutos de paro.
SELECT c.num_codigo, c.descripcion, SUM(p.minutos) AS minutos,
       ROUND(100.0 * SUM(p.minutos) /
         NULLIF(SUM(SUM(p.minutos)) OVER (), 0), 2) AS participacion_pct
FROM paro p
JOIN codigo_paro c ON c.num_codigo = p.num_codigo
GROUP BY c.num_codigo, c.descripcion
ORDER BY minutos DESC;

-- 5. Detalle por subcódigo de los códigos 01, 03 y 05.
SELECT c.num_codigo, c.descripcion AS codigo,
       COALESCE(s.codigo_texto, '(sin subcódigo)') AS subcodigo,
       COALESCE(s.descripcion, 'No especificado') AS detalle,
       SUM(p.minutos) AS minutos, COUNT(*) AS eventos
FROM paro p
JOIN codigo_paro c ON c.num_codigo = p.num_codigo
LEFT JOIN subcodigo s
  ON s.num_codigo = p.num_codigo AND s.id_subcodigo = p.id_subcodigo
WHERE c.num_codigo IN (1, 3, 5)
GROUP BY c.num_codigo, c.descripcion, s.codigo_texto, s.descripcion
ORDER BY c.num_codigo, subcodigo;

-- 6. Comparación entre turnos.
SELECT t.descripcion AS turno, COUNT(*) AS registros,
       SUM(r.pacas_producidas) AS pacas,
       ROUND(AVG(r.horas_trabajadas), 2) AS promedio_horas
FROM registro_produccion r
JOIN turno t ON t.id_turno = r.id_turno
GROUP BY t.descripcion
ORDER BY pacas DESC NULLS LAST;

-- 7. Registros sin paros (LEFT JOIN).
SELECT r.id_registro, r.fecha, m.nombre, r.pacas_producidas
FROM registro_produccion r
JOIN maquina m ON m.id_maquina = r.id_maquina
LEFT JOIN paro p ON p.id_registro = r.id_registro
WHERE p.id_paro IS NULL
ORDER BY r.fecha;

-- 8. Personas seudonimizadas con más registros asociados.
SELECT pe.codigo_anonimo, pe.rol, COUNT(rp.id_registro) AS registros
FROM persona pe
LEFT JOIN registro_persona rp ON rp.id_persona = pe.id_persona
GROUP BY pe.codigo_anonimo, pe.rol
ORDER BY registros DESC;

-- 9. Minutos de paro por año y código, con filtro de fechas.
SELECT EXTRACT(YEAR FROM r.fecha)::int AS anio,
       c.num_codigo, c.descripcion, SUM(p.minutos) AS minutos
FROM paro p
JOIN registro_produccion r ON r.id_registro = p.id_registro
JOIN codigo_paro c ON c.num_codigo = p.num_codigo
WHERE r.fecha BETWEEN DATE '2022-01-01' AND DATE '2025-12-31'
GROUP BY EXTRACT(YEAR FROM r.fecha), c.num_codigo, c.descripcion
ORDER BY anio, minutos DESC;

-- 10. Máquinas cuyo total de minutos de paro supera 120 (HAVING).
SELECT m.nombre, SUM(p.minutos) AS minutos_paro
FROM maquina m
JOIN registro_produccion r ON r.id_maquina = m.id_maquina
JOIN paro p ON p.id_registro = r.id_registro
GROUP BY m.id_maquina, m.nombre
HAVING SUM(p.minutos) > 120
ORDER BY minutos_paro DESC;

-- 11. Subconsulta: máquinas cuya producción acumulada supera el promedio
-- de producción acumulada por máquina.
SELECT m.nombre, SUM(r.pacas_producidas) AS pacas
FROM maquina m
JOIN registro_produccion r ON r.id_maquina = m.id_maquina
GROUP BY m.id_maquina, m.nombre
HAVING SUM(r.pacas_producidas) >
 (SELECT AVG(totales.pacas)
  FROM (SELECT SUM(pacas_producidas) AS pacas
        FROM registro_produccion
        GROUP BY id_maquina) AS totales);

-- 12. Comparación anual mediante subconsulta correlacionada:
-- producción por máquina/año frente al total de esa máquina.
SELECT m.nombre, EXTRACT(YEAR FROM r.fecha)::int AS anio,
       SUM(r.pacas_producidas) AS pacas_anuales,
       (SELECT SUM(r2.pacas_producidas)
        FROM registro_produccion r2
        WHERE r2.id_maquina = r.id_maquina) AS pacas_historicas_maquina
FROM registro_produccion r
JOIN maquina m ON m.id_maquina = r.id_maquina
GROUP BY m.id_maquina, m.nombre, EXTRACT(YEAR FROM r.fecha)
ORDER BY m.nombre, anio;
