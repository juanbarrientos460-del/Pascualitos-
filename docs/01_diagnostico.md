# Proyecto BDI: diagnóstico del Excel y ruta de arranque

Base de datos de paros de producción (vinilos y témperas). Resumen del análisis del archivo `SEGUIMIENTO TEMPERAS Y VINILOS Actividad.xlsm` y del procedimiento P-MTO-22, con los pasos para empezar.

## Cómo está el Excel hoy

La hoja principal (`Base De Datos`) tiene **8.208 registros**, del **1-ene-2022 al 28-mar-2025**, de 4 máquinas. Cada fila es un turno de una operaria en una máquina. Estos son los problemas que ya se ven:

- **Grupos repetidos (rompe 1FN):** hay 18 pares de columnas, "Código de paro N" y "Código N en horas". La primera guarda **minutos** (el nombre engaña) y la segunda es una fórmula que divide entre 60. Casi todas están vacías: el código 4 solo aparece en 8 filas y el 18 en 8.
- **Datos derivados guardados:** Mes y Año salen de la fecha (y el año está como texto), las horas salen de los minutos, y el tiempo de paro es una suma.
- **Turno inconsistente:** 8 variantes (`6am-2pm (Turno 1)`, `6am-4:30pm`, `6am-6pm`...), con 3.912 vacíos y 336 "No aplica".
- **Operario es texto libre:** 34 variantes ("Marcela" y "Marcela C.", "Erika" y "Erika H.", un "No"), con 3.721 vacíos.
- **Referencia mezcla varias cosas en un solo texto:** `Parchesitos 22cc (6 col)` junta producto, volumen y número de colores, y tiene errores de digitación (`Alocdor`, `Stilo Kids`, `(6col)` vs `(6 col)`).
- **Dos catálogos de "Tipo de paro" mezclados:** `17. PARO DE MAQUINA` y `[18] Paro de maquina por ventas` conviven.
- **El catálogo de códigos cambió con el tiempo:** el PDF lista 17 y el formulario del Excel 18 (agrega "Desinfección"), y algunos nombres difieren (códigos 10 y 13).
- **Subcódigos solo para los códigos 1, 3 y 5.** Son jerárquicos (1.1, 1.1.A...) y en el código 5 aparecen "Área involucrada" y "Personal involucrado", que incluye nombres completos del personal de mantenimiento (aquí entra el tema de datos personales).
- **Duplicación:** hay 42 filas idénticas, una hoja oculta repite parte de la tabla principal para los subcódigos, y 2 columnas están 100 % vacías.

