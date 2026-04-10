import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/text_styles.dart';

import '../../widgets/app_button.dart';
import 'admin_dashboard.dart';

class UserCreatedScreen extends StatelessWidget {
  const UserCreatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ✅ ICON
              const Icon(Icons.check_circle, size: 80, color: Colors.green),

              AppSpacing.h20,

              // ✅ TITLE
              const Text("User Created!", style: AppTextStyles.heading),

              AppSpacing.h10,

              const Text(
                "The user account has been successfully created.",
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              ),

              AppSpacing.h30,

              // ✅ UPDATED BUTTON TEXT
              AppButton(
                text: "Go to Dashboard",
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminDashboard()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
