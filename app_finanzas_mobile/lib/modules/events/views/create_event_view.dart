import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/snackbar_service.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../controllers/events_controller.dart';

class CreateEventView extends GetView<EventsController> {
  const CreateEventView({super.key});

  @override
  Widget build(BuildContext context) {
    return _CreateEventForm();
  }
}

class _CreateEventForm extends StatefulWidget {
  @override
  _CreateEventFormState createState() => _CreateEventFormState();
}

class _CreateEventFormState extends State<_CreateEventForm> {
  final EventsController controller = Get.find();
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final budgetCtrl = TextEditingController();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 7));
  bool _isCreating = false;

  @override
  void dispose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    budgetCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isCreating) return;
    final name = nameCtrl.text.trim();
    final budget = double.tryParse(budgetCtrl.text) ?? 0.0;
    if (name.isEmpty || budget <= 0) {
      SnackbarService.showWarning(
        'Error',
        'Nombre inválido o presupuesto nulo',
      );
      return;
    }
    if (endDate.isBefore(startDate)) {
      SnackbarService.showWarning(
          'Error', 'La fecha fin no puede ser anterior al inicio');
      return;
    }
    setState(() => _isCreating = true);
    try {
      await controller.createEvent(
        name,
        descCtrl.text.trim(),
        startDate,
        endDate,
        budget,
      );
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppL10n.of(context).createEventTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre del Evento',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: budgetCtrl,
              decoration: const InputDecoration(
                labelText: 'Presupuesto Total',
                border: OutlineInputBorder(),
                prefixText: '\$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      'Inicio: ${DateFormat('yyyy-MM-dd').format(startDate)}',
                    ),
                    onPressed: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: startDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (d != null) setState(() => startDate = d);
                    },
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      'Fin: ${DateFormat('yyyy-MM-dd').format(endDate)}',
                    ),
                    onPressed: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: endDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (d != null) setState(() => endDate = d);
                    },
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isCreating ? null : _submit,
                child: _isCreating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Crear Evento'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
