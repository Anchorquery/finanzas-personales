import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../controllers/workspaces_controller.dart';

class CreateWorkspaceView extends GetView<WorkspacesController> {
  const CreateWorkspaceView({super.key});

  @override
  Widget build(BuildContext context) {
    // Asegurar limpieza de formulario al entrar
    // Nota: Idealmente esto iría en onInit o onReady de un binding específico para esta vista,
    // pero como usamos el mismo controlador, lo reseteamos aquí o al navegar.
    controller.newWorkspaceName.value = '';

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDark
        ? AppTheme.backgroundDark
        : Colors.white;
    final Color cardColor = isDark
        ? AppTheme.surfaceDark
        : const Color(0xFFF3F4F6);
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color hintColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 80,
        leading: TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'Cancel',
            style: TextStyle(color: hintColor, fontSize: 16),
          ),
        ),
        title: Text(
          AppL10n.of(context).createWorkspaceTitle,
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre del Espacio
            Text(
              'Nombre del Espacio',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: hintColor,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: (val) => controller.newWorkspaceName.value = val,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: 'e.g., Family Budget',
                hintStyle: TextStyle(color: hintColor.withValues(alpha: 0.7)),
                filled: true,
                fillColor: cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: Icon(Icons.edit, color: hintColor, size: 20),
                contentPadding: const EdgeInsets.all(20),
              ),
            ),
            const SizedBox(height: 32),

            // Icono Selection
            Text(
              'Icono',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: hintColor,
              ),
            ),
            const SizedBox(height: 16),
            const _IconSelector(),
            const SizedBox(height: 32),

            // Color de Acento
            Text(
              'Color de Acento',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: hintColor,
              ),
            ),
            const SizedBox(height: 16),
            const _ColorSelector(),
            const SizedBox(height: 48),

            // Espacio Compartido
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.group_outlined,
                      color: const Color(0xFF3B82F6), // Azul
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Espacio Compartido',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Invita a otros miembros',
                          style: TextStyle(fontSize: 14, color: hintColor),
                        ),
                      ],
                    ),
                  ),
                  Obx(
                    () => Switch(
                      value: controller.isShared.value,
                      onChanged: (val) => controller.isShared.value = val,
                      thumbColor: WidgetStateProperty.all(Colors.white),
                      trackColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return AppTheme.accentGreen;
                        }
                        return Colors.grey[600];
                      }),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Botón Crear
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => controller.createWorkspace(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGreen, // Emerald 500
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Crear Espacio',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconSelector extends GetView<WorkspacesController> {
  const _IconSelector();

  final List<IconData> icons = const [
    Icons.account_balance_wallet_outlined,
    Icons.savings_outlined,
    Icons.show_chart_rounded,
    Icons.credit_card_outlined,
    Icons.home_outlined,
    Icons.shopping_bag_outlined,
    Icons.flight_outlined,
    Icons.restaurant_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDark
        ? AppTheme.surfaceDark
        : const Color(0xFFF3F4F6);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: icons.length + 1,
      itemBuilder: (context, index) {
        if (index == icons.length) {
          // Botón ver más iconos
          return GestureDetector(
            onTap: () {
              Get.dialog(
                AlertDialog(
                  title: const Text('Seleccionar Icono'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: GridView.builder(
                      shrinkWrap: true,
                      itemCount: _extendedIcons.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                      itemBuilder: (context, index) {
                        final icon = _extendedIcons[index];
                        return GestureDetector(
                          onTap: () {
                            controller.selectedIconCode.value = icon.codePoint;
                            Get.back();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(icon, color: Colors.grey[600]),
                          ),
                        );
                      },
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.black12,
                ),
              ),
              child: Icon(
                Icons.add,
                color: isDark ? Colors.white70 : Colors.black54,
                size: 24,
              ),
            ),
          );
        }

        final icon = icons[index];
        return Obx(() {
          final isSelected =
              controller.selectedIconCode.value == icon.codePoint;
          return GestureDetector(
            onTap: () => controller.selectedIconCode.value = icon.codePoint,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF3B82F6) : cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF3B82F6)
                      : (isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.transparent),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black54),
                size: 24,
              ),
            ),
          );
        });
      },
    );
  }

  static const List<IconData> _extendedIcons = [
    Icons.account_balance,
    Icons.savings,
    Icons.attach_money,
    Icons.euro,
    Icons.shopping_cart,
    Icons.shopping_bag,
    Icons.store,
    Icons.business,
    Icons.work,
    Icons.badge,
    Icons.school,
    Icons.lightbulb,
    Icons.fitness_center,
    Icons.directions_car,
    Icons.flight,
    Icons.hotel,
    Icons.restaurant,
    Icons.local_cafe,
    Icons.local_bar,
    Icons.celebration,
    Icons.home,
    Icons.apartment,
    Icons.cottage,
    Icons.deck,
    Icons.pets,
    Icons.face,
    Icons.people,
    Icons.family_restroom,
    Icons.computer,
    Icons.phone_android,
    Icons.tv,
    Icons.gamepad,
    Icons.music_note,
    Icons.movie,
    Icons.book,
    Icons.palette,
  ];
}

class _ColorSelector extends GetView<WorkspacesController> {
  const _ColorSelector();

  final List<Color> colors = const [
    Color(0xFF3B82F6), // Blue 500
    Color(0xFFA855F7), // Purple 500
    Color(0xFFEC4899), // Pink 500
    Color(0xFFF97316), // Orange 500
    Color(0xFF22C55E), // Green 500
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: colors.length + 1, // +1 for the add button
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          if (index == colors.length) {
            // Add button
            return GestureDetector(
              onTap: () {
                // Mostrar selector de colores completo
                Get.dialog(
                  AlertDialog(
                    title: const Text('Seleccionar Color'),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: GridView.builder(
                        shrinkWrap: true,
                        itemCount: Colors.primaries.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                        itemBuilder: (context, index) {
                          final color = Colors.primaries[index];
                          return GestureDetector(
                            onTap: () {
                              controller.selectedColorValue.value = color
                                  .toARGB32();
                              Get.back();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancelar'),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.black54,
                ),
              ),
            );
          }

          final color = colors[index];
          return Obx(() {
            final isSelected =
                controller.selectedColorValue.value == color.toARGB32();
            return GestureDetector(
              onTap: () =>
                  controller.selectedColorValue.value = color.toARGB32(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 3,
                        )
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withValues(alpha: 0.2)
                                : Colors.black.withValues(alpha: 0.2),
                            blurRadius: 0,
                            spreadRadius: 1, // Outer ring simulation
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 24)
                    : null,
              ),
            );
          });
        },
      ),
    );
  }
}
