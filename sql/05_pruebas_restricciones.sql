/*
Pascualitos - 05_pruebas_restricciones.sql
Pruebas aisladas. Ejecutar en entorno de desarrollo.
El ROLLBACK final evita conservar los datos de prueba.
*/
BEGIN;
SET LOCAL search_path TO pascualitos, public;

-- INSERT válido.
INSERT INTO maquina(nombre) VALUES ('MAQUINA_PRUEBA');

-- UPDATE válido.
UPDATE maquina SET nombre = 'MAQUINA_PRUEBA_ACTUALIZADA'
WHERE nombre = 'MAQUINA_PRUEBA';

-- INSERT inválido: nombre NULL viola NOT NULL. Ejecutar individualmente
-- fuera de esta transacción o dentro de un bloque DO con EXCEPTION.
DO $$
BEGIN
  BEGIN
    INSERT INTO maquina(nombre) VALUES (NULL);
    RAISE EXCEPTION 'La prueba falló: se aceptó nombre NULL';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'Correcto: NOT NULL rechazó nombre NULL';
  END;
END $$;

-- CHECK inválido: minutos cero debe rechazarse.
DO $$
BEGIN
  BEGIN
    INSERT INTO paro(id_registro, num_codigo, minutos)
    VALUES (-999, 1, 0);
    RAISE EXCEPTION 'La prueba falló: se aceptaron cero minutos';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'Correcto: CHECK rechazó minutos = 0';
  END;
END $$;

-- DELETE válido del registro de prueba.
DELETE FROM maquina WHERE nombre = 'MAQUINA_PRUEBA_ACTUALIZADA';

ROLLBACK;

-- Prueba referencial RESTRICT: ejecutar después de tener registros reales.
-- Debe seleccionarse una máquina con registros asociados y ejecutar el DELETE
-- en una transacción separada; se espera foreign_key_violation.
-- DELETE FROM pascualitos.maquina WHERE id_maquina = <id_con_historial>;
