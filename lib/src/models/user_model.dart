import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamhub_productivity_suite/src/models/user_roles.dart';
import 'package:teamhub_productivity_suite/src/constants/appstrings.dart';

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String? userPhotoUrl;
  final bool isFirstLogin;
  final DateTime createdAt;
  final String? createdBy; // UID of user who created this user (e.g., an admin)
  UserRoles roles; // Made mutable for easier updates in course examples
  bool isOnline;
  DateTime lastOnline;
  List<String> searchTokens;
  String? assignedOrganizationId; // For multi-tenancy or org structure
  String? jobTitle;
  String? phone;
  String? department;
  String? location;
  String? fcmToken;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    this.userPhotoUrl,
    this.isFirstLogin = true,
    required this.createdAt,
    this.createdBy,
    required this.roles,
    this.isOnline = false,
    required this.lastOnline,
    this.searchTokens = const [],
    this.assignedOrganizationId,
    this.jobTitle,
    this.phone,
    this.department,
    this.location,
    this.fcmToken,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    DateTime lastOnlineDate;
    if (map[AppStrings.fieldLastOnline] == null) {
      lastOnlineDate = DateTime.now();
    } else if (map[AppStrings.fieldLastOnline] is Timestamp) {
      lastOnlineDate = (map[AppStrings.fieldLastOnline] as Timestamp).toDate();
    } else if (map[AppStrings.fieldLastOnline] is String) {
      lastOnlineDate =
          DateTime.tryParse(map[AppStrings.fieldLastOnline] as String) ??
          DateTime.now();
    } else {
      lastOnlineDate = DateTime.now();
    }

    DateTime createdAtDate;
    if (map[AppStrings.fieldCreatedAt] == null) {
      createdAtDate = DateTime.now();
    } else if (map[AppStrings.fieldCreatedAt] is Timestamp) {
      createdAtDate = (map[AppStrings.fieldCreatedAt] as Timestamp).toDate();
    } else if (map[AppStrings.fieldCreatedAt] is String) {
      createdAtDate =
          DateTime.tryParse(map[AppStrings.fieldCreatedAt] as String) ??
          DateTime.now();
    } else {
      createdAtDate = DateTime.now();
    }

    return UserModel(
      uid: uid,
      email: map[AppStrings.fieldEmail] ?? '',
      fullName: map[AppStrings.fieldFullName] ?? '',
      userPhotoUrl: map[AppStrings.fieldUserPhotoUrl],
      isFirstLogin: map[AppStrings.fieldIsFirstLogin] ?? true,
      createdAt: createdAtDate,
      createdBy: map[AppStrings.fieldCreatedBy],
      roles: UserRoles.fromMap(
        map[AppStrings.fieldRoles] as Map<String, dynamic>? ?? {},
      ),
      isOnline: map[AppStrings.fieldIsOnline] ?? false,
      lastOnline: lastOnlineDate,
      searchTokens: List<String>.from(map[AppStrings.fieldSearchTokens] ?? []),
      assignedOrganizationId: map[AppStrings.fieldAssignedOrganizationId],
      jobTitle: map[AppStrings.fieldJobTitle],
      phone: map[AppStrings.fieldPhone],
      department: map[AppStrings.fieldDepartment],
      fcmToken: map[AppStrings.fieldFcmToken],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      AppStrings.fieldUid:
          uid, // Often not stored in the doc itself if uid is doc ID
      AppStrings.fieldEmail: email,
      AppStrings.fieldFullName: fullName,
      AppStrings.fieldUserPhotoUrl: userPhotoUrl,
      AppStrings.fieldIsFirstLogin: isFirstLogin,
      AppStrings.fieldCreatedAt: Timestamp.fromDate(createdAt),
      AppStrings.fieldCreatedBy: createdBy,
      AppStrings.fieldRoles: roles.toMap(),
      AppStrings.fieldIsOnline: isOnline,
      AppStrings.fieldLastOnline: Timestamp.fromDate(lastOnline),
      AppStrings.fieldSearchTokens: searchTokens,
      AppStrings.fieldAssignedOrganizationId: assignedOrganizationId,
      AppStrings.fieldJobTitle: jobTitle,
      AppStrings.fieldPhone: phone,
      AppStrings.fieldDepartment: department,
      AppStrings.fieldLocation: location,
      AppStrings.fieldFcmToken: fcmToken,
    };
  }

  UserModel copyWith({
    String? uid, // Added uid in case it's needed
    String? email,
    String? fullName,
    String? userPhotoUrl,
    bool? isFirstLogin,
    DateTime? createdAt,
    String? createdBy,
    UserRoles? roles,
    bool? isOnline,
    DateTime? lastOnline,
    List<String>? searchTokens,
    String? assignedOrganizationId,
    String? jobTitle,
    String? phone,
    String? department,
    String? location,
    String? fcmToken,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      isFirstLogin: isFirstLogin ?? this.isFirstLogin,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy, // Keep original if not provided
      roles: roles ?? this.roles,
      isOnline: isOnline ?? this.isOnline, // Corrected: was false
      lastOnline: lastOnline ?? this.lastOnline,
      searchTokens: searchTokens ?? this.searchTokens,
      assignedOrganizationId:
          assignedOrganizationId ?? this.assignedOrganizationId,
      jobTitle: jobTitle ?? this.jobTitle,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      location: location ?? this.location,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}
