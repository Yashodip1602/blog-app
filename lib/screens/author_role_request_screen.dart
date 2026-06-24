import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../models/user_model.dart';
import '../utils/mock_data.dart';
import '../widgets/glass_container.dart';

class AuthorRoleRequestScreen extends StatefulWidget {
  const AuthorRoleRequestScreen({super.key});

  @override
  State<AuthorRoleRequestScreen> createState() => _AuthorRoleRequestScreenState();
}

class _AuthorRoleRequestScreenState extends State<AuthorRoleRequestScreen> {
  UserModel _currentUser = MockDatabase.users.firstWhere((u) => u.fullName == 'Emma Watson', orElse: () => MockDatabase.users.first);
  String _demoName = 'Emma Watson';

  int _segmentIndex = 0; // 0 = Requests, 1 = Workflow

  @override
  void initState() {
    super.initState();
    _loadDemoUser();
  }

  Future<void> _loadDemoUser() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('demoUserName') ?? 'Emma Watson';
    final email = prefs.getString('demoUserEmail') ?? 'emma@example.com';
    
    setState(() {
      _demoName = name;
      _currentUser = UserModel(
        id: 'demo_user',
        fullName: name,
        email: email,
        phone: '+1 000 000 0000',
        profilePhotoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300',
        role: UserRole.user,
        status: UserStatus.active,
      );
    });
  }

  void _showCreateRequestModal() {
    TextEditingController reasonController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.of(context).surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Author Request',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.of(context).textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.of(context).surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.of(context).glassBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Requested Role:', style: GoogleFonts.inter(color: AppColors.of(context).textSecondary, fontSize: 14)),
                      Text('AUTHOR', style: GoogleFonts.inter(color: AppColors.of(context).primary, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text('Reason', style: GoogleFonts.inter(color: AppColors.of(context).textSecondary, fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: reasonController,
                  style: GoogleFonts.inter(color: AppColors.of(context).textPrimary),
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Why do you want to become an author?',
                    hintStyle: GoogleFonts.inter(color: AppColors.of(context).textHint),
                    filled: true,
                    fillColor: AppColors.of(context).surfaceLight,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.of(context).glassBorder)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.of(context).glassBorder)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.of(context).primary)),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.of(context).textSecondary)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppColors.of(context).primaryGradient,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          onPressed: () {
                            if (reasonController.text.isEmpty) {
                              _showToast('Please provide a reason', isSuccess: false);
                              return;
                            }

                            setState(() {
                              MockDatabase.roleRequests.add(
                                RoleRequestModel(
                                  id: DateTime.now().toString(),
                                  user: _currentUser,
                                  requestedRole: UserRole.author,
                                  requestedBy: _currentUser.fullName,
                                  reason: reasonController.text,
                                  status: RoleRequestStatus.pendingAdmin,
                                  requestedDate: DateTime.now(),
                                )
                              );
                            });
                            Navigator.pop(sheetContext);
                            _showToast('Author role request submitted successfully', isSuccess: true);
                          },
                          child: Text('Submit Request', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showToast(String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isSuccess ? Icons.check_circle : Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message, style: GoogleFonts.inter(color: Colors.white))),
          ],
        ),
        backgroundColor: isSuccess ? AppColors.of(context).primary : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      appBar: AppBar(
        backgroundColor: AppColors.of(context).background.withOpacity(0.95),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.of(context).textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Author Role Request',
          style: GoogleFonts.inter(color: AppColors.of(context).textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.of(context).backgroundGradient),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Segmented Control
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.of(context).surfaceLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _segmentIndex = 0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _segmentIndex == 0 ? AppColors.of(context).primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              'Requests',
                              style: GoogleFonts.inter(
                                color: _segmentIndex == 0 ? Colors.white : AppColors.of(context).textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _segmentIndex = 1),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _segmentIndex == 1 ? AppColors.of(context).primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              'Workflow',
                              style: GoogleFonts.inter(
                                color: _segmentIndex == 1 ? Colors.white : AppColors.of(context).textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _segmentIndex == 0 ? _buildRequestsTab() : _buildWorkflowTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsTab() {
    final myRequests = MockDatabase.roleRequests.where((r) => r.user.fullName == _demoName && r.requestedRole == UserRole.author).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.of(context).primaryGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: _showCreateRequestModal,
                child: Text('Create Author Request', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (myRequests.isEmpty)
          Expanded(
            child: Center(
              child: Text("You haven't requested the author role yet.", style: GoogleFonts.inter(color: AppColors.of(context).textSecondary)),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: myRequests.length,
              itemBuilder: (context, index) {
                final req = myRequests[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(req.user.profilePhotoUrl),
                              radius: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(req.user.fullName, style: GoogleFonts.inter(color: AppColors.of(context).textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(req.user.roleString, style: GoogleFonts.inter(color: AppColors.of(context).textSecondary, fontSize: 12)),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Icon(Icons.arrow_forward, color: AppColors.of(context).textSecondary, size: 14),
                                      ),
                                      _buildRoleBadge(req.requestedRole),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Requested: ${DateFormat('MMM d, yyyy').format(req.requestedDate)}', style: GoogleFonts.inter(color: AppColors.of(context).textSecondary, fontSize: 10)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.of(context).surfaceLight.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Reason:', style: GoogleFonts.inter(color: AppColors.of(context).textHint, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(req.reason, style: GoogleFonts.inter(color: AppColors.of(context).textPrimary, fontSize: 13, height: 1.4)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildRequestStatusBadge(req.status),
                      ],
                    ),
                  ).animate().fadeIn(delay: Duration(milliseconds: index * 100)).slideY(begin: 0.1, end: 0),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildWorkflowTab() {
    final myRequests = MockDatabase.roleRequests.where((r) => r.user.fullName == _demoName && r.requestedRole == UserRole.author).toList();
    
    if (myRequests.isEmpty) {
      return Center(
        child: Text('No workflow data available.', style: GoogleFonts.inter(color: AppColors.of(context).textSecondary)),
      );
    }
    
    final req = myRequests.last;

    // Logic for tracking node states
    bool l1Pending = req.status == RoleRequestStatus.pendingAdmin;
    bool l1Approved = req.status == RoleRequestStatus.pendingSuperAdmin || req.status == RoleRequestStatus.approved;
    bool l1Rejected = req.status == RoleRequestStatus.rejected && req.adminApprover != null;

    bool l2Locked = l1Pending || l1Rejected;
    bool l2Pending = req.status == RoleRequestStatus.pendingSuperAdmin;
    bool l2Approved = req.status == RoleRequestStatus.approved;
    bool l2Rejected = req.status == RoleRequestStatus.rejected && req.superAdminApprover != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Author Role Approval Workflow',
              style: GoogleFonts.inter(color: AppColors.of(context).textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Request by ${req.user.fullName}', style: GoogleFonts.inter(color: AppColors.of(context).textSecondary, fontSize: 12)),
            const SizedBox(height: 32),
            
            // Level 1: Admin
            _buildTimelineNode(
              level: 'Level 1: Admin Approval',
              approver: req.adminApprover,
              date: req.adminApprovalDate,
              isApproved: l1Approved,
              isRejected: l1Rejected,
              isPending: l1Pending,
              isLocked: false,
              rejectionReason: l1Rejected ? req.rejectionReason : null,
              actions: l1Pending ? _buildInlineActions(req, 1) : null,
            ),
            
            Container(
              margin: const EdgeInsets.only(left: 23, top: 4, bottom: 4),
              height: 40,
              width: 2,
              color: AppColors.of(context).glassBorder,
            ),

            // Level 2: Super Admin
            _buildTimelineNode(
              level: 'Level 2: Super Admin Approval',
              approver: req.superAdminApprover,
              date: req.superAdminApprovalDate,
              isApproved: l2Approved,
              isRejected: l2Rejected,
              isPending: l2Pending,
              isLocked: l2Locked,
              rejectionReason: l2Rejected ? req.rejectionReason : null,
              actions: (!l2Locked && l2Pending) ? _buildInlineActions(req, 2) : null,
            ).animate(target: l2Locked ? 0 : 1).fade(begin: 0.5, end: 1.0).slideY(begin: 0.1, end: 0, duration: 300.ms),
          ],
        ),
      ).animate().fadeIn(),
    );
  }

  Widget _buildInlineActions(RoleRequestModel request, int level) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _handleDemoApproval(request, false, level),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                ),
                alignment: Alignment.center,
                child: Text('Reject', style: GoogleFonts.inter(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () => _handleDemoApproval(request, true, level),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
                ),
                alignment: Alignment.center,
                child: Text('Approve', style: GoogleFonts.inter(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDemoApproval(RoleRequestModel request, bool approve, int level) {
    // Demo only: Allow the user to simulate admin approvals directly from this screen
    if (!approve) {
      setState(() {
        request.status = RoleRequestStatus.rejected;
        request.rejectionReason = 'Demo rejection reason';
        if (level == 1) {
          request.adminApprover = MockDatabase.users[1]; // Sarah (Admin)
          request.adminApprovalDate = DateTime.now();
        } else {
          request.superAdminApprover = MockDatabase.users[0]; // Yashodip (Super Admin)
          request.superAdminApprovalDate = DateTime.now();
        }
      });
      _showToast('Demo: Request Rejected', isSuccess: false);
      return;
    }

    if (level == 1) {
      setState(() {
        request.status = RoleRequestStatus.pendingSuperAdmin;
        request.adminApprover = MockDatabase.users[1];
        request.adminApprovalDate = DateTime.now();
      });
      _showToast('Demo: Level 1 Approved', isSuccess: true);
    } else if (level == 2) {
      setState(() {
        request.status = RoleRequestStatus.approved;
        request.superAdminApprover = MockDatabase.users[0];
        request.superAdminApprovalDate = DateTime.now();
        request.user.role = request.requestedRole;
      });
      _showToast('Demo: Level 2 Approved! Role updated.', isSuccess: true);
    }
  }

  Widget _buildTimelineNode({
    required String level,
    UserModel? approver,
    DateTime? date,
    required bool isApproved,
    required bool isRejected,
    required bool isPending,
    required bool isLocked,
    String? rejectionReason,
    Widget? actions,
  }) {
    Color statusColor = AppColors.of(context).textSecondary;
    IconData statusIcon = Icons.lock_outline;
    String statusText = 'Locked';

    if (isApproved) {
      statusColor = Colors.greenAccent;
      statusIcon = Icons.check_circle;
      statusText = 'Approved';
    } else if (isRejected) {
      statusColor = Colors.redAccent;
      statusIcon = Icons.cancel;
      statusText = 'Rejected';
    } else if (isPending) {
      statusColor = Colors.orangeAccent;
      statusIcon = Icons.access_time;
      statusText = 'Pending';
    } else if (isLocked) {
      statusColor = Colors.grey.shade600;
      statusIcon = Icons.lock;
      statusText = 'Locked';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: statusColor.withOpacity(0.1),
            border: Border.all(color: statusColor.withOpacity(0.3)),
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(statusIcon, color: statusColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(level, style: GoogleFonts.inter(color: isLocked ? AppColors.of(context).textSecondary : AppColors.of(context).textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              if (approver != null) ...[
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(approver.profilePhotoUrl),
                      radius: 12,
                    ),
                    const SizedBox(width: 8),
                    Text(approver.fullName, style: GoogleFonts.inter(color: AppColors.of(context).textSecondary, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  Text('Status: ', style: GoogleFonts.inter(color: AppColors.of(context).textHint, fontSize: 12)),
                  Text(statusText, style: GoogleFonts.inter(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              if (date != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Date: ${DateFormat('MMM d, yyyy - h:mm a').format(date)}', 
                  style: GoogleFonts.inter(color: AppColors.of(context).textHint, fontSize: 11)
                ),
              ],
              if (rejectionReason != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reason for Rejection:', style: GoogleFonts.inter(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(rejectionReason, style: GoogleFonts.inter(color: AppColors.of(context).textPrimary, fontSize: 12)),
                    ],
                  ),
                ),
              ],
              if (actions != null) actions,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequestStatusBadge(RoleRequestStatus status) {
    Color color;
    String text;
    switch (status) {
      case RoleRequestStatus.pendingAdmin:
        color = Colors.orangeAccent;
        text = 'Pending Admin Approval';
        break;
      case RoleRequestStatus.pendingSuperAdmin:
        color = Colors.orangeAccent;
        text = 'Pending Super Admin Approval';
        break;
      case RoleRequestStatus.approved:
        color = Colors.greenAccent;
        text = 'Approved';
        break;
      case RoleRequestStatus.rejected:
        color = Colors.redAccent;
        text = 'Rejected';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text, 
        style: GoogleFonts.inter(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildRoleBadge(UserRole role) {
    Color bgColor = AppColors.of(context).primary;
    String roleStr = role.toString().split('.').last.toUpperCase();
    if (roleStr == 'SUPERADMIN') roleStr = 'SUPER ADMIN';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        roleStr,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }
}
