import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';
import '../theme/app_theme.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final currency = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    final expenses = List<Expense>.from(state.expenses)..sort((a, b) => b.date.compareTo(a.date));
    final total = expenses.fold(0.0, (sum, e) => sum + e.amount);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: GradientHeader(
              height: 150,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 10),
                        const Text('Gastos e Insumos', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(currency.format(total), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                    const Text('Total en gastos', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
          expenses.isEmpty
              ? SliverFillRemaining(
                  child: EmptyState(
                    message: 'No hay gastos registrados.\nToca + para agregar uno.',
                    icon: Icons.receipt_long_outlined,
                    actionLabel: state.crops.isEmpty ? null : 'Agregar gasto',
                    onAction: state.crops.isEmpty ? null : () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => AddExpenseScreen(cropId: state.crops.first.id)),
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final e = expenses[i];
                        final crop = state.crops.where((c) => c.id == e.cropId).firstOrNull
                            ?? state.archivedCrops.where((c) => c.id == e.cropId).firstOrNull;
                        return _ExpenseListItem(expense: e, cropName: crop?.name ?? 'Cultivo eliminado', state: state);
                      },
                      childCount: expenses.length,
                    ),
                  ),
                ),
        ],
      ),
      floatingActionButton: state.crops.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => AddExpenseScreen(cropId: state.crops.first.id)),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo gasto'),
              backgroundColor: AppColors.warning,
            ),
    );
  }
}

class _ExpenseListItem extends StatelessWidget {
  final Expense expense;
  final String cropName;
  final AppState state;
  const _ExpenseListItem({required this.expense, required this.cropName, required this.state});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy', 'es');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: AppColors.warning.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.warning.withOpacity(0.2), AppColors.warning.withOpacity(0.08)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.receipt_long, color: AppColors.warning, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.description, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                Text(expense.category, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text('$cropName  •  ${dateFormat.format(expense.date)}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(currency.format(expense.amount), style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => state.deleteExpense(expense.id),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: const Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AddExpenseScreen extends StatefulWidget {
  final String cropId;
  const AddExpenseScreen({super.key, required this.cropId});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _date = DateTime.now();
  bool _isLoading = false;
  late String _selectedCropId;
  String _category = 'Semillas';

  final List<String> _categories = [
    'Semillas', 'Fertilizantes', 'Plaguicidas', 'Herramientas',
    'Mano de obra', 'Riego', 'Transporte', 'Otro',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCropId = widget.cropId;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    final state = context.read<AppState>();
    state.addExpense(Expense(
      id: state.newId(),
      cropId: _selectedCropId,
      description: _descriptionController.text.trim(),
      amount: double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0,
      category: _category,
      date: _date,
      createdAt: DateTime.now(),
    ));
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Gasto registrado exitosamente'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final dateFormat = DateFormat('dd/MM/yyyy', 'es');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Gasto'),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: LinearGradient(colors: AppColors.heroGradientLight)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.crops.isNotEmpty) ...[
                DropdownButtonFormField<String>(
                  value: _selectedCropId.isEmpty ? null : _selectedCropId,
                  decoration: InputDecoration(
                    labelText: 'Cultivo',
                    prefixIcon: const Icon(Icons.grass),
                    filled: true,
                    fillColor: isDark ? AppColors.cardDark : Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: isDark ? Colors.green.shade900 : Colors.green.shade100),
                    ),
                  ),
                  items: state.crops.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                  onChanged: (v) => setState(() => _selectedCropId = v ?? ''),
                  validator: (v) => v == null || v.isEmpty ? 'Selecciona un cultivo' : null,
                ),
                const SizedBox(height: 16),
              ],
              DropdownButtonFormField<String>(
                value: _category,
                decoration: InputDecoration(
                  labelText: 'Categoría',
                  prefixIcon: const Icon(Icons.category_outlined),
                  filled: true,
                  fillColor: isDark ? AppColors.cardDark : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: isDark ? Colors.green.shade900 : Colors.green.shade100),
                  ),
                ),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _category = v ?? 'Otro'),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Descripción del gasto',
                controller: _descriptionController,
                maxLines: 2,
                prefixIcon: const Icon(Icons.description_outlined),
                validator: (v) => v == null || v.trim().isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Monto (COP)',
                controller: _amountController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.monetization_on_outlined),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Campo obligatorio';
                  if (double.tryParse(v.replaceAll(',', '.')) == null) return 'Valor inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isDark ? Colors.green.shade900 : Colors.green.shade100),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 20, color: Colors.grey),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Fecha del gasto', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(dateFormat.format(_date), style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.edit_outlined, size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Guardar Gasto'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
