# Notación y herramienta de diagramación

## 1. Notación elegida: pata de gallo (crow's foot)

### Por qué pata de gallo y no Chen

| Criterio | Chen | Pata de gallo | Decisión |
|---|---|---|---|
| Cardinalidad y participación | Números (1, N) y línea simple o doble; hay que leer cada etiqueta | Se ven en el símbolo del extremo de la línea (mínimo y máximo) | Pata de gallo |
| Tamaño del diagrama | Cada atributo es un óvalo; con 8 entidades y ~35 atributos queda muy extenso | Los atributos van dentro del rectángulo de la entidad | Pata de gallo |
| Paso al modelo lógico | Hay que reinterpretar óvalos y rombos | Casi uno a uno con las tablas, PK y UK ya visibles | Pata de gallo |
| Herramientas | Pocas lo soportan bien | Soportada por Mermaid, draw.io, dbdiagram.io y DBeaver | Pata de gallo |
| Relaciones con atributos propios | Rombo con atributos | Se resuelve con tabla intermedia | Aceptable: en este modelo solo `opera` es N:M y no tiene atributos |

Chen es más expresivo en lo conceptual puro, pero para este proyecto, donde el MER se convierte directamente en un esquema SQL, la pata de gallo es más clara y más fácil de defender.

### Leyenda de símbolos

| Símbolo (en Mermaid) | Significado | Mínimo – Máximo |
|---|---|---|
| `\|\|` | Uno y solo uno | 1 – 1 |
| `\|o` | Cero o uno | 0 – 1 |
| `}o` / `o{` | Cero o muchos | 0 – N |
| `}\|` / `\|{` | Uno o muchos | 1 – N |
| Línea continua `--` | Relación identificante (la entidad débil depende de la fuerte) | |
| Línea punteada `..` | Relación no identificante | |
| `PK` | Llave primaria | |
| `UK` | Llave única (UNIQUE) | |

El símbolo pegado a una entidad indica **cuántas instancias de esa entidad** se asocian con cada instancia de la otra. El primer carácter (más lejos de la entidad) da el máximo y el segundo (pegado a la entidad) da el mínimo. El mínimo es la **participación**: 0 es parcial y 1 es total.

Ejemplo del diagrama: `REGISTRO_PRODUCCION ||--o{ PARO`
- Lado REGISTRO (`||`): cada paro pertenece a exactamente un registro (participación total de PARO).
- Lado PARO (`o{`): un registro tiene cero o muchos paros (participación parcial de REGISTRO).

### Cómo se representan los casos especiales

| Caso | Representación |
|---|---|
| Entidad débil (PARO) | Relación identificante (línea continua) y se declara como débil en la tabla de entidades, porque Mermaid no dibuja el doble rectángulo |
| Relación N:M (`opera`) | Se deja como N:M en el conceptual (`}\|--o{`) y se convierte en `REGISTRO_PERSONA` en el lógico |
| Relación recursiva (subcódigos) | Línea que sale y vuelve a `SUBCODIGO_PARO` con la etiqueta "es padre de" |
| Participación total/parcial | Mínimo `1` (total) o `0` (parcial) en cada extremo, más la tabla del documento del MER |
| Atributos derivados | No se dibujan; se listan aparte como "no almacenados" |

## 2. Herramienta elegida: Mermaid (diagrama como código)

### Por qué Mermaid

1. **Versionable.** El diagrama es texto dentro de un `.md`; cada cambio queda en el historial de Git con su diff, algo que un PNG o un `.drawio` binario no permite.
2. **Se renderiza en GitHub** sin instalar nada, y cualquier integrante puede editarlo desde el navegador.
3. **Trabajo en equipo.** Los cambios se revisan con pull requests como el resto del código.
4. **Reproducible.** Cualquiera puede regenerar la imagen para el PDF desde el mismo texto.
5. **Gratuita** y sin cuenta.

### Limitaciones y cómo se compensan

| Limitación | Compensación |
|---|---|
| No dibuja entidades débiles con doble borde | Se documenta en la tabla de entidades y se usa línea continua |
| No muestra FK en el diagrama conceptual | Es lo correcto en un MER; las FK aparecen en el modelo lógico |
| Control limitado del layout | Se exporta a SVG y, si hace falta, se retoca en draw.io solo para el PDF |
| Sin distinción gráfica de participación total | Se explicita con el símbolo mínimo y la tabla de relaciones |

### Herramientas complementarias

| Fase | Herramienta | Uso |
|---|---|---|
| Modelo conceptual (MER) | Mermaid + mermaid.live | Diagrama versionado y exportación a PNG/SVG |
| Modelo lógico | Mermaid o dbdiagram.io | Tablas con tipos, PK y FK |
| Modelo físico real | **DBeaver** (*ER Diagram*) | Se genera desde la base ya creada; sirve de evidencia de que el diagrama coincide con el esquema implementado |

Se mantiene DBeaver porque ya es la herramienta de la sustentación: el diagrama generado desde la base real demuestra que el script `01_schema.sql` implementa el modelo diseñado.

## 3. Flujo de trabajo

1. Editar el bloque `erDiagram` en `docs/03_modelo_conceptual_MER.md`.
2. Verificar el render en GitHub (o en mermaid.live).
3. Exportar PNG/SVG a `docs/img/mer_conceptual.png` (y `.svg`).
4. Hacer commit del `.md` y de la imagen.
5. Insertar la imagen en el PDF de entrega.
6. Tras crear la base, generar el diagrama ER desde DBeaver y guardarlo en `docs/img/er_dbeaver.png`.

## 4. Alternativas consideradas

| Herramienta | Por qué no fue la principal |
|---|---|
| draw.io / diagrams.net | Muy flexible y con soporte de Chen, pero el archivo no se compara bien en Git |
| dbdiagram.io | Excelente para el modelo lógico, pero orientado a tablas y no a un MER conceptual |
| Lucidchart | Requiere cuenta y su versión gratuita limita el número de objetos |
| MySQL Workbench / pgModeler | Orientados al modelo físico |
