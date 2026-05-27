import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../routes/app_routes.dart';
import '../controllers/events_controller.dart';
import '../../../data/models/finance/event.dart';

class EventsView extends GetView<EventsController> {
  const EventsView({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.eventsTitle),
        actions: [
          IconButton(
            tooltip: t.eventsAdd,
            icon: const Icon(Icons.add),
            onPressed: () => Get.toNamed(Routes.createEvent),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.events.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.event_busy, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No hay eventos activos.\n¡Crea uno para organizar tus gastos de viaje!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Get.toNamed(Routes.createEvent),
                  icon: const Icon(Icons.add),
                  label: const Text('Crear Evento'),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: controller.events.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final event = controller.events[index];
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.flight_takeoff,
                    color: AppTheme.primaryColor,
                  ),
                ),
                title: Text(
                  event.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      '${event.startDate?.toIso8601String().split('T')[0] ?? ''} - ${event.endDate?.toIso8601String().split('T')[0] ?? ''}',
                    ),
                    if (event.description.isNotEmpty)
                      Text(
                        event.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${event.budget}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                        fontSize: 16,
                      ),
                    ),
                    const Text('Presupuesto', style: TextStyle(fontSize: 12)),
                  ],
                ),
                onTap: () => _showEventDetail(context, event),
              ),
            );
          },
        );
      }),
    );
  }

  void _showEventDetail(BuildContext context, Event event) {
    final start = event.startDate?.toIso8601String().split('T')[0] ?? 'Sin fecha';
    final end = event.endDate?.toIso8601String().split('T')[0] ?? 'Sin fecha';

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.flight_takeoff, color: AppTheme.primaryColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    event.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (event.description.isNotEmpty) ...[
              const Text('Descripción', style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1)),
              const SizedBox(height: 6),
              Text(event.description, style: const TextStyle(color: Colors.white, fontSize: 15)),
              const SizedBox(height: 20),
            ],
            Row(
              children: [
                _detailChip(Icons.calendar_today_outlined, 'Inicio', start),
                const SizedBox(width: 12),
                _detailChip(Icons.event_available_outlined, 'Fin', end),
              ],
            ),
            const SizedBox(height: 16),
            _detailChip(
              Icons.attach_money_rounded,
              'Presupuesto',
              '\$${event.budget.toStringAsFixed(2)}',
              color: AppTheme.accentGreen,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cerrar', style: TextStyle(color: Colors.white70)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      Get.toNamed(Routes.createEvent);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Nuevo Evento', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  Widget _detailChip(IconData icon, String label, String value, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color ?? Colors.white54),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
              Text(value, style: TextStyle(color: color ?? Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
