class FormValidators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Veuillez entrer un email valide';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre mot de passe';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer votre mot de passe';
    }
    if (value != password) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer $fieldName';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Le numéro de téléphone est optionnel
    }
    if (!RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$').hasMatch(value)) {
      return 'Veuillez entrer un numéro de téléphone valide';
    }
    return null;
  }
}
