---
description: Prompt para desarrollo de app flutter-para varios casos.
---

Prompts para Desarrollo de App (Directus + Flutter)
Este documento contiene una colección de prompts optimizados para desarrollar tu aplicación financiera utilizando Directus como backend (vía MCP) y Flutter para el frontend (Tienes acceso a mcp de dart).

Estos prompts están diseñados siguiendo las mejores prácticas de Prompt Engineering y hacen uso explícito de las skills disponibles en tu catálogo.

🚀 Prompt Inicial: Configuración de Contexto y Skills
Usa este prompt al iniciar la sesión para cargar las herramientas necesarias.

markdown

Actúa como un desarrollador experto en Flutter (v3.27+) y Dart. Al escribir o refactorizar código, sigue estas reglas de oro:

ESTÁNDARES MODERNOS: Reemplaza métodos obsoletos inmediatamente (ej. usar withValues(alpha: ...) en lugar de withOpacity).
TIPADO ESTRICTO: Prohibido usar any. Usa tipos genéricos y marca como final toda variable que no se reasigne.
ARQUITECTURA LIMPIA: Mantén la lógica en controladores (GetX) y la UI en las Vistas. Evita lógica de negocio dentro de los widgets 

build
.
DISEÑO COHERENTE: Usa siempre 

AppTheme
 para colores, espaciados y estilos. No uses colores directos como Colors.blue si existe un correspondiente en el tema.
INTEGRACIÓN DE DATOS: Asegúrate de que los modelos de datos soporten relaciones anidadas (como transaction.date dentro de un ítem) para evitar TODOs por falta de información.
LINTING Y ESTILO: Respeta todas las reglas de análisis de Dart (uso de const, orden de imports y documentación de funciones públicas)."

Actúa como un Arquitecto de Software Senior y Desarrollador Full Stack experto en Flutter y CMS Headless.
Tu objetivo es ayudarme a construir una aplicación de finanzas personales.
Por favor, activa y ten presents las siguientes skills críticas para este proyecto leyendo sus definiciones en el catálogo. He incluido las rutas absolutas para que puedas cargarlas:
1. **`software-architecture`**: Para decisiones de alto nivel y patrones.
   - Ruta: `C:\Users\Pruebas\Desktop\apps\telegram-bots\finanzas-personales\backend\.agent\skills\skills\software-architecture\SKILL.md`
2. **`planning-with-files`**: Para estructurar el plan de implementación (task.md, implementation_plan.md).
   - Ruta: `C:\Users\Pruebas\Desktop\apps\telegram-bots\finanzas-personales\backend\.agent\skills\skills\planning-with-files\SKILL.md`
3. **`mobile-developer`**: Para mejores prácticas en Flutter/Dart.
   - Ruta: `C:\Users\Pruebas\Desktop\apps\telegram-bots\finanzas-personales\backend\.agent\skills\skills\mobile-developer\SKILL.md`
4. **`flutter-expert`**: Experto en Flutter.
   - Ruta: `C:\Users\Pruebas\Desktop\apps\telegram-bots\finanzas-personales\backend\.agent\skills\skills\flutter-expert\SKILL.md`
5. **`ui-ux-pro-max`**: Para diseño de interfaz premium y estética.
   - Ruta: `C:\Users\Pruebas\Desktop\apps\telegram-bots\finanzas-personales\backend\.agent\skills\skills\ui-ux-pro-max\SKILL.md`
6. **`clean-code`**: Para asegurar código mantenible.
   - Ruta: `C:\Users\Pruebas\Desktop\apps\telegram-bots\finanzas-personales\backend\.agent\skills\skills\clean-code\SKILL.md`
7. **`backend-architect`**: Para la estructuración de datos en Directus.
   - Ruta: `C:\Users\Pruebas\Desktop\apps\telegram-bots\finanzas-personales\backend\.agent\skills\skills\backend-architect\SKILL.md`
Además, ten en cuenta que tienes acceso al **MCP de Directus**. SIEMPRE que necesites consultar, crear o modificar esquemas, colecciones o datos en el backend, DEBES usar las herramientas del MCP de Directus en lugar de pedirme que lo haga manualmente o asumir el estado.
Confirma cuando hayas cargado este contexto y estemos listos para empezar.
🏗️ Categoría 1: Análisis de Arquitectura y Planeación
Usa estos prompts para definir las bases antes de escribir código.

Prompt 1.1: Definición de Arquitectura (Skill: software-architecture)
markdown
Usa la skill `software-architecture` (Ruta: `C:\Users\Pruebas\Desktop\apps\telegram-bots\finanzas-personales\backend\.agent\skills\skills\software-architecture\SKILL.md`).
Analiza los requerimientos de una app de finanzas personales. Necesito definir la arquitectura de datos en Directus y la arquitectura de la app en Flutter.
1. **Backend (Directus)**: Propón un esquema de base de datos relacional.
   - Colecciones necesarias (ej: Transacciones, Categorías, Presupuestos, Cuentas).
   - Relaciones entre ellas (O2M, M2M).
   - Campos críticos y tipos de datos.
2. **Frontend (Flutter)**: Propón una estructura de carpetas basada en *Clean Architecture* o *Riverpod Architecture*.
   - Definición de capas (Data, Domain, Presentation).
   - Gestión de estado recomendada (Riverpod/Bloc).
Entrégame un documento `architecture_design.md` con esta propuesta.
Prompt 1.2: Plan de Implementación (Skill: planning-with-files)
markdown
Usa la skill `planning-with-files` (Ruta: `C:\Users\Pruebas\Desktop\apps\telegram-bots\finanzas-personales\backend\.agent\skills\skills\planning-with-files\SKILL.md`).
Basado en la arquitectura aprobada, genera un plan de implementación detallado.
Crea un archivo `task.md` que desglose el proyecto en pasos atómicos:
- Configuración inicial.
- Creación de colecciones en Directus (usando MCP).
- Scaffold de la app Flutter.
- Implementación de Features (Auth, Dashboard, CRUD Transacciones).
- Verificación y Tests.
Asegúrate de que cada tarea sea lo suficientemente pequeña para ser ejecutada secuencialmente.
🔙 Categoría 2: Construcción del Backend (API & Directus)
Estos prompts se enfocan en usar el MCP de Directus para configurar el servidor.

Prompt 2.1: Creación de Esquema (Directus MCP)
markdown
Vamos a implementar el esquema de base de datos.
Usa las herramientas del MCP de Directus (`directus_create_collection`, `directus_create_field`, etc.) para crear la colección de **[Nombre de Colección, ej: 'transactions']**.
Campos requeridos:
- [Campo 1, ej: amount (decimal)]
- [Campo 2, ej: description (string)]
- [Campo 3, ej: date (datetime)]
- [Campo 4, ej: category_id (relation)]
Verifica primero si la colección ya existe usando `directus_list_collections` para evitar errores.
Prompt 2.2: Generación de Clases de Datos (Skill: mobile-developer)
markdown
Usa la skill `mobile-developer` (Ruta: `C:\Users\Pruebas\Desktop\apps\telegram-bots\finanzas-personales\backend\.agent\skills\skills\mobile-developer\SKILL.md`) y `flutter-expert` (Ruta: `C:\Users\Pruebas\Desktop\apps\telegram-bots\finanzas-personales\backend\.agent\skills\skills\flutter-expert\SKILL.md`).
Ahora que el esquema de Directus está listo, genera los modelos de datos en Dart (Flutter) para las colecciones creadas.
- Usa `json_serializable` y `freezed` si es adecuado.
- Crea los Repositorios que interactuarán con la API de Directus.
- Asegúrate de tipar estrictamente las respuestas.
🎨 Categoría 3: Diseño de Frontend y UI (Flutter)
Prompts para la construcción visual y lógica de la UI.

Prompt 3.1: Diseño Visual (Skill: ui-ux-pro-max + mobile-design)
markdown
Usa la skill `ui-ux-pro-max` (Ruta: `C:\Users\Pruebas\Desktop\apps\telegram-bots\finanzas-personales\backend\.agent\skills\skills\ui-ux-pro-max\SKILL.md`) y `mobile-design` (Ruta: `C:\Users\Pruebas\Desktop\apps\telegram-bots\finanzas-personales\backend\.agent\skills\skills\mobile-design\SKILL.md`).
Diseña la pantalla de **[Dashboard / Home]**.
- Estilo: Moderno, Minimalista, Dark Mode.
- Paleta de colores: [Definir o pedir sugerencia].
- Componentes: Gráficos de gastos, Lista de últimas transacciones, Resumen de saldo.
No generes código aún. Primero descríbeme los componentes visuales y la UX, y si puedes, usa la herramienta de generación de imágenes para crear un mockup o descríbelo detalladamente en texto para mi aprobación.
Prompt 3.2: Implementación de UI (Skill: mobile-developer + clean-code)
markdown
Usa la skill `mobile-developer`, `flutter-expert` y `clean-code` (Ruta: `C:\Users\Pruebas\Desktop\apps\telegram-bots\finanzas-personales\backend\.agent\skills\skills\clean-code\SKILL.md`).
Implementa el widget para **[Nombre del Componente, ej: TransactionList]** en Flutter.
- Usa `ListView.builder` para rendimiento.
- Implementa la lógica de estado usando [Riverpod/Bloc].
- Asegúrate de separar la lógica de la UI (no lógica de negocio dentro del método build).
- El código debe ser limpio, modular y seguir las guías de estilo de Dart.
🔒 Categoría 4: Seguridad y Optimización
Prompt 4.1: Revisión de Seguridad (Skill: security implícito / Best Practices)
markdown
Revisa la implementación actual de la autenticación y el manejo de datos.
1. ¿Estamos manejando los tokens de Directus de forma segura en el almacenamiento local del dispositivo (Flutter Secure Storage)?
2. Verifica si las reglas de permisos en Directus (Roles & Permissions) están configuradas correctamente vía MCP (o instrúyeme cómo verificarlas).
3. Analiza posibles vulnerabilidades en la inyección de dependencias.
Prompt 4.2: Optimización de Consultas (Skill: flutter-expert)
markdown
Usa la skill `flutter-expert`.
Analiza las consultas que estamos haciendo a Directus SDK en la app.
¿Podemos optimizar el `data fetching`?
- Sugiere el uso de filtros (`filter`) y selección de campos (`fields`) específicos en las peticiones API para no traer data innecesaria.
- Revisa si necesitamos implementar paginación en las listas largas.
🤖 Prompt General para Debugging (Skill: debugging-strategies)
markdown
Usa la skill `debugging-strategies` (Ruta: `C:\Users\Pruebas\Desktop\apps\telegram-bots\finanzas-personales\backend\.agent\skills\skills\debugging-strategies\SKILL.md`).
Estoy teniendo el siguiente error en la app:
[Pegar Error log aquí]
1. Analiza el Stack Trace.
2. Si es un error de API, usa el MCP de Directus para verificar el estado de los datos o logs recientes si es posible.
3. Propón una solución paso a paso siguiendo el método científico de debugging.