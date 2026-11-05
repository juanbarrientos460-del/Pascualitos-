Entidades y reglas de negocio: ajustes tras revisar el Excel
Resultado de contrastar el borrador de entidades, atributos y reglas de negocio con las columnas reales de la hoja Base De Datos del archivo SEGUIMIENTO TEMPERAS Y VINILOS Actividad.xlsm.
Lo que se confirma
• Tiempo de Paro está en horas y es la suma de los minutos de los 18 códigos dividida entre 60. Coincide en las 8.208 filas, así que es un dato derivado y no debe ser una columna en la base. Se calcula.
• No hay minutos negativos, así que el CHECK minutos >= 0 no choca con ningún dato.
• Las 3 columnas de subcódigo y "Área involucrada" existen tal como se describieron.
Lo que hay que corregir en el borrador
1. "Meta por hora" no está en la hoja de datos. Aparece en el formulario de registro y en la hoja Tiempos, pero no en Base De Datos. No debe ponerse todavía como atributo de Referencia; falta ubicar de dónde sale (hay que revisar Tiempos).
2. "Área involucrada" (Operarios / Personal de mantenimiento) describe el paro, no a la persona. Solo tiene esos 2 valores y es la que alimenta el gráfico del código 5 en el P-MTO-22. Va como atributo de Paro, junto con "Personal involucrado" (38 nombres distintos).
3. No hay una llave natural confiable. Solo 4.955 combinaciones distintas de fecha, máquina, turno, operaria y referencia entre 8.208 filas (incluyen los duplicados). Además, el formato físico muestra varias referencias en un mismo turno. Conviene un identificador propio (id) en Registro de producción.
4. Hay columnas desalineadas. "Unidad por display" tiene textos de turno (por ejemplo 6am-2pm) en 593 filas, probablemente porque la macro escribió en la columna equivocada. Esas filas hay que limpiarlas en la migración. Dos columnas más (Unidades producidas cada minuto y Display por paca) están vacías en todas las filas y no entran al modelo.
5. Turno tiene 7 valores distintos, incluidos turnos de 12 horas (6am-6pm, 6pm-6am) y "No aplica". El catálogo de Turno debe aceptar turnos de distinta duración.
La regla pendiente, ya probada
La suma de los minutos de paro de un registro supera las horas trabajadas en 45 filas, de las 5.159 que tienen horas trabajadas. Por eso no se puede poner como CHECK estricto sin antes decidir qué hacer con esos casos. Las opciones son corregirlos en la migración o dejarlos como una consulta de control de calidad.
Aviso sobre los vacíos
Hay muchos nulos: operario en 3.721 filas, referencia en 3.874, turno en 3.912, horas trabajadas en 3.049 y pacas en 3.051. Antes de decidir qué columnas aceptan nulos, hay que entender si esas filas son días sin producción o datos que faltaron. Es una decisión que deben tomar y justificar.
