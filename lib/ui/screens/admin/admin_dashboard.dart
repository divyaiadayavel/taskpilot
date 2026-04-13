import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/text_styles.dart';

import '../../widgets/stat_card.dart';
import '../../widgets/app_card.dart';

import '../../../providers/task_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/activity_provider.dart';

import '../../../data/models/user_model.dart';
import '../auth/login_screen.dart';
import 'create_user_screen.dart';
import 'assign_task_screen.dart';
import 'user_details_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedIndex = 0;

  /// ✅ PICK AND CROP IMAGE FUNCTION
  Future<void> _pickAndCropImage(BuildContext context, UserModel user) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);

    if (file == null) return;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: file.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Adjust Profile Photo',
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          aspectRatioPresets: [CropAspectRatioPreset.square],
        ),
        IOSUiSettings(
          title: 'Adjust Photo',
          aspectRatioPresets: [CropAspectRatioPreset.square],
        ),
      ],
    );

    if (croppedFile != null && context.mounted) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.updateProfileImage(user, croppedFile.path);
    }
  }

  /// ✅ DELETE USER CONFIRM POPUP
  Future<void> _showDeleteUserDialog(
    BuildContext context,
    dynamic user,
    UserProvider userProvider,
  ) async {
    final safeName = user.name.toString().trim().isEmpty
        ? "No Name"
        : user.name;

    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete User"),
        content: Text("Do you want to delete $safeName?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      taskProvider.deleteTasksByUser(user.id);
      userProvider.deleteUser(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final activityProvider = Provider.of<ActivityProvider>(context);

    final activities = activityProvider.activities;
    final users = userProvider.users;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => selectedIndex = 0);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AssignTaskScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: selectedIndex == 0
                        ? AppColors.primary
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: selectedIndex == 0 ? Colors.white : Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Assign Task",
                        style: TextStyle(
                          color: selectedIndex == 0
                              ? Colors.white
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => selectedIndex = 1);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateUserScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: selectedIndex == 1
                        ? AppColors.primary
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_add,
                        color: selectedIndex == 1 ? Colors.white : Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Add User",
                        style: TextStyle(
                          color: selectedIndex == 1
                              ? Colors.white
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "TaskPilot",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Text(auth.currentUser?.name ?? "Admin"),
                        const SizedBox(width: 10),

                        /// ✅ RESTORED PROFILE AVATAR WITH TAP TO CHANGE
                        GestureDetector(
                          onTap: () {
                            if (auth.currentUser != null) {
                              _pickAndCropImage(context, auth.currentUser!);
                            }
                          },
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.primary,
                            backgroundImage:
                                auth.currentUser?.profileImage != null
                                ? FileImage(
                                    File(auth.currentUser!.profileImage!),
                                  )
                                : null,
                            child: auth.currentUser?.profileImage == null
                                ? Text(
                                    auth.currentUser?.name[0].toUpperCase() ??
                                        "A",
                                    style: const TextStyle(color: Colors.white),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Logout"),
                                content: const Text("Are you sure?"),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text("Logout"),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await auth.logout();
                              if (context.mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                  (route) => false,
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),

                AppSpacing.h20,

                /// STATS
                AppCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              title: "Total Tasks",
                              count: taskProvider.totalTasks,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatCard(
                              title: "Pending Tasks",
                              count: taskProvider.pendingTasks,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              title: "Completed Tasks",
                              count: taskProvider.completedTasks,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatCard(
                              title: "Deleted Tasks",
                              count: taskProvider.deletedTasks,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                AppSpacing.h20,

                /// MANAGE USERS
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Manage Users",
                        style: AppTextStyles.subHeading,
                      ),
                      AppSpacing.h10,
                      ...users.map((user) {
                        final safeName = user.name.trim().isEmpty
                            ? "No Name"
                            : user.name;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundImage: user.profileImage != null
                                ? FileImage(File(user.profileImage!))
                                : null,
                            child: user.profileImage == null
                                ? Text(safeName[0].toUpperCase())
                                : null,
                          ),
                          title: Text(safeName),
                          trailing: Text(user.role),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UserDetailsScreen(user: user),
                              ),
                            );
                          },
                          onLongPress: () {
                            _showDeleteUserDialog(context, user, userProvider);
                          },
                        );
                      }),
                    ],
                  ),
                ),

                AppSpacing.h20,

                /// RECENT ACTIVITY
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Recent User Activity",
                        style: AppTextStyles.subHeading,
                      ),
                      AppSpacing.h10,
                      ...activities.take(5).map((activity) {
                        final actUser = users.firstWhere(
                          (u) => u.id == activity.userId,
                          orElse: () => users.first,
                        );

                        IconData icon;
                        Color color;
                        switch (activity.action) {
                          case "completed":
                            icon = Icons.check;
                            color = Colors.green;
                            break;
                          case "deleted":
                            icon = Icons.delete;
                            color = Colors.red;
                            break;
                          default:
                            icon = Icons.add;
                            color = Colors.orange;
                        }

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: color,
                            child: Icon(icon, color: Colors.white, size: 16),
                          ),
                          title: Text("${actUser.name} (${actUser.role})"),
                          subtitle: Text(
                            "${activity.action} '${activity.taskTitle}'",
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
