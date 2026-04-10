class Validators {
  // 📧 EMAIL
  static String? email(String value) {
    if (value.isEmpty) return "Email is required";

    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!regex.hasMatch(value)) {
      return "Enter valid email";
    }

    return null;
  }

  // 🔒 PASSWORD
  static String? password(String value) {
    if (value.isEmpty) return "Password is required";

    if (value.length < 6) {
      return "Minimum 6 characters required";
    }

    return null;
  }

  // 👤 NAME
  static String? name(String value) {
    if (value.isEmpty) return "Name is required";
    return null;
  }
}
