import 'package:app_finanzas_mobile/data/models/finance/category.dart';
import 'package:app_finanzas_mobile/modules/setup/controllers/setup_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'findBudgetCategory usa categorias globales cuando no existe una local',
    () {
      final category = SetupController.findBudgetCategory(
        <Category>[
          Category(id: 'cat-1', name: 'Alimentación', type: 'expense'),
          Category(id: 'cat-2', name: 'Transporte', type: 'expense'),
        ],
        'Alimentación',
        'ws-1',
      );

      expect(category?.id, 'cat-1');
    },
  );

  test('findBudgetCategory prioriza la categoria local sobre la global', () {
    final category = SetupController.findBudgetCategory(
      <Category>[
        Category(id: 'cat-global', name: 'Alimentación', type: 'expense'),
        Category(
          id: 'cat-local',
          name: 'Alimentación',
          type: 'expense',
          workspaceId: 'ws-1',
        ),
      ],
      'Alimentación',
      'ws-1',
    );

    expect(category?.id, 'cat-local');
  });
}
