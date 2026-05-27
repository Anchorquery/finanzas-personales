import 'package:get/get.dart';
import 'package:quick_actions/quick_actions.dart';

import '../../routes/app_routes.dart';

/// Registers home-screen long-press shortcuts (Android/iOS) and routes
/// taps to the right view.
class QuickActionsService extends GetxService {
  final QuickActions _qa = const QuickActions();

  static const _addExpense = 'add_expense';
  static const _addIncome = 'add_income';
  static const _scanReceipt = 'scan_receipt';
  static const _openCoach = 'open_coach';

  Future<QuickActionsService> init() async {
    _qa.initialize(_handle);
    await _qa.setShortcutItems(const [
      ShortcutItem(
        type: _addExpense,
        localizedTitle: 'Nuevo gasto',
        icon: 'ic_quick_expense',
      ),
      ShortcutItem(
        type: _addIncome,
        localizedTitle: 'Nuevo ingreso',
        icon: 'ic_quick_income',
      ),
      ShortcutItem(
        type: _scanReceipt,
        localizedTitle: 'Escanear recibo',
        icon: 'ic_quick_scan',
      ),
      ShortcutItem(
        type: _openCoach,
        localizedTitle: 'Coach IA',
        icon: 'ic_quick_coach',
      ),
    ]);
    return this;
  }

  void _handle(String type) {
    switch (type) {
      case _addExpense:
        Get.toNamed(Routes.createTransaction, arguments: {'type': 'expense'});
        break;
      case _addIncome:
        Get.toNamed(Routes.createTransaction, arguments: {'type': 'income'});
        break;
      case _scanReceipt:
        Get.toNamed(Routes.scanReceipt);
        break;
      case _openCoach:
        Get.toNamed(Routes.aiCoach);
        break;
    }
  }
}
