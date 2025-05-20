import 'package:teamhub_productivity_suite/src/constants/appstrings.dart';

class UserRoles {
  bool isAdmin;
  bool isManager;
  bool isMember;
  ApproverLevel approverLevel;
  bool canAccessPOS;
  bool canBalanceShifts;
  bool canAccessProcurement;
  bool canAccessAccounting;
  bool canManageCustomersAndSuppliers;
  bool canManageItems;
  bool canManageEquipment;
  bool canProcessRentals;
  bool canPerformStockCount;
  bool canManageUsers;
  bool canManageOrganizations;
  bool canManageSites;
  bool canGenerateInvoices;
  bool canManageAccountingPeriods;
  bool canOverrideRolloverConditions;
  bool canPostToSoftClosedPeriod;


  UserRoles({
    this.isAdmin = false,
    this.isManager = false,
    this.isMember = true,
    this.approverLevel = ApproverLevel.none,
    this.canAccessPOS = false,
    this.canBalanceShifts = false,
    this.canAccessProcurement = false,
    this.canAccessAccounting = false,
    this.canManageCustomersAndSuppliers = false,
    this.canManageItems = false,
    this.canManageEquipment = false,
    this.canProcessRentals = false,
    this.canPerformStockCount = false,
    this.canManageUsers = false,
    this.canManageOrganizations = false,
    this.canManageSites = false,
    this.canGenerateInvoices = false,
    this.canManageAccountingPeriods = false,
    this.canOverrideRolloverConditions = false,
    this.canPostToSoftClosedPeriod = false,
  });

  factory UserRoles.fromMap(Map<String, dynamic> map) {
    return UserRoles(
      isAdmin: map[AppStrings.fieldIsAdmin] ?? false,
      isManager: map[AppStrings.fieldIsManager] ?? false,
      isMember: map[AppStrings.fieldIsMember] ?? true,
      approverLevel: ApproverLevel.values.firstWhere(
            (e) => e.toString().split('.').last == map[AppStrings.fieldApproverLevel],
        orElse: () => ApproverLevel.none,
      ),
      // Map additional roles
      canAccessPOS: map[AppStrings.fieldCanAccessPOS] ?? false,
      canBalanceShifts: map[AppStrings.fieldCanBalanceShifts] ?? false,
      canAccessProcurement: map[AppStrings.fieldCanAccessProcurement] ?? false,
      canAccessAccounting: map[AppStrings.fieldCanAccessAccounting] ?? false,
      canManageCustomersAndSuppliers: map[AppStrings.fieldCanManageCustomersAndSuppliers] ?? false,
      canManageItems: map[AppStrings.fieldCanManageItems] ?? false,
      canManageEquipment: map[AppStrings.fieldCanManageEquipment] ?? false,
      canProcessRentals: map[AppStrings.fieldCanProcessRentals] ?? false,
      canPerformStockCount: map[AppStrings.fieldCanPerformStockCount] ?? false,
      canManageUsers: map[AppStrings.fieldCanManageUsers] ?? false,
      canManageOrganizations: map[AppStrings.fieldCanManageOrganizations] ?? false,
      canManageSites: map[AppStrings.fieldCanManageSites] ?? false,
      canGenerateInvoices: map[AppStrings.fieldCanGenerateInvoices] ?? false,
      canManageAccountingPeriods: map[AppStrings.fieldCanManageAccountingPeriods] ?? false,
      canOverrideRolloverConditions: map[AppStrings.fieldCanOverrideRolloverConditions] ?? false,
      canPostToSoftClosedPeriod: map[AppStrings.fieldCanPostToSoftClosedPeriod] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      AppStrings.fieldIsAdmin: isAdmin,
      AppStrings.fieldIsManager: isManager,
      AppStrings.fieldIsMember: isMember,
      AppStrings.fieldApproverLevel: approverLevel.toString().split('.').last,
      // Map additional roles
      AppStrings.fieldCanAccessPOS: canAccessPOS,
      AppStrings.fieldCanBalanceShifts: canBalanceShifts,
      AppStrings.fieldCanAccessProcurement: canAccessProcurement,
      AppStrings.fieldCanAccessAccounting: canAccessAccounting,
      AppStrings.fieldCanManageCustomersAndSuppliers: canManageCustomersAndSuppliers,
      AppStrings.fieldCanManageItems: canManageItems,
      AppStrings.fieldCanManageEquipment: canManageEquipment,
      AppStrings.fieldCanProcessRentals: canProcessRentals,
      AppStrings.fieldCanPerformStockCount: canPerformStockCount,
      AppStrings.fieldCanManageUsers: canManageUsers,
      AppStrings.fieldCanManageOrganizations: canManageOrganizations,
      AppStrings.fieldCanManageSites: canManageSites,
      AppStrings.fieldCanGenerateInvoices: canGenerateInvoices,
      AppStrings.fieldCanManageAccountingPeriods: canManageAccountingPeriods,
      AppStrings.fieldCanOverrideRolloverConditions: canOverrideRolloverConditions,
      AppStrings.fieldCanPostToSoftClosedPeriod: canPostToSoftClosedPeriod,
    };
  }
}
