class Validators {
  static String? required(String? value, {String fieldName = 'Campo'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName é obrigatório';
    }
    return null;
  }

  static String? maxLength(String? value, int max, {String fieldName = 'Campo'}) {
    if (value != null && value.length > max) {
      return '$fieldName deve ter no máximo $max caracteres';
    }
    return null;
  }

  static String? number(String? value, {String fieldName = 'Campo'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName é obrigatório';
    }
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null) {
      return '$fieldName deve ser um número válido';
    }
    return null;
  }

  static String? positiveNumber(String? value, {String fieldName = 'Campo'}) {
    final numberError = number(value, fieldName: fieldName);
    if (numberError != null) return numberError;
    
    final parsed = double.parse(value!.replaceAll(',', '.'));
    if (parsed < 0) {
      return '$fieldName deve ser positivo';
    }
    return null;
  }

  static String? integer(String? value, {String fieldName = 'Campo'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName é obrigatório';
    }
    final parsed = int.tryParse(value);
    if (parsed == null) {
      return '$fieldName deve ser um número inteiro';
    }
    return null;
  }

  static String? positiveInteger(String? value, {String fieldName = 'Campo'}) {
    final intError = integer(value, fieldName: fieldName);
    if (intError != null) return intError;
    
    final parsed = int.parse(value!);
    if (parsed <= 0) {
      return '$fieldName deve ser maior que zero';
    }
    return null;
  }

  static String? combine(String? value, List<String? Function(String?)> validators) {
    for (var validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  }
}
