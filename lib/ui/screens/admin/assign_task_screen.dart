import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import '../../../providers/task_provider.dart';
import '../../../providers/user_provider.dart';

import 'task_assigned_screen.dart';

class AssignTaskScreen extends StatefulWidget {
  const AssignTaskScreen({super.key});

  @override
  State<AssignTaskScreen> createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends State<AssignTaskScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  String? selectedUserId;
  String selectedPriority = "Medium";
  DateTime? selectedDate;

  /// 📎 FILE VARIABLES
  String? pickedFileName;
  String? pickedFilePath;

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  // 🔥 DATE PICKER
  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // 📎 PICK FILE FUNCTION
  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.pickFiles();

    if (result != null) {
      setState(() {
        pickedFileName = result.files.single.name;
        pickedFilePath = result.files.single.path;
      });
    }
  }

  // 🔥 PRIORITY BUTTON
  Widget buildPriority(String label) {
    final isSelected = selectedPriority == label;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedPriority = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 INPUT FIELD
  Widget buildField({
    required String hint,
    required IconData icon,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // 🔥 ASSIGN TASK
  void assignTask() {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter task title")));
      return;
    }

    if (selectedUserId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Select user")));
      return;
    }

    taskProvider.addTask(
      titleController.text.trim(),
      selectedUserId!,
      context,
      fileName: pickedFileName,
      fileUrl: pickedFilePath,
      dueDate: selectedDate,
      priority: selectedPriority,
      description: descController.text.trim(),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const TaskAssignedScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    final users = userProvider.users
        .where((user) => user.role.toLowerCase() == "user")
        .toList();

    if (selectedUserId != null &&
        !users.any((user) => user.id == selectedUserId)) {
      selectedUserId = null;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Assign Task"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  // TITLE
                  buildField(
                    hint: "Task Title",
                    icon: Icons.title,
                    controller: titleController,
                  ),

                  const SizedBox(height: 15),

                  // DESCRIPTION
                  buildField(
                    hint: "Description",
                    icon: Icons.description,
                    controller: descController,
                  ),

                  const SizedBox(height: 15),

                  // USER DROPDOWN
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedUserId,
                      underline: const SizedBox(),
                      hint: const Text("Select User"),
                      items: users.map((user) {
                        return DropdownMenuItem<String>(
                          value: user.id,
                          child: Text(user.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedUserId = value;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 15),

                  // DATE PICKER
                  GestureDetector(
                    onTap: pickDate,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 10),
                          Text(
                            selectedDate == null
                                ? "Select Due Date"
                                : "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}",
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // PRIORITY
                  Row(
                    children: [
                      buildPriority("Low"),
                      buildPriority("Medium"),
                      buildPriority("High"),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // ATTACH FILE
                  GestureDetector(
                    onTap: pickFile,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.attach_file),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              pickedFileName ?? "Attach File",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (pickedFileName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        "Selected: $pickedFileName",
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                ],
              ),
            ),

            // BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: assignTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Assign Task",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
