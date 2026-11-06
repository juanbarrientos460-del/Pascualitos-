/*
Pascualitos - 02_insertar_catalogos.sql
Ejecutar después de 01_crear_esquema.sql.
Carga idempotente: puede ejecutarse más de una vez.
*/
SET search_path TO pascualitos, public;

INSERT INTO maquina(nombre) VALUES
('Vinilos_1'), ('Vinilos_2'), ('Vinilos_3'), ('Vinilos_4')
ON CONFLICT (nombre) DO NOTHING;

-- Turnos identificados en el libro Excel. Los horarios no estándar se conservan
-- como descripción; no se fuerza una hora cuando el origen no la define.
INSERT INTO turno(descripcion, hora_inicio, hora_fin) VALUES
('6am-2pm (Turno 1)', TIME '06:00', TIME '14:00'),
('2pm-10pm (Turno 2)', TIME '14:00', TIME '22:00'),
('10pm-6am (Turno 3)', TIME '22:00', TIME '06:00'),
('6am-6pm', TIME '06:00', TIME '18:00'),
('6pm-6am', TIME '18:00', TIME '06:00'),
('6am-4:30pm', TIME '06:00', TIME '16:30')
ON CONFLICT (descripcion) DO NOTHING;

INSERT INTO codigo_paro(num_codigo, descripcion) VALUES
(1, 'Falla del sistema electromecánico y/o de control'),
(2, 'Espera de soporte de mantenimiento'),
(3, 'Novedad en los sistemas de potencia (aire, energía, vapor)'),
(4, 'Mantenimiento preventivo'),
(5, 'Ajuste operativo'),
(6, 'Limpieza por derrame operativo'),
(7, 'Alistamiento de máquina / Cambio de referencia'),
(8, 'Capacitación / Reunión'),
(9, 'Falta de operario'),
(10, 'Paro por ventaja/evacuación'),
(11, 'Reproceso'),
(12, 'Materia prima defectuosa'),
(13, 'En espera por el aval del laboratorio de microbiología'),
(14, 'Falta de materia prima'),
(15, 'Cambio de insumos (roscadores, O''ring, etiquetas)'),
(16, 'Alimentación y aseo de la zona de trabajo y la máquina'),
(17, 'Pausa activa'),
(18, 'Paro de máquina')
ON CONFLICT (num_codigo) DO UPDATE
SET descripcion = EXCLUDED.descripcion;

-- Subcódigos de códigos 03 y 05 transcritos del catálogo TABLA CODIGOS
-- del Excel. Se conserva el código textual del origen.
INSERT INTO subcodigo(num_codigo, codigo_texto, descripcion) VALUES
(3, '3.1', 'Fallo en la subestación'),
(3, '3.2', 'Fallo en la red pública'),
(3, '3.3', 'Falla en la red neumática o el compresor'),
(3, '3.4', 'Falla en la red de enfriamiento o el chiller'),
(3, '3.5', 'Falla en la red de vapor o la caldera'),
(5, '5.1', 'Sistema alimentador de envases'),
(5, '5.2', 'Sistema de dosificación de pintura, frontal posterior'),
(5, '5.3', 'Banda transportadora de entrada'),
(5, '5.4', 'Banda transportadora de salida'),
(5, '5.5', 'Transfer y pisador de tapa'),
(5, '5.6', 'Sistema alimentador de tapa y tobogan'),
(5, '5.7', 'Video Jet'),
(5, '5.8', 'Banda de sujeción y roscadores'),
(5, '5.9', 'Sistema de etiquetado'),
(5, '5.10', 'Purga de color'),
(5, '5.11', 'Lavado de boquilla')
ON CONFLICT (num_codigo, codigo_texto) DO UPDATE
SET descripcion = EXCLUDED.descripcion;

-- Nota: el catálogo del código 01 es jerárquico y extenso.
-- Sus niveles se cargan desde el catálogo completo validado en el Excel;
-- no se inventan filas de subcódigos que no estén confirmadas.
SELECT 'Catálogos base cargados' AS resultado;
