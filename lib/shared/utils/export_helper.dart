import 'package:share_plus/share_plus.dart';
import '../../modules/shopping_list/list_model.dart';
import '../../modules/calculator/calculator_model.dart';
import '../../modules/debts/debts_model.dart';

class ExportHelper {
  static Future<void> exportShoppingList(ShoppingList list) async {
    final buffer = StringBuffer();
    buffer.writeln('📋 ${list.title}\n');
    
    final unchecked = list.items.where((e) => !e.checked).toList();
    final checked = list.items.where((e) => e.checked).toList();
    
    if (unchecked.isNotEmpty) {
      buffer.writeln('Pendentes:');
      for (var item in unchecked) {
        buffer.writeln('☐ ${item.name}');
      }
      buffer.writeln();
    }
    
    if (checked.isNotEmpty) {
      buffer.writeln('Concluídos:');
      for (var item in checked) {
        buffer.writeln('☑ ${item.name}');
      }
    }
    
    await Share.share(buffer.toString(), subject: list.title);
  }

  static Future<void> exportCalculator(List<CalculatorItem> items, double total) async {
    final buffer = StringBuffer();
    buffer.writeln('🧮 Calculadora de Compras\n');
    
    for (var item in items) {
      buffer.writeln('${item.description}');
      buffer.writeln('  ${item.quantity} x R\$ ${item.price.toStringAsFixed(2)} = R\$ ${item.total.toStringAsFixed(2)}');
    }
    
    buffer.writeln('\n━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('TOTAL: R\$ ${total.toStringAsFixed(2)}');
    
    await Share.share(buffer.toString(), subject: 'Calculadora de Compras');
  }

  static Future<void> exportDebtSheet(DebtSheet sheet) async {
    final buffer = StringBuffer();
    buffer.writeln('💰 ${sheet.name}\n');
    
    buffer.writeln('Orçamento:');
    buffer.writeln('  Dia 15: R\$ ${sheet.budget15.toStringAsFixed(2)}');
    buffer.writeln('  Dia 30: R\$ ${sheet.budget30.toStringAsFixed(2)}');
    buffer.writeln('  Total: R\$ ${(sheet.budget15 + sheet.budget30).toStringAsFixed(2)}\n');
    
    final debts15 = sheet.debts.where((d) => d.day == 15).toList();
    final debts30 = sheet.debts.where((d) => d.day == 30).toList();
    
    if (debts15.isNotEmpty) {
      buffer.writeln('Dívidas dia 15:');
      for (var debt in debts15) {
        buffer.writeln('  • ${debt.title}: R\$ ${debt.value.toStringAsFixed(2)}');
      }
      buffer.writeln();
    }
    
    if (debts30.isNotEmpty) {
      buffer.writeln('Dívidas dia 30:');
      for (var debt in debts30) {
        buffer.writeln('  • ${debt.title}: R\$ ${debt.value.toStringAsFixed(2)}');
      }
      buffer.writeln();
    }
    
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('Total Dívidas: R\$ ${sheet.total.toStringAsFixed(2)}');
    final remaining = (sheet.budget15 + sheet.budget30) - sheet.total;
    buffer.writeln('Saldo: R\$ ${remaining.toStringAsFixed(2)}');
    
    await Share.share(buffer.toString(), subject: sheet.name);
  }
}
