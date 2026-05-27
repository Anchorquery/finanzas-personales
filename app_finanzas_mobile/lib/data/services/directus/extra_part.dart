part of '../directus_service.dart';

extension DirectusExtraExtension on DirectusService {
  // --- EVENTS ---
  Future<List<Event>> getEvents({String? workspaceId}) async {
    // Current schema doesn't have workspace field in events.
    // Filtering by user_created might be an alternative, but for now we fetch all.
    const String queryStr = r'''
      query GetEvents {
        events {
          id
          name
          start_date
          end_date
          budget_limit
          status
        }
      }
    ''';
    final result = await query(queryStr);
    if (result.hasException) throw result.exception!;
    final List data = result.data?['events'] ?? [];
    return data
        .map(
          (e) => Event.fromJson({
            ...e,
            'budget': e['budget_limit'], // Map to model field
          }),
        )
        .toList();
  }

  Future<void> createEvent({
    required String name,
    required String description,
    required String startDate,
    required String endDate,
    required double budget,
    required String workspaceId,
  }) async {
    const String mutation = r'''
      mutation CreateEvent($data: create_events_input!) {
        create_events_item(data: $data) {
          id
        }
      }
    ''';
    final Map<String, dynamic> variables = {
      'name': name,
      // 'description' and 'workspace' removed as they are missing in current schema
      'start_date': startDate,
      'end_date': endDate,
      'budget_limit': budget,
      'status': 'active', // 'published' is not a choice in schema, 'active' is.
    };

    final result = await mutate(mutation, variables: {'data': variables});
    if (result.hasException) throw result.exception!;
  }

  Future<void> updateEvent(String id, Map<String, dynamic> data) async {
    const String mutation = r'''
      mutation UpdateEvent($id: ID!, $data: update_events_input!) {
        update_events_item(id: $id, data: $data) { id }
      }
    ''';
    final result = await mutate(mutation, variables: {'id': id, 'data': data});
    if (result.hasException) {
      final updated = await updateItemViaRest('events', id, data);
      if (updated == null) throw result.exception!;
    }
  }

  Future<void> deleteEvent(String id) async {
    const String mutation = r'''
      mutation DeleteEvent($id: ID!) {
        delete_events_item(id: $id) { id }
      }
    ''';
    final result = await mutate(mutation, variables: {'id': id});
    if (result.hasException) {
      final deleted = await deleteItemViaRest('events', id);
      if (!deleted) throw result.exception!;
    }
  }

  // --- SUBSCRIPTIONS ---
  Future<List<Subscription>> getSubscriptions({String? workspaceId}) async {
    // Current schema doesn't have workspace field in subscriptions directly.
    const String queryStr = r'''
      query GetSubscriptions {
        subscriptions {
          id
          name
          amount
          billing_cycle
          next_billing_date
          currency
          is_active
        }
      }
    ''';
    final result = await query(queryStr);
    if (result.hasException) {
      Get.log('[DIRECTUS] Error in getSubscriptions: ${result.exception}');
      return [];
    }
    final List data = result.data?['subscriptions'] ?? [];
    return data.map((e) => Subscription.fromJson(e)).toList();
  }

  Future<void> addSubscription(Map<String, dynamic> data) async {
    const String mutation = r'''
      mutation AddSubscription($data: create_subscriptions_input!) {
        create_subscriptions_item(data: $data) {
          id
        }
      }
    ''';
    final Map<String, dynamic> variables = Map.from(data);
    // Remove fields not present in schema
    variables.remove('workspace');
    variables.remove('provider');
    variables.remove('day');
    variables.remove('id'); // ID is auto-generated

    if (variables.containsKey('category') && variables['category'] is String) {
      variables['category'] = {'id': variables['category']};
    }

    final result = await mutate(mutation, variables: {'data': variables});
    if (result.hasException) throw result.exception!;
  }

  Future<void> updateSubscription(String id, Map<String, dynamic> data) async {
    const String mutation = r'''
      mutation UpdateSubscription($id: ID!, $data: update_subscriptions_input!) {
        update_subscriptions_item(id: $id, data: $data) { id }
      }
    ''';
    final result = await mutate(mutation, variables: {'id': id, 'data': data});
    if (result.hasException) {
      final updated = await updateItemViaRest('subscriptions', id, data);
      if (updated == null) throw result.exception!;
    }
  }

  Future<void> deleteSubscription(String id) async {
    const String mutation = r'''
      mutation DeleteSubscription($id: ID!) {
        delete_subscriptions_item(id: $id) { id }
      }
    ''';
    final result = await mutate(mutation, variables: {'id': id});
    if (result.hasException) {
      final deleted = await deleteItemViaRest('subscriptions', id);
      if (!deleted) throw result.exception!;
    }
  }

  // --- INVITATIONS ---
  Future<List<Invitation>> getPendingInvitations([String? email]) async {
    const String queryStr = r'''
      query GetPendingInvitations($filter: invitations_filter) {
        invitations(filter: $filter) {
          id
          email
          role
          status
          organization { id name }
          date_created
        }
      }
    ''';

    final Map<String, dynamic> filter = {
      'status': {'_eq': 'pending'},
    };

    if (email != null) {
      filter['email'] = {'_eq': email};
    }

    final result = await query(queryStr, variables: {'filter': filter});
    if (result.hasException) return [];
    final data = result.data?['invitations'] as List<dynamic>? ?? [];
    return data.map((e) => Invitation.fromJson(e)).toList();
  }

  Future<void> createInvitation(
    String email, [
    String? orgId,
    String? role,
    String? workspaceId,
  ]) async {
    const String mutation = r'''
      mutation CreateInvitation($data: create_invitations_input!) {
        create_invitations_item(data: $data) {
          id
        }
      }
    ''';
    final Map<String, dynamic> variables = {
      'email': email,
      'role': role ?? 'member',
      'status': 'pending',
    };
    if (orgId != null) variables['organization'] = {'id': orgId};
    // workspace removed as it is missing in invitations schema

    final result = await mutate(mutation, variables: {'data': variables});
    if (result.hasException) throw result.exception!;
  }

  Future<void> acceptInvitation(String id) async {
    await updateInvitationStatus(id, 'accepted');
  }

  Future<void> updateInvitationStatus(String id, String status) async {
    const String mutation = r'''
      mutation UpdateInvitationStatus($id: ID!, $status: String!) {
        update_invitations_item(id: $id, data: { status: $status }) {
          id
        }
      }
    ''';
    final result = await mutate(
      mutation,
      variables: {'id': id, 'status': status},
    );
    if (result.hasException) throw result.exception!;
  }

  Future<void> deleteInvitation(String id) async {
    const String mutation = r'''
      mutation DeleteInvitation($id: ID!) {
        delete_invitations_item(id: $id) {
          id
        }
      }
    ''';
    final result = await mutate(mutation, variables: {'id': id});
    if (result.hasException) throw result.exception!;
  }

  Future<List<Map<String, dynamic>>> getOrganizationMembers(
    String orgId,
  ) async {
    const String queryStr = r'''
      query GetOrgMembers($orgId: ID!) {
        organization_members(filter: { organization: { id: { _eq: $orgId } } }) {
          id
          role
          user {
            id
            first_name
            last_name
            email
            avatar { id }
          }
        }
      }
    ''';
    final result = await query(queryStr, variables: {'orgId': orgId});
    if (result.hasException) return [];
    return List<Map<String, dynamic>>.from(
      result.data?['organization_members'] ?? [],
    );
  }

  Future<bool> addMemberToOrganization(
    String orgId,
    String userId,
    String role,
  ) async {
    const String mutation = r'''
      mutation AddMember($orgId: ID!, $userId: ID!, $role: String!) {
        create_organization_members_item(data: {
          organization: { id: $orgId },
          user: { id: $userId },
          role: $role
        }) {
          id
        }
      }
    ''';
    final result = await mutate(
      mutation,
      variables: {'orgId': orgId, 'userId': userId, 'role': role},
    );
    return !result.hasException;
  }

  // --- SAVINGS EXTRA ---
  Future<List<Transaction>> getSavingTransactions(String goalId) async {
    const String queryStr = r'''
      query GetSavingTransactions($goalId: ID!) {
        saving_transactions(filter: { goal: { id: { _eq: $goalId } } }, sort: ["-date_created"]) {
          id
          amount
          type
          date_created
        }
      }
    ''';
    final result = await query(queryStr, variables: {'goalId': goalId});
    if (result.hasException) return [];
    final List data = result.data?['saving_transactions'] ?? [];
    // Normalizar campos de saving_transaction al esquema de Transaction
    return data.map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      // date_created -> date para que Transaction.fromJson lo parsee
      map['date'] = map['date_created'] ?? DateTime.now().toIso8601String();
      map['concept'] = map['type'] == 'contribution' ? 'Aporte a ahorro' : 'Retiro de ahorro';
      return Transaction.fromJson(map);
    }).toList();
  }

  Future<void> addSavingFund(
    String goalId,
    double amount, [
    String? workspaceId,
  ]) async {
    const String mutation = r'''
      mutation AddSavingFund($data: create_saving_transactions_input!) {
        create_saving_transactions_item(data: $data) {
          id
        }
      }
    ''';
    final Map<String, dynamic> data = {
      'goal': {'id': goalId},
      'amount': amount,
      'type': 'contribution',
    };
    if (workspaceId != null) data['workspace'] = {'id': workspaceId};

    final result = await mutate(mutation, variables: {'data': data});
    if (result.hasException) throw result.exception!;
  }

  Future<void> withdrawSavingFund({
    required String id,
    required double amount,
    String? workspaceId,
  }) async {
    const String mutation = r'''
      mutation WithdrawSavingFund($data: create_saving_transactions_input!) {
        create_saving_transactions_item(data: $data) {
          id
        }
      }
    ''';
    final Map<String, dynamic> data = {
      'goal': {'id': id},
      'amount': amount,
      'type': 'withdrawal',
    };
    if (workspaceId != null) data['workspace'] = {'id': workspaceId};
    final result = await mutate(mutation, variables: {'data': data});
    if (result.hasException) throw result.exception!;
  }

  Future<void> deleteSavingGoal(String id) async {
    const String mutation = r'''
      mutation DeleteSavingGoal($id: ID!) {
        delete_savings_item(id: $id) {
          id
        }
      }
    ''';
    final result = await mutate(mutation, variables: {'id': id});
    if (result.hasException) throw result.exception!;
  }

  // --- SETTINGS ---
  Future<Map<String, dynamic>?> getOrganizationSettings(String orgId) async {
    const String queryStr = r'''
      query GetOrgSettings($orgId: ID!) {
        organization_settings(filter: { organization_id: { id: { _eq: $orgId } } }, limit: 1) {
          id
          gemini_api_key
          ai_enabled
          usage_limit_usd
        }
      }
    ''';
    final result = await query(queryStr, variables: {'orgId': orgId});
    if (result.hasException) return null;
    final List list = result.data?['organization_settings'] ?? [];
    if (list.isEmpty) return null;
    return list.first;
  }

  Future<void> createOrganizationSettings(
    String orgId, {
    String? apiKey,
    bool? aiEnabled,
  }) async {
    const String mutation = r'''
      mutation CreateSettings($data: create_organization_settings_input!) {
        create_organization_settings_item(data: $data) {
          id
        }
      }
    ''';
    final Map<String, dynamic> data = {
      'organization_id': {'id': orgId},
      'gemini_api_key': apiKey,
      'ai_enabled': aiEnabled,
    };
    final result = await mutate(mutation, variables: {'data': data});
    if (result.hasException) throw result.exception!;
  }

  Future<void> updateOrganizationSettings(
    String settingId,
    Map<String, dynamic> data,
  ) async {
    const String mutation = r'''
      mutation UpdateSettings($id: ID!, $data: update_organization_settings_input!) {
        update_organization_settings_item(id: $id, data: $data) {
          id
        }
      }
    ''';
    final result = await mutate(mutation, variables: {'id': settingId, 'data': data});
    if (result.hasException) throw result.exception!;
  }

  Future<void> initializeWorkspaceCategories(
    String workspaceId, [
    String? template,
  ]) async {
    await seedTemplateCategories(workspaceId, template ?? 'standard');
  }

  // --- ORGANIZATIONS ---
  Future<List<Organization>> getUserOrganizations() async {
    const String queryStr = r'''
      query GetOrganizations {
        organizations {
          id
          name
          owner { id }
        }
      }
    ''';

    final result = await query(queryStr);
    if (result.hasException) {
      throw result.exception!;
    }
    final data = result.data?['organizations'] as List<dynamic>? ?? [];
    return data.map((e) => Organization.fromJson(e)).toList();
  }

  Future<Organization> createOrganization(
    String name, {
    String? description,
  }) async {
    const String mutation = r'''
      mutation CreateOrganization($data: create_organizations_input!) {
        create_organizations_item(data: $data) {
          id
          name
        }
      }
    ''';

    final result = await mutate(
      mutation,
      variables: {
        'data': {'name': name, 'description': description},
      },
    );

    if (result.hasException) throw result.exception!;
    return Organization.fromJson(result.data!['create_organizations_item']);
  }

  Future<Map<String, dynamic>> getInitialDataStatus() async {
    await getCurrentUser();
    Get.log('[DIRECTUS] getInitialDataStatus: getting organizations...');
    final orgs = await getUserOrganizations();
    Get.log('[DIRECTUS] getInitialDataStatus: orgs count: ${orgs.length}');
    if (orgs.isEmpty) {
      Get.log(
        '[DIRECTUS] getInitialDataStatus: no orgs, checking invitations...',
      );
      final invs = await getPendingInvitations();
      Get.log(
        '[DIRECTUS] getInitialDataStatus: invitations count: ${invs.length}',
      );
      return {
        'hasOrg': false,
        'hasWorkspace': false,
        'hasInvitations': invs.isNotEmpty,
      };
    }

    String? orgWithCompleteSetup;
    String? orgNeedingSetup;
    String? workspaceNeedingSetup;

    for (var org in orgs) {
      Get.log(
        '[DIRECTUS] getInitialDataStatus: checking workspaces for org ${org.id} (${org.name})...',
      );
      final workspaces = await getWorkspaces(organizationId: org.id);

      if (workspaces.isEmpty) {
        orgNeedingSetup ??= org.id;
        continue;
      }

      for (final workspace in workspaces) {
        final accounts = await getAccounts(workspaceId: workspace.id);
        final incomePlans = await getIncomePlans(workspaceId: workspace.id);
        final hasAccount = accounts.isNotEmpty;
        final hasIncomePlan = incomePlans.isNotEmpty;

        if (hasAccount && hasIncomePlan) {
          Get.log(
            '[DIRECTUS] getInitialDataStatus: found complete workspace ${workspace.id} in org ${org.id}',
          );
          orgWithCompleteSetup = org.id;
          break;
        }

        orgNeedingSetup ??= org.id;
        workspaceNeedingSetup ??= workspace.id;
      }

      if (orgWithCompleteSetup != null) {
        break;
      }
    }

    return {
      'hasOrg': true,
      'hasWorkspace':
          orgWithCompleteSetup != null || workspaceNeedingSetup != null,
      'hasAccount': orgWithCompleteSetup != null,
      'hasIncomePlan': orgWithCompleteSetup != null,
      'orgWithCompleteSetup': orgWithCompleteSetup,
      'orgNeedingSetup': orgNeedingSetup,
      'workspaceNeedingSetup': workspaceNeedingSetup,
      'hasInvitations': false,
    };
  }

  Future<void> updateOrganization(String id, Map<String, dynamic> data) async {
    const String mutation = r'''
      mutation UpdateOrganization($id: ID!, $data: update_organizations_input!) {
        update_organizations_item(id: $id, data: $data) {
          id
        }
      }
    ''';
    final result = await mutate(mutation, variables: {'id': id, 'data': data});
    if (result.hasException) throw result.exception!;
  }

  Future<Organization?> getOrganization([String? id]) async {
    const String queryStr = r'''
      query GetOrganization($filter: organizations_filter) {
        organizations(filter: $filter, limit: 1) {
          id
          name
          owner {
            id
          }
        }
      }
    ''';

    final variables = id != null
        ? {
            'filter': {
              'id': {'_eq': id},
            },
          }
        : null;

    final result = await query(queryStr, variables: variables);
    if (result.hasException || result.data?['organizations'] == null) {
      return null;
    }

    final list = result.data!['organizations'] as List;
    if (list.isEmpty) return null;

    return Organization.fromJson(list.first);
  }

  // --- RECURRING PAYMENTS ---
  Future<void> payRecurring(
    String name,
    double amount, [
    String? workspaceId,
    String? categoryId,
  ]) async {
    final effectiveWsId =
        workspaceId ?? Get.find<WorkspacesController>().activeWorkspace?.id;
    if (effectiveWsId == null) throw Exception('No hay workspace activo');

    // Find category for 'Subscriptions' or similar
    String? effectiveCatId = categoryId;
    if (effectiveCatId == null) {
      final cats = await getCategories(workspaceId: effectiveWsId);
      final subCat = cats.firstWhereOrNull(
        (c) =>
            c.name.toLowerCase().contains('suscrip') ||
            c.name.toLowerCase().contains('recur'),
      );
      effectiveCatId = subCat?.id ?? cats.firstOrNull?.id;
    }

    if (effectiveCatId == null) {
      throw Exception('No se encontró una categoría adecuada para el pago recurrente');
    }

    await createTransaction(
      amount: amount,
      concept: 'Pago recurrente: $name',
      date: DateTime.now().toIso8601String().split('T')[0],
      type: 'expense',
      categoryId: effectiveCatId,
      workspaceId: effectiveWsId,
    );
  }
}
