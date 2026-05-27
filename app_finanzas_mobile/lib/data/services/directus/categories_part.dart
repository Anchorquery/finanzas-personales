part of '../directus_service.dart';

extension DirectusCategoryExtension on DirectusService {
  static const Map<String, List<Map<String, String>>> _templateCategories = {
    'standard': [
      {
        'name': 'Alimentación',
        'icon': 'restaurant',
        'color': '#FF5252',
        'type': 'expense',
      },
      {
        'name': 'Transporte',
        'icon': 'directions_car',
        'color': '#448AFF',
        'type': 'expense',
      },
      {
        'name': 'Vivienda',
        'icon': 'home',
        'color': '#4CAF50',
        'type': 'expense',
      },
      {
        'name': 'Salud',
        'icon': 'medical_services',
        'color': '#E91E63',
        'type': 'expense',
      },
      {
        'name': 'Ocio',
        'icon': 'sports_esports',
        'color': '#FFB300',
        'type': 'expense',
      },
      {
        'name': 'Salario',
        'icon': 'payments',
        'color': '#00C853',
        'type': 'income',
      },
    ],
    'student': [
      {
        'name': 'Alimentación',
        'icon': 'restaurant',
        'color': '#FF5252',
        'type': 'expense',
      },
      {
        'name': 'Transporte',
        'icon': 'directions_bus',
        'color': '#448AFF',
        'type': 'expense',
      },
      {
        'name': 'Estudios',
        'icon': 'school',
        'color': '#7C4DFF',
        'type': 'expense',
      },
      {
        'name': 'Tecnología',
        'icon': 'laptop_mac',
        'color': '#00ACC1',
        'type': 'expense',
      },
      {
        'name': 'Ocio',
        'icon': 'sports_esports',
        'color': '#FFB300',
        'type': 'expense',
      },
      {
        'name': 'Beca',
        'icon': 'workspace_premium',
        'color': '#00C853',
        'type': 'income',
      },
    ],
    'business': [
      {
        'name': 'Nómina',
        'icon': 'badge',
        'color': '#5E35B1',
        'type': 'expense',
      },
      {
        'name': 'Operaciones',
        'icon': 'factory',
        'color': '#546E7A',
        'type': 'expense',
      },
      {
        'name': 'Marketing',
        'icon': 'campaign',
        'color': '#FB8C00',
        'type': 'expense',
      },
      {
        'name': 'Impuestos',
        'icon': 'receipt_long',
        'color': '#E53935',
        'type': 'expense',
      },
      {
        'name': 'Software',
        'icon': 'terminal',
        'color': '#00897B',
        'type': 'expense',
      },
      {
        'name': 'Ventas',
        'icon': 'trending_up',
        'color': '#00C853',
        'type': 'income',
      },
    ],
  };

  Future<List<Category>> getCategories({String? workspaceId}) async {
    const String readCategories = r'''
      query ReadCategories($filter: categories_filter) {
        categories(filter: $filter, sort: ["name"]) {
          id
          name
          icon
          color
          type
          workspace {
            id
          }
        }
      }
    ''';

    final effectiveWorkspaceId =
        workspaceId ?? Get.find<WorkspacesController>().activeWorkspace?.id;

    Map<String, dynamic> filter = {
      '_or': <Map<String, dynamic>>[
        {
          'workspace': {
            'id': {'_null': true},
          },
        },
      ],
    };

    if (effectiveWorkspaceId != null) {
      filter['_or'].add({
        'workspace': {
          'id': {'_eq': effectiveWorkspaceId},
        },
      });
    }

    final result = await query(readCategories, variables: {'filter': filter});
    if (result.hasException) throw result.exception!;
    final data = result.data?['categories'] as List<dynamic>? ?? [];
    return data.map((e) => Category.fromJson(e)).toList();
  }

  Future<void> createCategory({
    required String name,
    required String type,
    String? icon,
    String? color,
    String? workspaceId,
  }) async {
    const String mutation = r'''
      mutation CreateCategory($data: create_categories_input!) {
        create_categories_item(data: $data) {
          id
        }
      }
    ''';

    final effectiveWorkspaceId =
        workspaceId ?? Get.find<WorkspacesController>().activeWorkspace?.id;

    final Map<String, dynamic> data = {
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
    };

    if (effectiveWorkspaceId != null) {
      data['workspace'] = {'id': effectiveWorkspaceId};
    }

    final result = await mutate(mutation, variables: {'data': data});
    if (result.hasException) {
      Get.log('[DIRECTUS] Error creating category: ${result.exception}');
      final created = await createItemViaRest('categories', data);
      if (created == null) {
        throw result.exception!;
      }
    }
  }

  Future<void> seedBaseCategories(String workspaceId) async {
    await seedTemplateCategories(workspaceId, 'standard');
  }

  Future<void> seedTemplateCategories(
    String workspaceId, [
    String? template,
  ]) async {
    final templateCategories =
        _templateCategories[template ?? 'standard'] ??
        _templateCategories['standard']!;
    final existingCategories = await getCategories(workspaceId: workspaceId);
    final existingNames = existingCategories
        .map((category) => category.name.toLowerCase())
        .toSet();

    for (final category in templateCategories) {
      final categoryName = category['name'];
      if (categoryName == null ||
          existingNames.contains(categoryName.toLowerCase())) {
        continue;
      }
      await createBaseCategory(category, workspaceId);
    }
  }

  Future<void> createBaseCategory(
    Map<String, dynamic> data,
    String workspaceId,
  ) async {
    const String mutation = r'''
      mutation CreateCategory($data: create_categories_input!) {
        create_categories_item(data: $data) {
          id
        }
      }
    ''';

    final Map<String, dynamic> mutationData = {
      ...data,
      'workspace': {'id': workspaceId},
    };
    final result = await mutate(mutation, variables: {'data': mutationData});
    if (result.hasException) {
      Get.log('[DIRECTUS] Error creating base category: ${result.exception}');
      final created = await createItemViaRest('categories', mutationData);
      if (created == null) {
        throw result.exception!;
      }
    }
  }
}
