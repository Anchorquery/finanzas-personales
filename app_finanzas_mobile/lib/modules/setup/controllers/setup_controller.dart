import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/snackbar_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/directus_service.dart';
import '../../../routes/app_routes.dart';

class SetupController extends GetxController {
  static const int totalSteps = 7;

  static const Map<String, List<String>> _templateBudgetCategories = {
    'standard': ['Alimentación', 'Transporte', 'Vivienda', 'Salud', 'Ocio'],
    'student': ['Alimentación', 'Transporte', 'Estudios', 'Tecnología', 'Ocio'],
    'business': ['Nómina', 'Operaciones', 'Marketing', 'Impuestos', 'Software'],
  };

  static const Map<String, Map<String, double>> _templateSuggestedRatios = {
    'standard': {
      'Vivienda': 0.30,
      'Alimentación': 0.15,
      'Transporte': 0.10,
      'Salud': 0.10,
      'Ocio': 0.10,
    },
    'student': {
      'Alimentación': 0.20,
      'Transporte': 0.10,
      'Estudios': 0.25,
      'Tecnología': 0.10,
      'Ocio': 0.10,
    },
    'business': {
      'Nómina': 0.35,
      'Operaciones': 0.20,
      'Marketing': 0.15,
      'Impuestos': 0.15,
      'Software': 0.10,
    },
  };

  final DirectusService _directusService = Get.find<DirectusService>();
  final AuthService _authService = Get.find<AuthService>();

  final currentStep = 0.obs;
  final isLoading = false.obs;

  // Paso 0: Organization
  final orgNameController = TextEditingController(text: 'Mi Organización');
  final geminiKeyController = TextEditingController();
  final aiEnabled = true.obs;

  // Paso 1: Workspace
  final workspaceNameController = TextEditingController(text: 'Principal');
  final selectedWorkspaceType = WorkspaceType.personal.obs;
  final selectedCurrency = 'USD'.obs;

  // Paso 2: Initial Account & Balance
  final accountNameController = TextEditingController(text: 'Efectivo');
  final initialBalanceController = TextEditingController(text: '0.00');
  // 'cash' | 'bank' | 'card' | 'investment'
  final accountType = 'cash'.obs;

  // Onboarding (4 pasos) — independiente de currentStep (7 pasos legacy)
  final onboardingStep = 0.obs;
  static const int onboardingTotal = 4;

  // Paso 3: Income Plans
  final incomePlans = <_Entry>[].obs;
  final incomeNameController = TextEditingController();
  final incomeAmountController = TextEditingController();

  // Paso 4: Category Template
  final selectedTemplate = 'standard'.obs;

  // Paso 5: Budget Plans
  final budgetPlans = <String, double>{}.obs;

  // Paso 6: Invitations
  final inviteEmailController = TextEditingController();
  final invitedEmails = <String>[].obs;

  late final Worker _templateWorker;

  @override
  void onInit() {
    super.onInit();
    _syncBudgetCategories(selectedTemplate.value);
    _templateWorker = ever<String>(selectedTemplate, _syncBudgetCategories);
  }

  String? _validateCurrentStep() {
    switch (currentStep.value) {
      case 0:
        if (orgNameController.text.trim().isEmpty) {
          return 'Ingresa un nombre para la organización.';
        }
        return null;
      case 1:
        if (workspaceNameController.text.trim().isEmpty) {
          return 'Ingresa un nombre para el workspace.';
        }
        return null;
      case 2:
        if (accountNameController.text.trim().isEmpty) {
          return 'Ingresa un nombre para la cuenta.';
        }
        final balance = double.tryParse(initialBalanceController.text.trim());
        if (balance == null) return 'Ingresa un saldo inicial (puede ser 0).';
        if (balance < 0) return 'El saldo no puede ser negativo.';
        return null;
      case 3:
        if (incomePlans.isEmpty) {
          return 'Agrega al menos un ingreso esperado (ej: Salario).';
        }
        return null;
      default:
        return null;
    }
  }

  void _syncBudgetCategories(String template) {
    final categories =
        _templateBudgetCategories[template] ??
        _templateBudgetCategories['standard'] ?? const [];
    final currentValues = Map<String, double>.from(budgetPlans);
    final nextValues = <String, double>{};

    for (final category in categories) {
      nextValues[category] = currentValues[category] ?? 0.0;
    }

    budgetPlans
      ..clear()
      ..addAll(nextValues);
  }

  double get totalExpectedIncome =>
      incomePlans.fold(0.0, (sum, entry) => sum + entry.amount);

  Map<String, double> get suggestedBudgetPlans {
    final templateRatios =
        _templateSuggestedRatios[selectedTemplate.value] ??
        _templateSuggestedRatios['standard'] ?? const {};
    final totalIncome = totalExpectedIncome;

    return Map<String, double>.fromEntries(
      budgetPlans.keys.map((category) {
        final ratio = templateRatios[category] ?? 0.0;
        return MapEntry(category, totalIncome * ratio);
      }),
    );
  }

  Map<String, double> _resolveBudgetPlans() {
    final suggestions = suggestedBudgetPlans;
    final resolved = <String, double>{};

    for (final category in budgetPlans.keys) {
      final manualAmount = budgetPlans[category] ?? 0.0;
      final suggestedAmount = suggestions[category] ?? 0.0;
      resolved[category] = manualAmount > 0 ? manualAmount : suggestedAmount;
    }

    return resolved;
  }

  static Category? findBudgetCategory(
    List<Category> categories,
    String categoryName,
    String workspaceId,
  ) {
    final normalizedName = categoryName.toLowerCase();

    return categories.firstWhereOrNull(
          (item) =>
              item.workspaceId == workspaceId &&
              item.name.toLowerCase() == normalizedName,
        ) ??
        categories.firstWhereOrNull(
          (item) =>
              item.workspaceId == null &&
              item.name.toLowerCase() == normalizedName,
        ) ??
        categories.firstWhereOrNull(
          (item) => item.name.toLowerCase() == normalizedName,
        );
  }

  void addIncomePlan() {
    final name = incomeNameController.text.trim();
    final amount = double.tryParse(incomeAmountController.text.trim());

    if (name.isEmpty) {
      SnackbarService.showWarning('Atención', 'Ingresa el nombre del ingreso.');
      return;
    }
    if (amount == null || amount <= 0) {
      SnackbarService.showWarning(
        'Atención',
        'Ingresa un monto válido mayor a 0.',
      );
      return;
    }

    incomePlans.add(_Entry(name: name, amount: amount));
    incomeNameController.clear();
    incomeAmountController.clear();
  }

  void removeIncomePlan(int index) {
    incomePlans.removeAt(index);
  }

  void updateBudget(String category, String value) {
    budgetPlans[category] = double.tryParse(value) ?? 0.0;
  }

  void selectTemplate(String template) {
    selectedTemplate.value = template;
  }

  // ── Onboarding (4 pasos) ─────────────────────────────────────────────
  String? _validateOnboardingStep() {
    switch (onboardingStep.value) {
      case 0:
        return null;
      case 1:
        if (workspaceNameController.text.trim().isEmpty) {
          return 'Ingresa un nombre para el workspace.';
        }
        return null;
      case 2:
        if (accountNameController.text.trim().isEmpty) {
          return 'Ingresa un nombre para la cuenta.';
        }
        final balance = double.tryParse(initialBalanceController.text.trim());
        if (balance == null) return 'Ingresa un saldo válido (0 está bien).';
        if (balance < 0) return 'El saldo no puede ser negativo.';
        return null;
      default:
        return null;
    }
  }

  void nextOnboarding() {
    final error = _validateOnboardingStep();
    if (error != null) {
      SnackbarService.showWarning('Paso incompleto', error);
      return;
    }
    if (onboardingStep.value < onboardingTotal - 1) {
      onboardingStep.value++;
    }
  }

  void previousOnboarding() {
    if (onboardingStep.value > 0) {
      onboardingStep.value--;
    }
  }

  void nextStep() {
    final error = _validateCurrentStep();
    if (error != null) {
      SnackbarService.showWarning('Paso incompleto', error);
      return;
    }

    if (currentStep.value < totalSteps - 1) {
      currentStep.value++;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  void addInvitation() {
    final email = inviteEmailController.text.trim();
    if (email.isEmpty) return;
    if (!GetUtils.isEmail(email)) {
      SnackbarService.showWarning(
        'Email inválido',
        'Ingresa un correo válido.',
      );
      return;
    }
    if (invitedEmails.contains(email)) return;
    invitedEmails.add(email);
    inviteEmailController.clear();
  }

  void removeInvitation(String email) {
    invitedEmails.remove(email);
  }

  Future<void> finishSetup() async {
    isLoading.value = true;

    try {
      final currentUser = await _directusService.getCurrentUser();
      if (currentUser == null) {
        throw 'No se pudo obtener el usuario actual';
      }

      final userOrgs = await _directusService.getUserOrganizations();
      final activeOrgId = await _authService.getActiveOrganization();
      final activeOrg = userOrgs.firstWhereOrNull(
        (organization) => organization.id == activeOrgId,
      );
      final ownedOrg = userOrgs.firstWhereOrNull(
        (organization) => organization.ownerId == currentUser.id,
      );

      String orgId;
      if (activeOrg != null) {
        orgId = activeOrg.id;
      } else if (ownedOrg != null) {
        orgId = ownedOrg.id;
      } else if (userOrgs.isNotEmpty) {
        orgId = userOrgs.first.id;
      } else {
        final organization = await _directusService.createOrganization(
          orgNameController.text.trim(),
        );
        orgId = organization.id;
        await _directusService.createOrganizationSettings(
          orgId,
          apiKey: geminiKeyController.text.isNotEmpty
              ? geminiKeyController.text
              : null,
          aiEnabled: aiEnabled.value,
        );
      }

      await _authService.setActiveOrganization(orgId);

      final existingSettings = await _directusService.getOrganizationSettings(
        orgId,
      );
      final settingsPayload = {
        'gemini_api_key': geminiKeyController.text.isNotEmpty
            ? geminiKeyController.text
            : null,
        'ai_enabled': aiEnabled.value,
      };

      if (existingSettings == null) {
        await _directusService.createOrganizationSettings(
          orgId,
          apiKey: geminiKeyController.text.isNotEmpty
              ? geminiKeyController.text
              : null,
          aiEnabled: aiEnabled.value,
        );
      } else {
        await _directusService.updateOrganizationSettings(
          existingSettings['id'].toString(),
          settingsPayload,
        );
      }

      final workspaces = await _directusService.getWorkspaces(
        organizationId: orgId,
        restrictToCurrentUser: false,
      );
      String workspaceId;

      if (workspaces.isNotEmpty) {
        workspaceId = workspaces.first.id;
      } else {
        final workspace = Workspace(
          id: '',
          name: workspaceNameController.text.trim(),
          type: selectedWorkspaceType.value,
          description: 'Workspace inicial',
          currency: selectedCurrency.value,
          organizationId: orgId,
          isActive: true,
        );

        final createdWorkspace = await _directusService.createWorkspace(
          workspace,
          orgId,
          currentUser.id,
          seedDefaults: false,
        );

        if (createdWorkspace == null) {
          throw 'No se pudo crear el workspace inicial';
        }

        workspaceId = createdWorkspace.id;
      }

      final existingAccounts = await _directusService.getAccounts(
        workspaceId: workspaceId,
      );
      if (existingAccounts.isEmpty) {
        final balance =
            double.tryParse(initialBalanceController.text.trim()) ?? 0.0;
        await _directusService.createAccount(
          Account(
            id: '',
            name: accountNameController.text.trim(),
            type: accountType.value,
            currency: selectedCurrency.value,
            initialBalance: balance,
            workspaceId: workspaceId,
          ),
        );
      }

      await _directusService.initializeWorkspaceCategories(
        workspaceId,
        selectedTemplate.value,
      );

      final workspaceCategories = await _directusService.getCategories(
        workspaceId: workspaceId,
      );

      final existingBudgets = await _directusService.getBudgetsStatus(
        workspaceId,
      );
      final resolvedBudgetPlans = _resolveBudgetPlans();

      for (final entry in resolvedBudgetPlans.entries) {
        if (entry.value <= 0) continue;

        final category = findBudgetCategory(
          workspaceCategories,
          entry.key,
          workspaceId,
        );
        if (category == null) continue;

        final existingBudget = existingBudgets.firstWhereOrNull(
          (budget) => budget.name.toLowerCase() == entry.key.toLowerCase(),
        );

        if (existingBudget != null) {
          await _directusService.updateBudget(existingBudget.id, entry.value);
        } else {
          await _directusService.createBudget(
            limit: entry.value,
            categoryId: category.id,
            workspaceId: workspaceId,
          );
        }
      }

      final existingIncomePlans = await _directusService.getIncomePlans(
        workspaceId: workspaceId,
      );
      final existingIncomeNames = existingIncomePlans
          .map((plan) => plan.name.toLowerCase())
          .toSet();

      for (final plan in incomePlans) {
        if (existingIncomeNames.contains(plan.name.toLowerCase())) {
          continue;
        }

        await _directusService.createIncomePlan(
          IncomePlan(
            id: '',
            name: plan.name,
            amount: plan.amount,
            workspaceId: workspaceId,
          ),
        );
      }

      for (final email in invitedEmails) {
        await _directusService.createInvitation(email, orgId, 'member');
      }

      SnackbarService.showSuccess(
        '¡Listo!',
        'Configuración completada con éxito.',
      );
      Get.offAllNamed(Routes.home);
    } catch (e) {
      Get.log('Error in setup: $e');
      SnackbarService.showError('Error', 'No se pudo completar: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _templateWorker.dispose();
    orgNameController.dispose();
    geminiKeyController.dispose();
    workspaceNameController.dispose();
    accountNameController.dispose();
    initialBalanceController.dispose();
    incomeNameController.dispose();
    incomeAmountController.dispose();
    inviteEmailController.dispose();
    super.onClose();
  }
}

class _Entry {
  final String name;
  final double amount;

  _Entry({required this.name, required this.amount});
}
