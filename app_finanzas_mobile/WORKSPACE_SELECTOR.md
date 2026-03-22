# Selector de Workspace - Documentación

## Descripción General

Se ha implementado un sistema completo de selección de workspaces con un modal que replica exactamente el diseño del mockup proporcionado.

## Archivos Creados

### Modelos
- **`lib/data/models/workspace.dart`**: Modelo de datos para workspaces con tipos (Personal, Familia, Negocio)

### Widgets
- **`lib/core/widgets/workspaces/workspace_selector_modal.dart`**: Modal principal para seleccionar workspace
- **`lib/core/widgets/workspaces/workspace_list_item.dart`**: Widget de cada ítem en la lista
- **`lib/core/widgets/workspaces/workspaces_widgets.dart`**: Archivo índice para exportaciones

### Controlador y Vista
- **`lib/modules/workspaces/controllers/workspaces_controller.dart`**: Controlador actualizado con gestión completa
- **`lib/modules/workspaces/views/workspaces_view.dart`**: Vista funcional con workspace activo

## Características Implementadas

### Modal Selector
✅ Diseño exacto 1:1 con el mockup
✅ Handle superior para indicar que es un bottom sheet
✅ Header con título "Cambiar Espacio" y botón X
✅ Lista de workspaces con diseño personalizado
✅ Botón azul "Crear Nuevo Espacio" al final
✅ Animación slide-up desde abajo
✅ Soporte para modo claro y oscuro

### Items de Workspace
✅ Icono circular a la izquierda según tipo:
  - Personal: `Icons.person` (azul)
  - Familia: `Icons.people` (violeta)
  - Negocio: `Icons.business_center` (gris)
✅ Nombre y descripción del workspace
✅ Check verde si está activo
✅ Flecha derecha si no está activo
✅ Borde verde brillante para el workspace activo
✅ Efecto hover/tap con InkWell

### Funcionalidad
✅ Selección de workspace con actualización en tiempo real
✅ Cierre automático del modal al seleccionar
✅ Snackbar de confirmación al cambiar workspace
✅ Lista de workspaces observable (GetX)
✅ Persistencia del workspace activo en memoria

## Cómo Usar

### Abrir el Modal desde cualquier lugar

\`\`\`dart
import 'package:get/get.dart';
import 'package:app_finanzas_mobile/modules/workspaces/controllers/workspaces_controller.dart';

// Dentro de un widget con context
final controller = Get.find<WorkspacesController>();
controller.showWorkspaceSelector(context);
\`\`\`

### Navegar a la vista de Workspaces

La ruta ya está configurada en GetX:

\`\`\`dart
Get.toNamed('/workspaces');
\`\`\`

### Obtener el Workspace Activo

\`\`\`dart
final controller = Get.find<WorkspacesController>();
final activeWorkspace = controller.activeWorkspace;

if (activeWorkspace != null) {
  print('Workspace actual: \${activeWorkspace.name}');
}
\`\`\`

## Próximos Pasos (TODO)

### 1. Integración con Directus
- [ ] Crear endpoints en Directus para workspaces
- [ ] Implementar `getWorkspaces()` en `directus_service.dart`
- [ ] Implementar `switchWorkspace()` en `directus_service.dart`
- [ ] Reemplazar datos de ejemplo por datos reales

### 2. Persistencia
- [ ] Guardar workspace seleccionado en SharedPreferences
- [ ] Cargar workspace al iniciar la app
- [ ] Sincronizar con backend

### 3. Funcionalidad Adicional
- [ ] Implementar creación de workspace
- [ ] Implementar edición de workspace
- [ ] Implementar eliminación de workspace
- [ ] Gestión de miembros para workspaces de familia/negocio

### 4. Integración con el Dashboard
- [ ] Añadir botón de cambio de workspace en el header del dashboard
- [ ] Filtrar datos según workspace activo
- [ ] Actualizar estadísticas por workspace

## Diseño y Colores

El diseño sigue exactamente el mockup con estos colores:

- **Background modal (dark)**: `#1A1D2E`
- **Background items (dark)**: `#1E2030` (surfaceDark)
- **Borde activo**: `#34D399` (verde esmeralda)
- **Borde inactivo**: `#2D303E` (gris oscuro)
- **Botón principal**: `#2B4BEE` (azul primary)
- **Check activo**: `#34D399` (verde)

## Testing

Para probar la funcionalidad:

1. Ejecutar la app: `flutter run`
2. Navegar a la sección de workspaces
3. Presionar "Cambiar Workspace"
4. Seleccionar un workspace diferente
5. Verificar que se actualiza correctamente
6. Verificar que el diseño coincide con el mockup

## Notas Técnicas

- Usa **GetX** para gestión de estado
- Implementa **Material 3**
- Soporta **modo claro y oscuro**
- Usa **Google Fonts (Inter)**
- Componentes **completamente funcionales**
- Diseño **responsive** y adaptable
