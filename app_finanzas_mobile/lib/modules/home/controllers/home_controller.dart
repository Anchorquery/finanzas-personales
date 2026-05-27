import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/directus_service.dart';
import '../../../data/services/auth_service.dart';

import '../../workspaces/controllers/workspaces_controller.dart';
import '../../../core/widgets/transactions/add_transaction_modal.dart';

class HomeController extends GetxController {
  static const int dashboardIndex = 0;
  static const int statsIndex = 1;
  static const int coachIndex = 3;
  static const int settingsIndex = 4;
  static const int savingsIndex = 5;
  static const int budgetsIndex = 6;
  static const int debtsIndex = 7;
  static const int incomesIndex = 8;
  static const int subscriptionsIndex = 9;
  static const int expensesIndex = 10;
  static const int transactionsIndex = 11;
  static const int eventsIndex = 12;
  static const int workspacesIndex = 13;
  static const int recurringIndex = 14;
  static const int profileIndex = 15;

  final DirectusService _directusService = Get.find<DirectusService>();
  final AuthService _authService = Get.find<AuthService>();
  final currentIndex = 0.obs;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final organizationName = 'Finanzas Personales'.obs;
  final userOrganizations = <Organization>[].obs;

  Future<void> switchOrganization(String orgId) async {
    await _authService.setActiveOrganization(orgId);
    await loadOrganization();
    // Reload workspaces
    if (Get.isRegistered<WorkspacesController>()) {
      await Get.find<WorkspacesController>().loadWorkspaces();
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadOrganization();
  }

  Future<void> loadOrganization() async {
    try {
      final orgId = _authService.activeOrganizationId.value;
      if (orgId.isNotEmpty) {
        final org = await _directusService.getOrganization(orgId);
        if (org != null) {
          organizationName.value = org.name;
        }
      } else {
        // Fallback to first available if none set
        final org = await _directusService.getOrganization();
        if (org != null) {
          organizationName.value = org.name;
          _authService.activeOrganizationId.value = org.id;
        }
      }

      // Load list for switcher
      final orgs = await _directusService.getUserOrganizations();
      userOrganizations.assignAll(orgs);
    } catch (e) {
      Get.log('Error loading organization in home: $e');
    }
  }

  void changeIndex(int index) {
    if (index == 2) {
      Get.bottomSheet(
        const AddTransactionModal(),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
      );
      return;
    }
    currentIndex.value = index;
  }

  void showSavings() {
    currentIndex.value = savingsIndex;
  }

  void showBudgets() {
    currentIndex.value = budgetsIndex;
  }

  void showDebts() {
    currentIndex.value = debtsIndex;
  }

  void showIncomes() {
    currentIndex.value = incomesIndex;
  }

  void showSubscriptions() {
    currentIndex.value = subscriptionsIndex;
  }

  void showExpenses() {
    currentIndex.value = expensesIndex;
  }

  void showSettings() {
    currentIndex.value = settingsIndex;
  }
}
