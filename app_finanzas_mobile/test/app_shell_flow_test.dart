import 'package:app_finanzas_mobile/data/services/auth_service.dart';
import 'package:app_finanzas_mobile/data/services/directus_service.dart';
import 'package:app_finanzas_mobile/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:app_finanzas_mobile/modules/dashboard/views/dashboard_alt_view.dart';
import 'package:app_finanzas_mobile/modules/dashboard/views/dashboard_view.dart';
import 'package:app_finanzas_mobile/modules/home/controllers/home_controller.dart';
import 'package:app_finanzas_mobile/modules/organizations/controllers/organizations_controller.dart';
import 'package:app_finanzas_mobile/modules/workspaces/controllers/workspaces_controller.dart';
import 'package:app_finanzas_mobile/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart' hide Subscription;

class FakeDirectusService extends DirectusService {
  FakeDirectusService({
    List<Organization>? organizations,
    List<Workspace>? workspaces,
  }) : _organizations = organizations ?? <Organization>[],
       _workspaces = workspaces ?? <Workspace>[];

  final List<Organization> _organizations;
  final List<Workspace> _workspaces;

  Future<Organization> createOrganization(
    String name, {
    String? description,
  }) async {
    final newOrganization = Organization(
      id: 'org-${_organizations.length + 1}',
      name: name,
    );
    _organizations.add(newOrganization);
    return newOrganization;
  }

  QueryResult _buildMutationResult(String document, Map<String, dynamic> data) {
    return QueryResult(
      options: MutationOptions(document: gql(document)),
      source: QueryResultSource.network,
      data: data,
    );
  }

  QueryResult _buildQueryResult(
    String document,
    Map<String, dynamic> data, {
    Map<String, dynamic>? variables,
  }) {
    return QueryResult(
      options: QueryOptions(
        document: gql(document),
        variables: variables ?? {},
      ),
      source: QueryResultSource.network,
      data: data,
    );
  }

  Future<DashboardSummary> getDashboardSummary({
    required DateTime startDate,
    required DateTime endDate,
    String? workspaceId,
  }) async {
    return DashboardSummary(
      currentBalance: 2500,
      monthlyIncome: 1200,
      monthlyExpenses: 400,
    );
  }

  Future<List<Map<String, dynamic>>> getDailyCashFlow({
    required DateTime startDate,
    required DateTime endDate,
    String? workspaceId,
  }) async {
    return <Map<String, dynamic>>[];
  }

  Future<Organization?> getOrganization([String? id]) async {
    if (id == null) {
      return _organizations.isEmpty ? null : _organizations.first;
    }

    return _organizations.firstWhereOrNull(
      (organization) => organization.id == id,
    );
  }

  Future<List<Map<String, dynamic>>> getOrganizationMembers(
    String orgId,
  ) async {
    return <Map<String, dynamic>>[];
  }

  Future<List<Invitation>> getPendingInvitations([String? email]) async {
    return <Invitation>[];
  }

  Future<List<Subscription>> getSubscriptions({String? workspaceId}) async {
    return <Subscription>[];
  }

  Future<List<Transaction>> getTransactions({
    int? limit,
    String? workspaceId,
    DateTime? startDate,
    DateTime? endDate,
    String? type,
  }) async {
    return <Transaction>[];
  }

  Future<User?> getCurrentUser() async {
    return User(id: 'user-1', firstName: 'Prueba', email: 'test@example.com');
  }

  Future<List<Organization>> getUserOrganizations() async {
    return List<Organization>.from(_organizations);
  }

  Future<List<Workspace>> getWorkspaces({
    String? organizationId,
    bool restrictToCurrentUser = true,
  }) async {
    if (organizationId == null) {
      return List<Workspace>.from(_workspaces);
    }

    return _workspaces
        .where((workspace) => workspace.organizationId == organizationId)
        .toList();
  }

  @override
  Future<QueryResult> mutate(
    String doc, {
    Map<String, dynamic>? variables,
  }) async {
    if (doc.contains('CreateOrganization')) {
      final name = variables?['data']?['name']?.toString() ?? 'Nueva Org';
      final created = await createOrganization(name);
      return _buildMutationResult(doc, {
        'create_organizations_item': created.toJson(),
      });
    }

    return _buildMutationResult(doc, const <String, dynamic>{});
  }

  @override
  Future<QueryResult> query(
    String doc, {
    Map<String, dynamic>? variables,
  }) async {
    if (doc.contains('GetOrganizations')) {
      return _buildQueryResult(doc, {
        'organizations': _organizations
            .map((organization) => organization.toJson())
            .toList(),
      });
    }

    if (doc.contains('GetPendingInvitations')) {
      return _buildQueryResult(doc, {
        'invitations': const <Map<String, dynamic>>[],
      }, variables: variables);
    }

    if (doc.contains('GetOrgMembers')) {
      return _buildQueryResult(doc, {
        'organization_members': const <Map<String, dynamic>>[],
      }, variables: variables);
    }

    if (doc.contains('GetOrganization(')) {
      final organizationId = variables?['filter']?['id']?['_eq']?.toString();
      final organization = organizationId == null
          ? (_organizations.isEmpty ? null : _organizations.first)
          : _organizations.firstWhereOrNull(
              (candidate) => candidate.id == organizationId,
            );

      return _buildQueryResult(doc, {
        'organizations': organization == null
            ? const []
            : [organization.toJson()],
      }, variables: variables);
    }

    return _buildQueryResult(
      doc,
      const <String, dynamic>{},
      variables: variables,
    );
  }
}

class FakeAuthService extends AuthService {
  @override
  Future<String?> getActiveOrganization() async {
    return activeOrganizationId.value.isEmpty
        ? null
        : activeOrganizationId.value;
  }

  @override
  Future<void> setActiveOrganization(String orgId) async {
    activeOrganizationId.value = orgId;
  }
}

class TestWorkspacesController extends WorkspacesController {
  TestWorkspacesController(this._initialWorkspace);

  final Workspace _initialWorkspace;

  @override
  Future<void> loadWorkspaces() async {
    activeWorkspaceRx.value = _initialWorkspace;
  }

  @override
  void onInit() {
    super.onInit();
    activeWorkspaceRx.value = _initialWorkspace;
  }

  @override
  Future<void> setWorkspace(Workspace workspace) async {
    activeWorkspaceRx.value = workspace;
  }
}

void main() {
  late FakeAuthService authService;
  late FakeDirectusService directusService;

  setUp(() {
    Get.testMode = true;
    directusService = FakeDirectusService(
      organizations: [Organization(id: 'org-1', name: 'Principal')],
      workspaces: [
        Workspace(
          id: 'ws-1',
          name: 'Principal',
          type: WorkspaceType.personal,
          description: 'Workspace principal',
          organizationId: 'org-1',
          currency: 'USD',
        ),
      ],
    );
    Get.put<DirectusService>(directusService);
    authService = FakeAuthService()..activeOrganizationId.value = 'org-1';
    Get.put<AuthService>(authService);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('crear organizacion nueva lleva al onboarding de setup', (
    tester,
  ) async {
    Get.put<OrganizationsController>(OrganizationsController());

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/',
        getPages: [
          GetPage(name: '/', page: () => const SizedBox.shrink()),
          GetPage(name: Routes.setup, page: () => const SizedBox.shrink()),
        ],
      ),
    );

    await Get.find<OrganizationsController>().createOrganization('Nueva Org');
    await tester.pumpAndSettle();

    expect(authService.activeOrganizationId.value, 'org-2');
    expect(Get.currentRoute, Routes.setup);
  });

  testWidgets('dashboard principal reutiliza el shell al abrir presupuestos', (
    tester,
  ) async {
    Get.put<WorkspacesController>(
      TestWorkspacesController(
        Workspace(
          id: 'ws-1',
          name: 'Principal',
          type: WorkspaceType.personal,
          description: 'Workspace principal',
          organizationId: 'org-1',
          currency: 'USD',
        ),
      ),
    );
    Get.put<HomeController>(HomeController());
    Get.put<DashboardController>(DashboardController());

    await tester.pumpWidget(
      GetMaterialApp(
        getPages: [
          GetPage(name: Routes.budgets, page: () => const SizedBox.shrink()),
        ],
        home: Scaffold(
          key: Get.find<HomeController>().scaffoldKey,
          body: const DashboardView(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Presupuestos').last);
    await tester.tap(find.text('Presupuestos').last);
    await tester.pumpAndSettle();

    expect(
      Get.find<HomeController>().currentIndex.value,
      HomeController.budgetsIndex,
    );
  });

  testWidgets(
    'dashboard alternativo reutiliza el shell al abrir presupuestos',
    (tester) async {
      Get.put<WorkspacesController>(
        TestWorkspacesController(
          Workspace(
            id: 'ws-1',
            name: 'Principal',
            type: WorkspaceType.personal,
            description: 'Workspace principal',
            organizationId: 'org-1',
            currency: 'USD',
          ),
        ),
      );
      Get.put<DashboardController>(DashboardController());
      Get.put<HomeController>(HomeController());

      await tester.pumpWidget(
        GetMaterialApp(
          getPages: [
            GetPage(name: Routes.budgets, page: () => const SizedBox.shrink()),
          ],
          home: Scaffold(
            key: Get.find<HomeController>().scaffoldKey,
            body: const DashboardAltView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Presupuestos').last);
      await tester.tap(find.text('Presupuestos').last);
      await tester.pumpAndSettle();

      expect(
        Get.find<HomeController>().currentIndex.value,
        HomeController.budgetsIndex,
      );
    },
  );
}
