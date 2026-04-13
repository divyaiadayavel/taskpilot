import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:open_filex/open_filex.dart';

import '../../../providers/task_provider.dart';
import '../../../providers/activity_provider.dart';

class UserDetailsScreen extends StatelessWidget {
  final dynamic user;

  const UserDetailsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    final activityProvider = Provider.of<ActivityProvider>(context);

    /// 🔥 USER TASKS
    final tasks = taskProvider.tasks
        .where((task) => task.userId == user.id)
        .toList();

    /// 🔥 USER HISTORY
    final history = activityProvider.activities
        .where((a) => a.userId == user.id)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(user.name), backgroundColor: Colors.orange),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            /// USER INFO
            Card(
              child: ListTile(
                leading: CircleAvatar(child: Text(user.name[0].toUpperCase())),
                title: Text(user.name),
                subtitle: Text(user.email),
                trailing: Text(user.role),
              ),
            ),

            const SizedBox(height: 20),

            /// TASK TITLE
            const Text(
              "Assigned Tasks",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            if (tasks.isEmpty) const Text("No tasks assigned"),

            ...tasks.map((task) {
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: Icon(
                    task.isDone ? Icons.check_circle : Icons.pending,
                    color: task.isDone ? Colors.green : Colors.orange,
                  ),

                  title: Text(task.title),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),

                      /// PRIORITY
                      Text("Priority: ${task.priority ?? 'Medium'}"),

                      /// DUE DATE
                      Text(
                        "Due: ${task.dueDate != null ? task.dueDate.toString().split(' ')[0] : 'No Date'}",
                      ),

                      const SizedBox(height: 6),

                      /// FILE
                      if (task.fileName != null && task.fileName!.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.attach_file, size: 16),
                            const SizedBox(width: 5),

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
                                  final result = await OpenFilex.open(
                                    task.fileUrl!,
                                  );

                                  if (result.type != ResultType.done &&
                                      context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(result.message)),
                                    );
                                  }
                                }
                              },
                              child: const Text("View"),
                            ),
                          ],
                        )
                      else
                        const Text("No File"),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),

            /// HISTORY
            const Text(
              "User Activity History",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            if (history.isEmpty) const Text("No activity found"),

            ...history.map((item) {
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const Icon(Icons.history),

                  title: Text("${item.action} '${item.taskTitle}'"),

                  subtitle: Text(
                    "${item.time.day}-${item.time.month}-${item.time.year} "
                    "${item.time.hour}:${item.time.minute.toString().padLeft(2, '0')}",
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
