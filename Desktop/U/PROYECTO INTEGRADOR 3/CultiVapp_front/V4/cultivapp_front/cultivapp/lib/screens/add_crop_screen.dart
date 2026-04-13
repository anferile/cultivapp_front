import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';
import '../theme/app_theme.dart';

class AddCropScreen extends StatefulWidget {
  const AddCropScreen({super.key});

  @override
  State<AddCropScreen> createState() => _AddCropScreenState();
}

class _AddCropScreenState extends State<AddCropScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _customTypeController = TextEditingController();
  DateTime _sowingDate = DateTime.now();
  CropStatus _status = CropStatus.active;
  String? _selectedType;
  bool _isLoading = false;
  bool _showCustomType = false;

  final List<String> _cropTypes = [
    'Maíz', 'Tomate', 'Papa', 'Arroz', 'Frijol', 'Café',
    'Caña de azúcar', 'Plátano', 'Yuca', 'Cebolla', 'Otro',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _customTypeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _sowingDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _sowingDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    final state = context.read<AppState>();
    final type = _showCustomType ? _customTypeController.text.trim() : (_selectedType ?? '');
    state.addCrop(Crop(
      id: state.newId(),
      name: _nameController.text.trim(),
      type: type,
      location: _locationController.text.trim(),
      sowingDate: _sowingDate,
      status: _status,
      createdAt: DateTime.now(),
    ));
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Cultivo registrado exitosamente'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy', 'es');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Cultivo'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: AppColors.heroGradientLight),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionLabel(label: 'Información del cultivo'),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Nombre del cultivo',
                controller: _nameController,
                prefixIcon: const Icon(Icons.grass),
                validator: (v) => v == null || v.trim().isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 16),
              // Tipo dropdown
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Tipo de cultivo',
                  prefixIcon: const Icon(Icons.category_outlined),
                  filled: true,
                  fillColor: isDark ? AppColors.cardDark : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: isDark ? Colors.green.shade900 : Colors.green.shade100),
                  ),
                ),
                items: _cropTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() {
                  _selectedType = v;
                  _showCustomType = v == 'Otro';
                }),
                validator: (v) => v == null || v.isEmpty ? 'Selecciona un tipo' : null,
              ),
              // Show custom type field when "Otro" selected
              if (_showCustomType) ...[
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Especifica el tipo de cultivo',
                  controller: _customTypeController,
                  prefixIcon: const Icon(Icons.edit_outlined),
                  validator: (v) => _showCustomType && (v == null || v.trim().isEmpty)
                      ? 'Escribe el tipo de cultivo'
                      : null,
                ),
              ],
              const SizedBox(height: 16),
              AppTextField(
                label: 'Ubicación o parcela',
                controller: _locationController,
                prefixIcon: const Icon(Icons.location_on_outlined),
                validator: (v) => v == null || v.trim().isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 16),
              // Date picker
              GestureDetector(
                onTap: _pickDate,
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
                          const Text('Fecha de siembra', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(dateFormat.format(_sowingDate), style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.edit_outlined, size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _SectionLabel(label: 'Estado inicial'),
              const SizedBox(height: 4),
              Text(
                'El cultivo nuevo se marca como Activo por defecto.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Row(
                children: [CropStatus.active, CropStatus.growing].map((s) {
                  final selected = _status == s;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _status = s),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: selected
                              ? LinearGradient(colors: [s.color, s.color.withOpacity(0.7)])
                              : null,
                          color: selected ? null : s.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: s.color.withOpacity(selected ? 0 : 0.4)),
                          boxShadow: selected
                              ? [BoxShadow(color: s.color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(s.icon, size: 16, color: selected ? Colors.white : s.color),
                            const SizedBox(width: 6),
                            Text(
                              s.label,
                              style: TextStyle(
                                color: selected ? Colors.white : s.color,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Guardar Cultivo'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 4, height: 18, decoration: BoxDecoration(
          gradient: const LinearGradient(colors: AppColors.heroGradientLight, begin: Alignment.topCenter, end: Alignment.bottomCenter),
          borderRadius: BorderRadius.circular(2),
        )),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
