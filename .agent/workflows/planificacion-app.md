---
description: Workflow de planificación integral: Valida tu idea de negocio, define los requisitos del producto y diseña la arquitectura técnica. Ejecuta 10 skills secuenciales para crear una base sólida antes de escribir código.
---

Estoy iniciando la planificación de un nuevo proyecto y quiero que actúes como un arquitecto de soluciones experto, siguiendo estrictamente una "Ruta de Planificación" basada en skills específicos.

Por favor, ejecuta las siguientes 3 Fases secuencialmente. Para cada paso, debes leer primero el archivo SKILL.md (usando view_file) ubicado en la ruta indicada antes de proceder con la tarea. No asumas el contenido del skill, léelo primero.

El directorio base de los skills es: C:\Users\Pruebas\Desktop\apps\telegram-bots\finanzas-personales\backend\.agent\skills\skills

FASE 1: Ideación y Validación
El objetivo es validar la viabilidad y definir el "qué".

Definición de Características (Brainstorming)
Skill: brainstorming
Ruta: [DirectorioBase]\brainstorming\SKILL.md
Acción: Ayúdame a transformar mi idea inicial en un conjunto concreto de características y funcionalidades clave.
Análisis Competitivo
Skill: competitive-landscape
Ruta: [DirectorioBase]\competitive-landscape\SKILL.md
Acción: Identifica competidores potenciales y define mi ventaja competitiva (lo que haremos diferente/mejor).
Oportunidad de Mercado
Skill: startup-business-analyst-market-opportunity
Ruta: [DirectorioBase]\startup-business-analyst-market-opportunity\SKILL.md
Acción: Realiza una estimación del tamaño del mercado (TAM/SAM/SOM) para confirmar la viabilidad.
Caso de Negocio
Skill: startup-business-analyst-business-case
Ruta: [DirectorioBase]\startup-business-analyst-business-case\SKILL.md
Acción: Genera un documento formal de Caso de Negocio con la estrategia y premisas financieras básicas.
FASE 2: Definición del Producto
El objetivo es definir cómo va a funcionar y estructurar el proyecto.

Configuración Inicial (Conductor)
Skill: conductor-setup
Ruta: [DirectorioBase]\conductor-setup\SKILL.md
Acción: Inicializa la definición del producto, define el stack tecnológico preliminar y establece las guías de estilo y convenciones.
Contexto del Sistema (Modelo C4)
Skill: c4-context
Ruta: [DirectorioBase]\c4-context\SKILL.md
Acción: Crea un diagrama de contexto C4 definiendo los usuarios (Personas), sistemas externos y sus interacciones.
Historias de Usuario
Skill: brainstorming (Usado como fallback para users-stories)
Ruta: [DirectorioBase]\brainstorming\SKILL.md
Acción: Define los flujos de usuario principales y desgloza las funcionalidades en historias de usuario de alto nivel.
FASE 3: Arquitectura Técnica
El objetivo es crear el plano de construcción.

Estrategia de Monetización
Skill: pricing-strategy
Ruta: [DirectorioBase]\pricing-strategy\SKILL.md
Acción: Define el modelo de precios (Suscripción, Freemium, etc.), ya que esto impactará en el diseño de la base de datos y la gestión de usuarios.
Decisiones de Arquitectura
Skill: architecture
Ruta: [DirectorioBase]\architecture\SKILL.md
Acción: Documenta las decisiones técnicas clave (Trade-offs), como la elección de base de datos (SQL vs NoSQL) o estilo de arquitectura (Monolito vs Microservicios).
Diseño de Software
Skill: software-architecture
Ruta: [DirectorioBase]\software-architecture\SKILL.md
Acción: Estructura los componentes del sistema enfocándote en la calidad, escalabilidad y mantenibilidad desde el inicio.
