import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';
import '../theme/app_theme.dart';

class AddActivityScreen extends StatefulWidget {
  final String cropId;
  const AddActivityScreen({super.key, required this.cropId});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _costController = TextEditingController();
  ActivityType _type = ActivityType.irrigation;
  DateTime _date = DateTime.now();
  bool _isLoading = false;
  late String _selectedCropId;

  @override
  void initState() {
    super.initState();
    _selectedCropId = widget.cropId;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    final state = context.read<AppState>();
    state.addActivity(Activity(
      id: state.newId(),
      cropId: _selectedCropId,
      type: _type,
      date: _date,
      description: _descriptionController.text.trim(),
      cost: double.tryParse(_costController.text.replaceAll(',', '.')) ?? 0,
      createdAt: DateTime.now(),
    ));
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Actividad registrada exitosamente'),
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
        title: const Text('Nueva Actividad'),
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
                const SizedBox(height: 20),
              ],
              Text('Tipo de actividad', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ActivityType.values.map((t) {
                  final selected = _type == t;
                  return GestureDetector(
                    onTap: () => setState(() => _type = t),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: selected ? LinearGradient(colors: [t.color, t.color.withOpacity(0.75)]) : null,
                        color: selected ? null : t.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: t.color.withOpacity(selected ? 0 : 0.4)),
                        boxShadow: selected ? [BoxShadow(color: t.color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))] : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(t.icon, size: 16, color: selected ? Colors.white : t.color),
                          const SizedBox(width: 6),
                          Text(t.label, style: TextStyle(color: selected ? Colors.white : t.color, fontWeight: FontWeight.w700, fontSize: 13)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
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
                          const Text('Fecha de actividad', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(dateFormat.format(_date), style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.edit_outlined, size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Descripción',
                controller: _descriptionController,
                maxLines: 3,
                prefixIcon: const Icon(Icons.description_outlined),
                validator: (v) => v == null || v.trim().isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Costo (COP)',
                controller: _costController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.monetization_on_outlined),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Campo obligatorio';
                  if (double.tryParse(v.replaceAll(',', '.')) == null) return 'Ingresa un valor válido';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Guardar Actividad'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
