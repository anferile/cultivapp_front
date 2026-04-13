import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'user_manual_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.currentUser;
    final currency = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: GradientHeader(
              height: 160,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white.withOpacity(0.25),
                      child: Text(
                        user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : 'U',
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(user?.fullName ?? 'Usuario',
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                          Text(user?.contact ?? '',
                              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stats
                Row(
                  children: [
                    Expanded(child: StatCard(title: 'Cultivos', value: state.crops.length.toString(), icon: Icons.grass, color: AppColors.primary)),
                    const SizedBox(width: 12),
                    Expanded(child: StatCard(title: 'Actividades', value: state.activities.length.toString(), icon: Icons.assignment, color: AppColors.info)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: StatCard(title: 'Gastos', value: state.expenses.length.toString(), icon: Icons.receipt_long, color: AppColors.warning)),
                    const SizedBox(width: 12),
                    Expanded(child: StatCard(title: 'Cosechados', value: state.archivedCrops.length.toString(), icon: Icons.agriculture, color: AppColors.accent)),
                  ],
                ),
                const SizedBox(height: 24),

                // Resumen por cultivo
                if (state.crops.isNotEmpty) ...[
                  const SectionHeader(title: 'Resumen por cultivo'),
                  const SizedBox(height: 12),
                  ...state.crops.map((c) => _CropSummaryCard(crop: c, state: state)),
                  const SizedBox(height: 24),
                ],

                // Configuración
                const SectionHeader(title: 'Configuración'),
                const SizedBox(height: 12),
                _SettingsCard(
                  children: [
                    SwitchListTile(
                      title: const Text('Modo oscuro', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Tema verde oscuro elegante'),
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                        child: Icon(state.isDarkMode ? Icons.dark_mode : Icons.light_mode, color: AppColors.primary, size: 20),
                      ),
                      value: state.isDarkMode,
                      activeColor: AppColors.primary,
                      onChanged: (_) => state.toggleDarkMode(),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppColors.info.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.menu_book_outlined, color: AppColors.info, size: 20),
                      ),
                      title: const Text('Manual de uso', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Aprende a usar CultivApp'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserManualScreen())),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.science_outlined, color: AppColors.accent, size: 20),
                      ),
                      title: const Text('Datos de prueba', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Cargar o limpiar datos demo'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showDemoTemplates(context, state),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                      ),
                      title: const Text('Acerca de CultivApp', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Versión 1.0.0'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showAbout(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _confirmLogout(context, state),
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar sesión'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showDemoTemplates(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('Datos de prueba', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text('Carga cultivos de ejemplo para explorar la app.', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 20),
            _TemplateOption(
              icon: Icons.filter_1,
              title: 'Pocos cultivos',
              subtitle: '1 cultivo con actividades básicas',
              color: AppColors.info,
              onTap: () { Navigator.pop(context); state.loadDemoTemplate('few'); _showSuccess(context, 'Plantilla cargada'); },
            ),
            const SizedBox(height: 10),
            _TemplateOption(
              icon: Icons.filter_2,
              title: 'Cultivos medianos',
              subtitle: '4 cultivos variados con registros',
              color: AppColors.primary,
              onTap: () { Navigator.pop(context); state.loadDemoTemplate('medium'); _showSuccess(context, 'Plantilla cargada'); },
            ),
            const SizedBox(height: 10),
            _TemplateOption(
              icon: Icons.filter_3,
              title: 'Muchos cultivos',
              subtitle: '8 cultivos con múltiples actividades',
              color: AppColors.accent,
              onTap: () { Navigator.pop(context); state.loadDemoTemplate('many'); _showSuccess(context, 'Plantilla cargada'); },
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                state.clearAllData();
                _showSuccess(context, 'Datos eliminados');
              },
              icon: const Icon(Icons.delete_sweep_outlined, color: AppColors.error),
              label: const Text('Limpiar todos los datos', style: TextStyle(color: AppColors.error)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccess(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [const AppLogo(size: 40), const SizedBox(width: 10), const Text('CultivApp')]),
        content: const Text('Bitácora digital agrícola para pequeños y medianos productores.\n\nOrganiza, registra y mejora tu cultivo.\n\nVersión 1.0.0 — Proyecto académico.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))],
      ),
    );
  }

  void _confirmLogout(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cerrar sesión'),
        content: const Text('¿Deseas cerrar sesión?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              await state.logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(children: children),
    );
  }
}

class _CropSummaryCard extends StatelessWidget {
  final Crop crop;
  final AppState state;
  const _CropSummaryCard({required this.crop, required this.state});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    final total = state.totalCostForCrop(crop.id);
    final acts = state.activitiesForCrop(crop.id).length;
    final exps = state.expensesForCrop(crop.id).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: crop.status.color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(crop.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14))),
              StatusBadge(label: crop.status.label, color: crop.status.color),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _MiniStat(label: 'Actividades', value: acts.toString(), icon: Icons.assignment_outlined),
              const SizedBox(width: 16),
              _MiniStat(label: 'Gastos', value: exps.toString(), icon: Icons.receipt_outlined),
              const SizedBox(width: 16),
              _MiniStat(label: 'Invertido', value: currency.format(total), icon: Icons.monetization_on_outlined, color: AppColors.warning),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  const _MiniStat({required this.label, required this.value, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color ?? Colors.grey),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: color)),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ],
    );
  }
}

class _TemplateOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _TemplateOption({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color.withOpacity(0.1), color.withOpacity(0.04)]),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 15)),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}
