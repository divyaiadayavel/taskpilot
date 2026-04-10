import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';

import '../../../providers/task_provider.dart';
import '../../../providers/auth_provider.dart';

import '../../widgets/task_tile.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    final userId = auth.currentUser!.id;

    final userTasks = taskProvider.tasks
        .where((task) => task.userId == userId)
        .toList();

    final controller = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,

      appBar: AppBar(
        title: const Text("My Tasks"),
        backgroundColor: AppColors.primary,
      ),

      body: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          children: [
            // 🔥 ADD TASK
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: "Add a new task...",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (controller.text.isEmpty) return;

                    taskProvider.addTask(controller.text, userId);

                    controller.clear();
                  },
                ),
              ],
            ),

            AppSpacing.h20,

            // 🔥 TASK LIST
            Expanded(
              child: userTasks.isEmpty
                  ? const Center(child: Text("No tasks yet"))
                  : ListView.builder(
                      itemCount: userTasks.length,
                      itemBuilder: (context, index) {
                        final task = userTasks[index];

                        return TaskTile(
                          task: task,
                          onToggle: () => taskProvider.toggleTask(task),
                          onDelete: () => taskProvider.deleteTask(task),
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
