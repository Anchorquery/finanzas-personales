part of '../directus_service.dart';

extension DirectusSavingExtension on DirectusService {
  Future<List<Saving>> getSavings(String workspaceId) async {
    const String readSavings = r'''
      query ReadSavings($workspaceId: ID!) {
        savings(
          filter: { workspace: { id: { _eq: $workspaceId } } }
          sort: ["name"]
        ) {
          id
          name
          target_amount
          current_amount
          icon
          target_date
        }
      }
    ''';

    final result = await query(
      readSavings,
      variables: {'workspaceId': workspaceId},
    );
    if (result.hasException) throw result.exception!;
    final data = result.data?['savings'] as List<dynamic>? ?? [];
    return data.map((e) => Saving.fromJson(e)).toList();
  }

  Future<void> createSavingGoal({
    required String name,
    required double targetAmount,
    required String workspaceId,
    String? icon,
    DateTime? targetDate,
  }) async {
    final Map<String, dynamic> data = {
      'name': name,
      'target_amount': targetAmount,
      'current_amount': 0,
      'workspace': workspaceId,
    };
    if (icon != null && icon.isNotEmpty) {
      data['icon'] = icon;
    }
    if (targetDate != null) {
      data['target_date'] = targetDate.toIso8601String();
    }

    final result = await createItemViaRest('savings', data);
    if (result == null) {
      throw Exception('Failed to create saving goal via REST');
    }
  }

  Future<void> updateSavingGoal({
    required String id,
    String? name,
    double? targetAmount,
    String? icon,
    DateTime? targetDate,
  }) async {
    const String mutation = r'''
      mutation UpdateSaving($id: ID!, $data: update_savings_input!) {
        update_savings_item(id: $id, data: $data) {
          id
        }
      }
    ''';

    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (targetAmount != null) data['target_amount'] = targetAmount;
    if (icon != null) data['icon'] = icon;
    if (targetDate != null) data['target_date'] = targetDate.toIso8601String();

    final result = await mutate(mutation, variables: {'id': id, 'data': data});
    if (result.hasException) {
      Get.log(
        '[DIRECTUS] Error updating saving goal (GQL): ${result.exception}',
      );
      throw result.exception!;
    }
  }

  Future<void> addSavingContribution(
    String goalId,
    double amount,
    double currentTotal,
  ) async {
    const String updateSaving = r'''
      mutation AddContribution($id: ID!, $newAmount: Float!) {
        update_savings_item(id: $id, data: { current_amount: $newAmount }) {
          id
        }
      }
    ''';

    final result = await mutate(
      updateSaving,
      variables: {'id': goalId, 'newAmount': currentTotal + amount},
    );

    if (result.hasException) throw result.exception!;
  }

  Future<List<Map<String, dynamic>>> getSavingContributions(
    String goalId,
  ) async {
    // Note: This matches the schema if there's a m2m or o2m relation.
    // Assuming contributions are transactions linked to the saving goal.
    const String readContributions = r'''
      query ReadContributions($goalId: ID!) {
        transactions(filter: { saving_goal: { id: { _eq: $goalId } } }, sort: ["-date"]) {
          id
          amount
          date
          concept
        }
      }
    ''';

    final result = await query(
      readContributions,
      variables: {'goalId': goalId},
    );
    if (result.hasException) throw result.exception!;
    return List<Map<String, dynamic>>.from(result.data?['transactions'] ?? []);
  }
}
