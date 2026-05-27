part of '../directus_service.dart';

extension DirectusWorkspaceExtension on DirectusService {
  bool _canUserAccessWorkspace(Workspace workspace, String userId) {
    if (userId.isEmpty) {
      return true;
    }

    if (workspace.userId == userId) {
      return true;
    }

    if (workspace.accessScope == 'organization') {
      return true;
    }

    if (workspace.accessMemberIds.contains(userId)) {
      return true;
    }

    // Legacy compatibility: before access_scope/access_member_ids existed,
    // organization workspaces were effectively shared. Keep them visible
    // until an explicit access list is configured.
    return workspace.accessScope == 'restricted' &&
        workspace.accessMemberIds.isEmpty;
  }

  Future<List<Workspace>> getWorkspaces({
    String? organizationId,
    bool restrictToCurrentUser = true,
  }) async {
    const String queryStr = r'''
      query ReadWorkspaces($filter: workspaces_filter) {
        workspaces(filter: $filter) {
          id
          name
          type
          description
          is_active
          color_value
          icon_code_point
          ai_predictive_analysis
          ai_categorization
          currency
          exchange_rate_mode
          manual_exchange_rate
          secondary_currency
          access_scope
          access_member_ids
          user {
            id
            first_name
          }
          organization {
            id
            name
          }
        }
      }
    ''';

    final userId = currentUserId.value;
    Map<String, dynamic> gqlFilter = {};

    if (organizationId != null) {
      gqlFilter = {
        'organization': {
          'id': {'_eq': organizationId},
        },
      };
    }

    final result = await query(queryStr, variables: {'filter': gqlFilter});
    if (result.hasException) {
      Get.log('[DIRECTUS] Error in getWorkspaces: ${result.exception}');
      return [];
    }

    final data = result.data?['workspaces'] as List<dynamic>? ?? [];
    final workspaces = data.map((e) => Workspace.fromJson(e)).toList();

    if (!restrictToCurrentUser || userId.isEmpty) {
      return workspaces;
    }

    return workspaces
        .where((workspace) => _canUserAccessWorkspace(workspace, userId))
        .toList();
  }

  Future<List<Workspace>> getOrganizationWorkspaces(String orgId) async {
    return getWorkspaces(organizationId: orgId, restrictToCurrentUser: false);
  }

  Future<List<Workspace>> getOrganizationWorkspacesRestricted(
    String orgId,
  ) async {
    const String queryStr = r'''
      query GetOrgWorkspaces($filter: workspaces_filter) {
        workspaces(filter: $filter) {
          id
          name
          type
          description
          is_active
          color_value
          icon_code_point
          ai_predictive_analysis
          ai_categorization
          currency
          exchange_rate_mode
          manual_exchange_rate
          secondary_currency
          access_scope
          access_member_ids
          user {
            id
          }
          organization {
            id
          }
        }
      }
    ''';

    final userId = currentUserId.value;
    final Map<String, dynamic> gqlFilter = {
      'organization': {
        'id': {'_eq': orgId},
      },
    };

    final result = await query(queryStr, variables: {'filter': gqlFilter});
    if (result.hasException) throw result.exception!;
    final data = result.data?['workspaces'] as List<dynamic>? ?? [];
    final workspaces = data.map((e) => Workspace.fromJson(e)).toList();

    if (userId.isEmpty) {
      return workspaces;
    }

    return workspaces
        .where((workspace) => _canUserAccessWorkspace(workspace, userId))
        .toList();
  }

  Future<Workspace?> createWorkspace(
    Workspace workspace,
    String organizationId,
    String userId, {
    bool seedDefaults = true,
  }) async {
    const String createMutation = r'''
      mutation CreateWorkspace($data: create_workspaces_input!) {
        create_workspaces_item(data: $data) {
          id
          name
          type
          description
          is_active
          user { id }
          organization { id }
          color_value
          icon_code_point
          ai_predictive_analysis
          ai_categorization
          currency
          exchange_rate_mode
          manual_exchange_rate
          secondary_currency
        }
      }
    ''';

    final Map<String, dynamic> data = workspace.toJson();
    data.remove('id');

    data.remove('access_scope');
    data.remove('access_member_ids');
    data['organization'] = {'id': organizationId};
    data['user'] = {'id': userId};

    data['ai_categorization'] = true;
    data['ai_predictive_analysis'] = true;
    data['is_active'] = true;

    final result = await mutate(createMutation, variables: {'data': data});

    if (result.hasException) {
      Get.log('[DIRECTUS] Error in createWorkspace (GQL): ${result.exception}');
      final fallbackWorkspace = await _createWorkspaceViaRest(
        workspace,
        organizationId: organizationId,
        userId: userId,
      );
      if (fallbackWorkspace != null) {
        if (seedDefaults) {
          await seedBaseCategories(fallbackWorkspace.id);
        }
        return fallbackWorkspace;
      }
      return null;
    }

    final responseData = result.data?['create_workspaces_item'];
    if (responseData != null) {
      final newWorkspace = Workspace.fromJson(responseData);
      if (seedDefaults) {
        await seedBaseCategories(newWorkspace.id);
      }
      return newWorkspace;
    }

    return null;
  }

  Future<Workspace?> _createWorkspaceViaRest(
    Workspace workspace, {
    required String organizationId,
    required String userId,
  }) async {
    try {
      final token = await AppStorage.read(key: 'auth_token');
      if (token == null || token.isEmpty) {
        Get.log('[DIRECTUS] REST createWorkspace aborted: missing auth token');
        return null;
      }

      final dioInstance = dio.Dio(
        dio.BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ),
      );

      final payload = workspace.toJson()
        ..remove('id')
        ..['organization'] = organizationId
        ..['user'] = userId
        ..['ai_categorization'] = true
        ..['ai_predictive_analysis'] = true
        ..['is_active'] = true;

      final response = await dioInstance.post(
        '$serverUrl/items/workspaces',
        data: payload,
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final responseData = response.data?['data'];
      if (responseData is! Map<String, dynamic>) {
        return null;
      }

      return Workspace.fromJson(responseData);
    } catch (e) {
      Get.log('[DIRECTUS] Error in createWorkspace (REST fallback): $e');
      return null;
    }
  }

  Future<Workspace> updateWorkspace(
    String id,
    Map<String, dynamic> data,
  ) async {
    const String updateMutation = r'''
      mutation UpdateWorkspace($id: ID!, $data: update_workspaces_input!) {
        update_workspaces_item(id: $id, data: $data) {
          id
          name
          type
          description
          is_active
          color_value
          icon_code_point
          ai_predictive_analysis
          ai_categorization
          currency
          exchange_rate_mode
          manual_exchange_rate
          secondary_currency
        }
      }
    ''';

    final sanitizedData = Map<String, dynamic>.from(data)
      ..remove('access_scope')
      ..remove('access_member_ids');

    final result = await mutate(
      updateMutation,
      variables: {'id': id, 'data': sanitizedData},
    );

    if (result.hasException) throw result.exception!;
    return Workspace.fromJson(result.data!['update_workspaces_item']);
  }

  Future<void> deleteWorkspace(String id) async {
    const String deleteMutation = r'''
      mutation DeleteWorkspace($id: ID!) {
        delete_workspaces_item(id: $id) {
          id
        }
      }
    ''';

    final result = await mutate(deleteMutation, variables: {'id': id});
    if (result.hasException) throw result.exception!;
  }

  Future<Map<String, dynamic>?> getWorkspaceSettings(String workspaceId) async {
    const String queryStr = r'''
      query GetWorkspaceSettings($id: ID!) {
        workspaces_by_id(id: $id) {
          ai_categorization
          ai_predictive_analysis
          currency
          exchange_rate_mode
          manual_exchange_rate
          secondary_currency
        }
      }
    ''';

    final result = await query(queryStr, variables: {'id': workspaceId});
    if (result.hasException) return null;
    return result.data?['workspaces_by_id'];
  }

  Future<void> updateWorkspaceCurrency(
    String workspaceId,
    String currency,
  ) async {
    await updateWorkspace(workspaceId, {'currency': currency});
  }

  Future<List<User>> getWorkspaceMembers(String workspaceId) async {
    const String queryStr = r'''
      query GetWorkspaceMembers($workspaceId: ID!) {
        workspaces_by_id(id: $workspaceId) {
          organization {
            users {
              directus_users_id {
                id
                first_name
                email
                avatar { id }
              }
            }
          }
        }
      }
    ''';

    final result = await query(
      queryStr,
      variables: {'workspaceId': workspaceId},
    );
    if (result.hasException) return [];

    final org = result.data?['workspaces_by_id']?['organization'];
    if (org == null) return [];

    final usersData = org['users'] as List<dynamic>? ?? [];
    return usersData.map((u) => User.fromJson(u['directus_users_id'])).toList();
  }

  Future<String?> _getWorkspaceOrganizationId(String workspaceId) async {
    const String queryStr = r'''
      query GetWorkspaceOrganization($workspaceId: ID!) {
        workspaces_by_id(id: $workspaceId) {
          organization {
            id
          }
        }
      }
    ''';

    final result = await query(
      queryStr,
      variables: {'workspaceId': workspaceId},
    );
    if (result.hasException) return null;

    return result.data?['workspaces_by_id']?['organization']?['id']?.toString();
  }

  Future<void> removeWorkspaceMember(String workspaceId, String userId) async {
    // Logic depends on how members are linked. Usually remove from organization.
  }

  Future<List<Invitation>> getWorkspaceInvitations(String workspaceId) async {
    final orgId = await _getWorkspaceOrganizationId(workspaceId);
    if (orgId == null || orgId.isEmpty) {
      return [];
    }

    final invitations = await getPendingInvitations();
    return invitations
        .where((invite) => invite.organizationId == orgId)
        .toList();
  }

  Future<void> createWorkspaceInvitation(
    String workspaceId,
    String email,
    String role,
  ) async {
    final orgId = await _getWorkspaceOrganizationId(workspaceId);
    if (orgId == null || orgId.isEmpty) {
      throw Exception('Workspace sin organización asociada');
    }

    await createInvitation(email, orgId, role);
  }

  Future<void> acceptWorkspaceInvitation(String invitationId) async {
    const String mutation = r'''
      mutation AcceptInvitation($id: ID!) {
        update_invitations_item(id: $id, data: { status: "accepted" }) {
          id
        }
      }
    ''';
    await mutate(mutation, variables: {'id': invitationId});
  }

  Future<void> rejectWorkspaceInvitation(String invitationId) async {
    const String mutation = r'''
      mutation RejectInvitation($id: ID!) {
        update_invitations_item(id: $id, data: { status: "rejected" }) {
          id
        }
      }
    ''';
    await mutate(mutation, variables: {'id': invitationId});
  }

  Future<void> cancelWorkspaceInvitation(String invitationId) async {
    const String mutation = r'''
      mutation CancelInvitation($id: ID!) {
        delete_invitations_item(id: $id) {
          id
        }
      }
    ''';
    await mutate(mutation, variables: {'id': invitationId});
  }
}
