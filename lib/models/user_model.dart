enum UserRole { user, author, admin, superAdmin }

enum UserStatus { active, pending, blocked }

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String profilePhotoUrl;
  UserRole role;
  UserStatus status;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.profilePhotoUrl,
    required this.role,
    required this.status,
  });

  String get roleString {
    switch (role) {
      case UserRole.superAdmin:
        return 'SUPER ADMIN';
      case UserRole.admin:
        return 'ADMIN';
      case UserRole.author:
        return 'AUTHOR';
      case UserRole.user:
        return 'USER';
    }
  }

  String get statusString {
    switch (status) {
      case UserStatus.active:
        return 'Active';
      case UserStatus.pending:
        return 'Pending';
      case UserStatus.blocked:
        return 'Blocked';
    }
  }
}

enum RoleRequestStatus { pendingAdmin, pendingSuperAdmin, approved, rejected }

class RoleRequestModel {
  final String id;
  final UserModel user;
  final UserRole requestedRole;
  final String requestedBy;
  final String reason;
  RoleRequestStatus status;
  final DateTime requestedDate;
  
  String? rejectionReason;
  UserModel? adminApprover;
  DateTime? adminApprovalDate;
  UserModel? superAdminApprover;
  DateTime? superAdminApprovalDate;

  RoleRequestModel({
    required this.id,
    required this.user,
    required this.requestedRole,
    required this.requestedBy,
    required this.reason,
    required this.status,
    required this.requestedDate,
    this.rejectionReason,
    this.adminApprover,
    this.adminApprovalDate,
    this.superAdminApprover,
    this.superAdminApprovalDate,
  });

  String get statusString {
    switch (status) {
      case RoleRequestStatus.pendingAdmin:
        return 'Pending Admin Approval';
      case RoleRequestStatus.pendingSuperAdmin:
        return 'Pending Super Admin Approval';
      case RoleRequestStatus.approved:
        return 'Approved';
      case RoleRequestStatus.rejected:
        return 'Rejected';
    }
  }
}
