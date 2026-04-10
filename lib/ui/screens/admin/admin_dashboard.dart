import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/text_styles.dart';

import '../../widgets/stat_card.dart';
import '../../widgets/activity_tile.dart';
import '../../widgets/app_card.dart';

import '../../../providers/task_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/auth_provider.dart';

import 'create_user_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  // ✅ Helper to safely get first letter
  String getInitial(String name) {
    if (name.trim().isEmpty) return "?";
    return name.trim()[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final total = taskProvider.totalTasks;
    final completed = taskProvider.completedTasks;
    final pending = taskProvider.pendingTasks;
    final deleted = taskProvider.deletedTasks;

    final recentTasks = taskProvider.recentTasks;
    final users = userProvider.users;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateUserScreen()),
          );
        },
        label: const Text("+ Add User"),
      ),

      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔥 HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "TaskPilot",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      const Text(
                        "Admin",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 10),
                      const CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage(
                          'assets/images/profile-pic.jpg',
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              AppSpacing.h20,

              // 🔥 STATS
              AppCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: "Total Tasks",
                            count: total,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: StatCard(
                            title: "Pending Tasks",
                            count: pending,
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
                            count: completed,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: StatCard(
                            title: "Deleted Tasks",
                            count: deleted,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              AppSpacing.h20,

              // 🔥 MANAGE USERS HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Manage Users", style: AppTextStyles.subHeading),
                  Text("View All"),
                ],
              ),

              AppSpacing.h10,

              // 🔥 USERS LIST
              AppCard(
                child: Column(
                  children: users.isEmpty
                      ? [
                          const Padding(
                            padding: EdgeInsets.all(10),
                            child: Text("No users found"),
                          ),
                        ]
                      : users.map((user) {
                          final safeName = user.name.trim().isEmpty
                              ? "No Name"
                              : user.name;

                          return GestureDetector(
                            onLongPress: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text("Delete User"),
                                    content: Text(
                                      "Are you sure you want to delete $safeName?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          if (auth.currentUser?.id == user.id) {
                                            Navigator.pop(context);

                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "You cannot delete yourself",
                                                ),
                                              ),
                                            );
                                            return;
                                          }

                                          userProvider.deleteUser(user);

                                          Navigator.pop(context);

                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "User deleted successfully",
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          "Delete",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },

                            // 🔥 USER TILE
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Colors.orange.shade100,
                                    child: Text(
                                      getInitial(user.name),
                                      style: const TextStyle(
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          safeName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          user.email.isNotEmpty
                                              ? user.email
                                              : "No Email",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: user.role == 'admin'
                                          ? Colors.green.withOpacity(0.2)
                                          : Colors.blue.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      user.role,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: user.role == 'admin'
                                            ? Colors.green
                                            : Colors.blue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                ),
              ),

              AppSpacing.h20,

              // 🔥 ACTIVITY HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Recent Activity", style: AppTextStyles.subHeading),
                  Text("View All"),
                ],
              ),

              AppSpacing.h10,

              // 🔥 ACTIVITY LIST (SAFE)
              Expanded(
                child: recentTasks.isEmpty
                    ? const Center(child: Text("No recent activity"))
                    : ListView(
                        children: recentTasks
                            .map(
                              (task) =>
                                  ActivityTile(name: task.title ?? "No Title"),
                            )
                            .toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
