import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:open_filex/open_filex.dart';

import '../../../core/constants/colors.dart';
import '../../../providers/task_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/user_provider.dart';
import '../auth/login_screen.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  String filter = "All";

  /// ✅ PICK + CROP PROFILE IMAGE
  Future<void> _pickProfileImage() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Profile',
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(title: 'Crop Profile', aspectRatioLockEnabled: true),
      ],
    );

    if (cropped != null && auth.currentUser != null && context.mounted) {
      userProvider.updateProfileImage(auth.currentUser!, cropped.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    final taskProvider = Provider.of<TaskProvider>(context);

    if (user == null) {
      return const Scaffold(body: Center(child: Text("User not found")));
    }

    final tasks = taskProvider.getUserTasks(user.id, filter);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text("TaskPilot", style: TextStyle(color: Colors.white)),
        actions: [
          /// ✅ PROFILE IMAGE
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: _pickProfileImage,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage:
                    user.profileImage != null && user.profileImage!.isNotEmpty
                    ? FileImage(File(user.profileImage!))
                    : null,
                child: (user.profileImage == null || user.profileImage!.isEmpty)
                    ? Text(
                        user.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            ),
          ),

          /// LOGOUT
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
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

                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
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
            /// GREETING
            Text(
              "Hi ${user.name}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            const Text(
              "Let’s complete your tasks efficiently",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            /// TASK LIST
            Expanded(
              child: tasks.isEmpty
                  ? const Center(child: Text("No tasks assigned"))
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
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

                                const SizedBox(height: 8),

                                /// DESCRIPTION
                                if (task.description != null &&
                                    task.description!.isNotEmpty)
                                  Text(task.description!),

                                const SizedBox(height: 8),

                                /// PRIORITY
                                Row(
                                  children: [
                                    const Icon(Icons.flag, size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Priority: ${task.priority ?? 'Medium'}",
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 6),

                                /// DUE DATE
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      task.dueDate != null
                                          ? "Due: ${task.dueDate.toString().split(' ')[0]}"
                                          : "Due: No Date",
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                /// FILE VIEW
                                if (task.fileName != null &&
                                    task.fileName!.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.attach_file),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            task.fileName!,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            if (task.fileUrl != null &&
                                                task.fileUrl!.isNotEmpty) {
                                              final result =
                                                  await OpenFilex.open(
                                                    task.fileUrl!,
                                                  );

                                              if (result.type !=
                                                      ResultType.done &&
                                                  context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      result.message,
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                          child: const Text("View"),
                                        ),
                                      ],
                                    ),
                                  ),

                                const SizedBox(height: 10),

                                /// STATUS
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
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

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
}
