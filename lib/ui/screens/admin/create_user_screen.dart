import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';

import '../../widgets/app_button.dart';
import '../../widgets/app_textfield.dart';
import '../../widgets/app_card.dart';

import '../../../providers/user_provider.dart';
import 'user_created_screen.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String selectedRole = "user";

  @override
  void dispose() {
    // ✅ Prevent memory leaks
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text("Create User"),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: AppSpacing.screenPadding,
        child: Form(
          key: formKey,
          child: Column(
            children: [
              // 🔥 FORM CONTAINER
              AppCard(
                child: Column(
                  children: [
                    // ✅ NAME FIELD
                    AppTextField(
                      hint: "Full Name",
                      controller: nameController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Name is required";
                        }
                        return null;
                      },
                    ),
                    AppSpacing.h10,

                    // ✅ EMAIL FIELD
                    AppTextField(
                      hint: "Email",
                      controller: emailController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Email is required";
                        }
                        if (!value.contains("@")) {
                          return "Enter valid email";
                        }
                        return null;
                      },
                    ),
                    AppSpacing.h10,

                    // ✅ PASSWORD FIELD
                    AppTextField(
                      hint: "Password",
                      controller: passwordController,
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Password is required";
                        }
                        if (value.length < 4) {
                          return "Minimum 4 characters";
                        }
                        return null;
                      },
                    ),
                    AppSpacing.h10,

                    // ✅ ROLE DROPDOWN
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      items: const [
                        DropdownMenuItem(value: "user", child: Text("User")),
                        DropdownMenuItem(value: "admin", child: Text("Admin")),
                      ],
                      onChanged: (val) {
                        setState(() {
                          selectedRole = val!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: "Role",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),

              AppSpacing.h20,

              // ✅ CREATE BUTTON
              AppButton(
                text: "Create Account",
                onTap: () {
                  if (formKey.currentState!.validate()) {
                    userProvider.addUser(
                      nameController.text.trim(),
                      emailController.text.trim(),
                      passwordController.text.trim(),
                      selectedRole,
                    );

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UserCreatedScreen(),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
