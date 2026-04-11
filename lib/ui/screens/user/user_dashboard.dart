import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/colors.dart';
import '../../../providers/task_provider.dart';
import '../../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  String filter = "All";
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    final taskProvider = Provider.of<TaskProvider>(context);

    if (user == null) {
      return const Scaffold(body: Center(child: Text("User not found")));
    }

    /// ✅ FILTER TASKS
    List tasks = taskProvider.getUserTasks(user.id, filter);

    /// ✅ SEARCH FILTER
    if (searchQuery.isNotEmpty) {
      tasks = tasks
          .where(
            (t) => t.title.toLowerCase().contains(searchQuery.toLowerCase()),
          )
          .toList();
    }

    return Scaffold(
      // backgroundColor: AppColors.background,

      /// 🔥 APPBAR WITH LOGOUT CONFIRM
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("TaskPilot"),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 10),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: AppColors.primary),
            ),
          ),

          /// ✅ LOGOUT WITH CONFIRM
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirm = await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await auth.logout();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 👋 GREETING
            Text(
              "Hi ${user.name}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            const Text(
              "Let’s complete your tasks efficiently",
              style: TextStyle(color: AppColors.textSecondary),
            ),

            const SizedBox(height: 16),

            /// 🔍 SEARCH BAR
            TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Search tasks...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// 🔘 FILTER CHIPS
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildFilter("All"),
                  buildFilter("Pending"),
                  buildFilter("Completed"),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// 📋 TASK LIST
            Expanded(
              child: tasks.isEmpty
                  ? const Center(child: Text("No tasks assigned"))
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// TITLE
                              Text(
                                task.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 6),

                              /// DESCRIPTION (OPTIONAL)
                              if (task.description != null &&
                                  task.description.isNotEmpty)
                                Text(task.description),

                              const SizedBox(height: 8),

                              /// STATUS + ACTION
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    task.isDone ? "Completed" : "Pending",
                                    style: TextStyle(
                                      color: task.isDone
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                  ),

                                  /// ✅ TOGGLE BUTTON
                                  IconButton(
                                    icon: Icon(
                                      task.isDone
                                          ? Icons.check_circle
                                          : Icons.radio_button_unchecked,
                                      color: task.isDone
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                    onPressed: () {
                                      taskProvider.toggleTask(task, context);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔘 FILTER BUTTON
  Widget buildFilter(String text) {
    final isSelected = filter == text;

    return GestureDetector(
      onTap: () {
        setState(() => filter = text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(color: isSelected ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}
