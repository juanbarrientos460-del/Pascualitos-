# Modelo conceptual (MER) – Pascualitos

Notación: pata de gallo (Crow's Foot). Este modelo presenta entidades, atributos y relaciones; no incluye llaves foráneas como columnas.

## Diagrama

```mermaid
erDiagram
    MAQUINA ||--o{ REGISTRO_PRODUCCION : "se registra en"
    TURNO ||--o{ REGISTRO_PRODUCCION : "programa"
    REFERENCIA ||--o{ REGISTRO_PRODUCCION : "se produce en"
    PERSONA }o--|{ REGISTRO_PRODUCCION : "opera"
    REGISTRO_PRODUCCION ||--o{ PARO : "contiene"
    CODIGO_PARO ||--o{ PARO : "clasifica"
    SUBCODIGO_PARO o|--o{ PARO : "detalla"
    PERSONA o|--o{ PARO : "atiende"
    AREA_IMPACTO ||--o{ CODIGO_PARO : "agrupa"
    CODIGO_PARO ||--o{ SUBCODIGO_PARO : "tiene"
    TIPO_PARO o|--o{ REGISTRO_PRODUCCION : "clasifica"
    SUBCODIGO_PARO o|--o{ SUBCODIGO_PARO : "es padre de"

    MAQUINA {
        int maquina_id
        string nombre
    }
    TURNO {
        int turno_id
        string descripcion
        time hora_inicio
        time hora_fin
    }
    PERSONA {
        int persona_id
        string codigo_anonimo
        string rol
    }
    REFERENCIA {
        int referencia_id
        string producto
        int volumen_cc
        int num_colores
    }
    AREA_IMPACTO {
        int area_id
        string nombre
    }
    CODIGO_PARO {
        int codigo
        string descripcion
    }
    SUBCODIGO_PARO {
        int subcodigo_id
        string clave
        string descripcion
    }
    TIPO_PARO {
        int tipo_paro_id
        string nombre
    }
    REGISTRO_PRODUCCION {
        int registro_id
        date fecha
        decimal horas_trabajadas
        decimal meta_por_hora
        int pacas_producidas
    }
    PARO {
        int paro_id
        int minutos
        string observacion
    }
```

## Cardinalidades y participación

| Relación | Cardinalidad | Participación |
|---|---|---|
| MAQUINA – REGISTRO_PRODUCCION | 1:N | Máquina parcial; registro total |
| TURNO – REGISTRO_PRODUCCION | 1:N | Turno parcial; registro total |
| REFERENCIA – REGISTRO_PRODUCCION | 1:N | Referencia parcial; registro total |
| PERSONA – REGISTRO_PRODUCCION | N:M | Persona parcial; registro total |
| REGISTRO_PRODUCCION – PARO | 1:N | Registro parcial; paro total |
| CODIGO_PARO – PARO | 1:N | Código parcial; paro total |
| SUBCODIGO_PARO – PARO | 1:N | Subcódigo parcial; paro parcial |
| PERSONA – PARO | 1:N | Persona parcial; paro parcial |
| AREA_IMPACTO – CODIGO_PARO | 1:N | Área parcial; código total |
| CODIGO_PARO – SUBCODIGO_PARO | 1:N | Código parcial; subcódigo total |
| TIPO_PARO – REGISTRO_PRODUCCION | 1:N | Tipo parcial; registro parcial |
| SUBCODIGO_PARO – SUBCODIGO_PARO | 1:N | Participación parcial en ambos lados |

**Nota:** el MER representa la relación PERSONA–REGISTRO_PRODUCCION como N:M. Al derivar el modelo lógico, esta relación requiere una tabla intermedia (por ejemplo, `registro_persona`) si un registro puede tener varias personas y una persona puede participar en varios registros.
