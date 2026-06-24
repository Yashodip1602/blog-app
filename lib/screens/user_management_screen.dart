import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../models/user_model.dart';
import '../utils/mock_data.dart';
import '../widgets/glass_container.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  // To test different flows, change this mock value to UserRole.admin or UserRole.superAdmin
  final UserRole _currentUserRole = UserRole.admin;
  late UserModel _currentMockUser;
  int _authorTabSegmentIndex = 0; // 0 = Requests, 1 = Workflow

  @override
  void initState() {
    super.initState();
    // Mock the current user object based on the _currentUserRole
    _currentMockUser = _currentUserRole == UserRole.superAdmin ? MockDatabase.users[0] : MockDatabase.users[1];
  }

  void _showAssignRoleModal(BuildContext context, UserModel user) {
    UserRole selectedRole = user.role;
    TextEditingController reasonController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.of(context).surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
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
                      'Assign Role',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.of(context).textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(user.profilePhotoUrl),
                          radius: 20,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.fullName, style: GoogleFonts.inter(color: AppColors.of(context).textPrimary, fontWeight: FontWeight.bold)),
                            Text('Current Role: ${user.roleString}', style: GoogleFonts.inter(color: AppColors.of(context).textSecondary, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('Select New Role', style: GoogleFonts.inter(color: AppColors.of(context).textSecondary, fontSize: 14)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.of(context).surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.of(context).glassBorder),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<UserRole>(
                          value: selectedRole,
                          isExpanded: true,
                          dropdownColor: AppColors.of(context).surface,
                          icon: Icon(Icons.keyboard_arrow_down, color: AppColors.of(context).textSecondary),
                          style: GoogleFonts.inter(color: AppColors.of(context).textPrimary),
                          items: UserRole.values.map((UserRole role) {
                            String roleStr = role.toString().split('.').last.toUpperCase();
                            if (roleStr == 'SUPERADMIN') roleStr = 'SUPER ADMIN';
                            return DropdownMenuItem<UserRole>(
                              value: role,
                              child: Text(roleStr),
                            );
                          }).toList(),
                          onChanged: (UserRole? newValue) {
                            if (newValue != null) {
                              setSheetState(() {
                                selectedRole = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    Text('Reason', style: GoogleFonts.inter(color: AppColors.of(context).textSecondary, fontSize: 14)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: reasonController,
                      style: GoogleFonts.inter(color: AppColors.of(context).textPrimary),
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Why are you assigning this role?',
                        hintStyle: GoogleFonts.inter(color: AppColors.of(context).textHint),
                        filled: true,
                        fillColor: AppColors.of(context).surfaceLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.of(context).glassBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.of(context).glassBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.of(context).primary),
                        ),
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
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(24),
                                onTap: () {
                                  if (selectedRole == user.role) {
                                    Navigator.pop(sheetContext);
                                    return;
                                  }
                                  
                                  if (_currentUserRole == UserRole.superAdmin) {
                                    setState(() => user.role = selectedRole);
                                    _showToast('Role updated successfully', isSuccess: true);
                                  } else {
                                    RoleRequestStatus initialStatus = RoleRequestStatus.pendingSuperAdmin;
                                    
                                    // Rule: USER to AUTHOR -> Admin requests, Super Admin Approves
                                    // (Admin cannot approve Author role, starts at pendingSuperAdmin if Admin makes it)
                                    // Wait, the new rule states: "Admin Approval -> Super Admin Approval" for USER to AUTHOR?
                                    // Actually prompt says: "Level 1: Admin Approval. After Admin approval, request moves to Level 2."
                                    // So if an admin makes it, maybe it implicitly passes Admin approval, or we start it at pendingSuperAdmin.
                                    // We will start it at pendingAdmin just to test the full flow, simulating it was requested by USER.
                                    if (selectedRole == UserRole.author) {
                                      initialStatus = RoleRequestStatus.pendingAdmin;
                                    }

                                    setState(() {
                                      MockDatabase.roleRequests.add(
                                        RoleRequestModel(
                                          id: DateTime.now().toString(),
                                          user: user,
                                          requestedRole: selectedRole,
                                          requestedBy: _currentMockUser.fullName,
                                          reason: reasonController.text.isNotEmpty ? reasonController.text : 'No reason provided',
                                          status: initialStatus,
                                          requestedDate: DateTime.now(),
                                        )
                                      );
                                    });
                                    _showToast('Approval request sent successfully', isSuccess: true);
                                  }
                                  Navigator.pop(sheetContext);
                                },
                                child: Center(
                                  child: Text(
                                    _currentUserRole == UserRole.superAdmin ? 'Direct Approve' : 'Send Approval Request', 
                                    style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
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
      },
    );
  }

  void _showRejectModal(RoleRequestModel request) {
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reject Request',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 16),
              Text('Enter rejection reason', style: GoogleFonts.inter(color: AppColors.of(context).textSecondary, fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: reasonController,
                style: GoogleFonts.inter(color: AppColors.of(context).textPrimary),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Why are you rejecting this role?',
                  filled: true,
                  fillColor: AppColors.of(context).surfaceLight,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: () {
                    setState(() {
                      request.status = RoleRequestStatus.rejected;
                      request.rejectionReason = reasonController.text.isNotEmpty ? reasonController.text : 'No reason provided';
                      
                      // Assign the rejector to whichever level we were on
                      if (request.status == RoleRequestStatus.pendingAdmin) {
                        request.adminApprover = _currentMockUser;
                        request.adminApprovalDate = DateTime.now();
                      } else {
                        request.superAdminApprover = _currentMockUser;
                        request.superAdminApprovalDate = DateTime.now();
                      }
                    });
                    Navigator.pop(sheetContext);
                    _showToast('Role rejected', isSuccess: false);
                  },
                  child: Text('Reject Request', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _handleRequestApproval(RoleRequestModel request, bool approve) {
    if (!approve) {
      _showRejectModal(request);
      return;
    }

    if (_currentUserRole == UserRole.superAdmin) {
      setState(() {
        request.status = RoleRequestStatus.approved;
        request.superAdminApprover = _currentMockUser;
        request.superAdminApprovalDate = DateTime.now();
        request.user.role = request.requestedRole;
      });
      _showToast('Role approved successfully', isSuccess: true);
    } else if (_currentUserRole == UserRole.admin) {
      if (request.status == RoleRequestStatus.pendingAdmin) {
        setState(() {
          request.adminApprover = _currentMockUser;
          request.adminApprovalDate = DateTime.now();
          request.status = RoleRequestStatus.pendingSuperAdmin;
        });
        _showToast('Waiting for Super Admin approval', isSuccess: true);
      } else {
        _showToast('Only Super Admin can finalize this approval', isSuccess: false);
      }
    }
  }

  void _showToast(String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isSuccess ? Icons.check_circle : Icons.info, color: Colors.white),
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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.of(context).background,
        appBar: AppBar(
          backgroundColor: AppColors.of(context).background.withOpacity(0.95),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.of(context).textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'User Management',
            style: GoogleFonts.inter(color: AppColors.of(context).textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.search, color: AppColors.of(context).textPrimary),
              onPressed: () {},
            ),
          ],
          bottom: TabBar(
            indicatorColor: AppColors.of(context).primary,
            labelColor: AppColors.of(context).primary,
            unselectedLabelColor: AppColors.of(context).textSecondary,
            labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12),
            isScrollable: true,
            tabs: const [
              Tab(text: 'Users'),
              Tab(text: 'Role Requests'),
              Tab(text: 'Author Role Request'),
            ],
          ),
        ),
        body: Container(
          decoration: BoxDecoration(gradient: AppColors.of(context).backgroundGradient),
          child: TabBarView(
            children: [
              _buildUsersTab(),
              _buildRoleRequestsTab(filterAuthor: false),
              _buildAuthorRoleRequestTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsersTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: MockDatabase.users.length,
      itemBuilder: (context, index) {
        final user = MockDatabase.users[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(user.profilePhotoUrl),
                      radius: 28,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.fullName, style: GoogleFonts.inter(color: AppColors.of(context).textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(user.email, style: GoogleFonts.inter(color: AppColors.of(context).textSecondary, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text(user.phone, style: GoogleFonts.inter(color: AppColors.of(context).textSecondary, fontSize: 13)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildRoleBadge(user.role),
                        const SizedBox(height: 8),
                        _buildStatusBadge(user.status),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: AppColors.of(context).glassBorder, height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionTextBtn(context, 'View Details', Icons.visibility_outlined, () {}),
                    _buildActionTextBtn(context, 'Assign Role', Icons.shield_outlined, () => _showAssignRoleModal(context, user), color: AppColors.of(context).primary),
                    _buildActionTextBtn(context, 'Status', Icons.block_outlined, () {}, color: Colors.redAccent),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: index * 100)).slideY(begin: 0.1, end: 0),
        );
      },
    );
  }

  Widget _buildRoleRequestsTab({required bool filterAuthor}) {
    List<RoleRequestModel> filteredList = MockDatabase.roleRequests.where((r) {
      if (filterAuthor) return r.requestedRole == UserRole.author;
      return r.requestedRole != UserRole.author;
    }).toList();

    if (filteredList.isEmpty) {
      return Center(
        child: Text('No role requests pending', style: GoogleFonts.inter(color: AppColors.of(context).textSecondary)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final req = filteredList[index];
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
                      if (req.status == RoleRequestStatus.rejected && req.rejectionReason != null) ...[
                        const SizedBox(height: 8),
                        Text('Rejection Reason:', style: GoogleFonts.inter(color: Colors.redAccent, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(req.rejectionReason!, style: GoogleFonts.inter(color: AppColors.of(context).textPrimary, fontSize: 13, height: 1.4)),
                      ]
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildRequestStatusBadge(req.status),
                    if (!filterAuthor && req.status != RoleRequestStatus.approved && req.status != RoleRequestStatus.rejected)
                      Row(
                        children: [
                          InkWell(
                            onTap: () => _handleRequestApproval(req, false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('Reject', style: GoogleFonts.inter(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => _handleRequestApproval(req, true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.greenAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('Approve', style: GoogleFonts.inter(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                    if (filterAuthor)
                      Text('Check Workflow Tab to act', style: GoogleFonts.inter(color: AppColors.of(context).textSecondary, fontSize: 11, fontStyle: FontStyle.italic)),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: index * 100)).slideY(begin: 0.1, end: 0),
        );
      },
    );
  }

  Widget _buildAuthorRoleRequestTab() {
    return Column(
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
                    onTap: () => setState(() => _authorTabSegmentIndex = 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _authorTabSegmentIndex == 0 ? AppColors.of(context).primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          'Requests',
                          style: GoogleFonts.inter(
                            color: _authorTabSegmentIndex == 0 ? Colors.white : AppColors.of(context).textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _authorTabSegmentIndex = 1),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _authorTabSegmentIndex == 1 ? AppColors.of(context).primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          'Workflow',
                          style: GoogleFonts.inter(
                            color: _authorTabSegmentIndex == 1 ? Colors.white : AppColors.of(context).textSecondary,
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
        Expanded(
          child: _authorTabSegmentIndex == 0
              ? _buildRoleRequestsTab(filterAuthor: true) // Section 1: Reuse Request cards for Author only
              : _buildWorkflowTimelineTab(), // Section 2: Timeline Workflow
        ),
      ],
    );
  }

  Widget _buildWorkflowTimelineTab() {
    // Find the latest Author request to show in the timeline
    final authorRequests = MockDatabase.roleRequests.where((r) => r.requestedRole == UserRole.author).toList();
    if (authorRequests.isEmpty) {
      return Center(
        child: Text('No workflow data available.', style: GoogleFonts.inter(color: AppColors.of(context).textSecondary)),
      );
    }
    
    final req = authorRequests.last;

    // Logic:
    // Level 1 (Admin) is Pending if status == pendingAdmin
    // Level 1 is Approved if status == pendingSuperAdmin || approved
    // Level 1 is Rejected if status == rejected and adminApprover != null
    bool l1Pending = req.status == RoleRequestStatus.pendingAdmin;
    bool l1Approved = req.status == RoleRequestStatus.pendingSuperAdmin || req.status == RoleRequestStatus.approved;
    bool l1Rejected = req.status == RoleRequestStatus.rejected && req.adminApprover != null;

    // Level 2 (Super Admin) is Locked if Level 1 is pendingAdmin or rejected
    bool l2Locked = l1Pending || l1Rejected;
    bool l2Pending = req.status == RoleRequestStatus.pendingSuperAdmin;
    bool l2Approved = req.status == RoleRequestStatus.approved;
    bool l2Rejected = req.status == RoleRequestStatus.rejected && req.superAdminApprover != null;

    bool showAdminButtons = _currentUserRole == UserRole.admin && l1Pending;
    bool showSuperAdminButtons = _currentUserRole == UserRole.superAdmin && l2Pending;

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
              rejectionReason: l1Rejected ? req.rejectionReason : null,
              isLocked: false,
              actions: showAdminButtons ? _buildInlineActions(req) : null,
            ),
            
            // Vertical Line connector
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
              rejectionReason: l2Rejected ? req.rejectionReason : null,
              isLocked: l2Locked,
              actions: showSuperAdminButtons ? _buildInlineActions(req) : null,
            ).animate(target: l2Locked ? 0 : 1).fade(begin: 0.5, end: 1.0).slideY(begin: 0.1, end: 0, duration: 300.ms),
          ],
        ),
      ).animate().fadeIn(),
    );
  }

  Widget _buildInlineActions(RoleRequestModel request) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _handleRequestApproval(request, false),
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
              onTap: () => _handleRequestApproval(request, true),
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
        text = 'Pending Admin';
        break;
      case RoleRequestStatus.pendingSuperAdmin:
        color = Colors.orangeAccent;
        text = 'Pending Super Admin';
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
    Color bgColor;
    Color textColor = Colors.white;
    switch (role) {
      case UserRole.superAdmin:
        bgColor = Colors.redAccent;
        break;
      case UserRole.admin:
        bgColor = Colors.deepPurple;
        break;
      case UserRole.author:
        bgColor = AppColors.of(context).primary;
        break;
      case UserRole.user:
        bgColor = Colors.grey.shade700;
        break;
    }

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
        style: GoogleFonts.inter(color: textColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildStatusBadge(UserStatus status) {
    Color color;
    switch (status) {
      case UserStatus.active:
        color = Colors.greenAccent;
        break;
      case UserStatus.pending:
        color = Colors.orangeAccent;
        break;
      case UserStatus.blocked:
        color = Colors.redAccent;
        break;
    }

    String s = status.toString().split('.').last;
    s = s[0].toUpperCase() + s.substring(1);

    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(
          s,
          style: GoogleFonts.inter(color: color, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildActionTextBtn(BuildContext context, String title, IconData icon, VoidCallback onTap, {Color? color}) {
    final textColor = color ?? AppColors.of(context).textSecondary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
            Text(title, style: GoogleFonts.inter(color: textColor, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
