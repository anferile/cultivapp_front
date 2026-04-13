import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../widgets/shared_widgets.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import 'crops_screen.dart';
import 'activities_screen.dart';
import 'expenses_screen.dart';
import 'main_screen.dart';
import 'crop_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final currency = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => await Future.delayed(const Duration(milliseconds: 300)),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Hero header
            SliverToBoxAdapter(
              child: GradientHeader(
                height: 160,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
                  child: Row(
                    children: [
                      const AppLogo(size: 52),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Hola, ${state.currentUser?.fullName.split(' ').first ?? 'Agricultor'}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Resumen de tu producción',
                              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(state.isDarkMode ? Icons.light_mode : Icons.dark_mode, color: Colors.white),
                        onPressed: state.toggleDarkMode,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Stat cards row 1
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Cultivos activos',
                          value: state.crops.length.toString(),
                          icon: Icons.grass,
                          color: AppColors.primary,
                          onTap: () => _showCropsList(context, state),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          title: 'Total invertido',
                          value: currency.format(state.totalInvested),
                          icon: Icons.monetization_on,
                          color: AppColors.warning,
                          onTap: () => _showInvestmentBreakdown(context, state),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Actividades',
                          value: state.activities.length.toString(),
                          icon: Icons.assignment,
                          color: AppColors.info,
                          onTap: () => _navigateToTab(context, 2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          title: 'Gastos',
                          value: state.expenses.length.toString(),
                          icon: Icons.receipt_long,
                          color: AppColors.error,
                          onTap: () => _navigateToTab(context, 3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Mis cultivos
                  SectionHeader(
                    title: 'Mis cultivos',
                    onViewAll: () => _navigateToTab(context, 1),
                  ),
                  const SizedBox(height: 12),
                  if (state.crops.isEmpty)
                    const EmptyState(message: 'Aún no tienes cultivos.\nToca + en Cultivos para comenzar.', icon: Icons.grass)
                  else
                    ...state.crops.take(3).map((crop) => _CropCard(crop: crop)),

                  const SizedBox(height: 28),

                  // Actividades recientes
                  SectionHeader(
                    title: 'Actividades recientes',
                    onViewAll: () => _navigateToTab(context, 2),
                  ),
                  const SizedBox(height: 12),
                  if (state.recentActivities.isEmpty)
                    const EmptyState(message: 'No hay actividades registradas aún.', icon: Icons.assignment_outlined)
                  else
                    ...state.recentActivities.map((a) => _ActivityTile(activity: a, state: state)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTab(BuildContext context, int tab) {
    final mainState = context.findAncestorStateOfType<MainScreenState>();
    mainState?.setTab(tab);
  }

  void _showCropsList(BuildContext context, AppState state) {
    if (state.crops.isEmpty) return;
    final currency = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheet(
        title: 'Mis cultivos activos',
        child: Column(
          children: state.crops.map((c) => ListTile(
            leading: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(c.status.icon, color: AppColors.primary, size: 20),
            ),
            title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(c.type),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StatusBadge(label: c.status.label, color: c.status.color),
                Text(currency.format(state.totalCostForCrop(c.id)), style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => CropDetailScreen(cropId: c.id)));
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showInvestmentBreakdown(BuildContext context, AppState state) {
    final currency = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheet(
        title: 'Desglose de inversión',
        child: Column(
          children: [
            _BreakdownRow(
              icon: Icons.assignment,
              label: 'Costos de actividades',
              value: currency.format(state.totalActivitiesCost),
              color: AppColors.info,
            ),
            _BreakdownRow(
              icon: Icons.receipt_long,
              label: 'Gastos e insumos',
              value: currency.format(state.totalExpensesCost),
              color: AppColors.warning,
            ),
            const Divider(height: 24),
            _BreakdownRow(
              icon: Icons.account_balance_wallet,
              label: 'Total invertido',
              value: currency.format(state.totalInvested),
              color: AppColors.primary,
              isBold: true,
            ),
            if (state.crops.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Por cultivo', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 8),
              ...state.crops.map((c) => _BreakdownRow(
                icon: Icons.grass,
                label: c.name,
                value: currency.format(state.totalCostForCrop(c.id)),
                color: c.status.color,
              )),
            ],
          ],
        ),
      ),
    );
  }
}

class _BottomSheet extends StatelessWidget {
  final String title;
  final Widget child;
  const _BottomSheet({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isBold;
  const _BreakdownRow({required this.icon, required this.label, required this.value, required this.color, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.w700 : FontWeight.w400))),
          Text(value, style: TextStyle(color: color, fontWeight: isBold ? FontWeight.w800 : FontWeight.w600, fontSize: isBold ? 15 : 13)),
        ],
      ),
    );
  }
}

class _CropCard extends StatelessWidget {
  final Crop crop;
  const _CropCard({required this.crop});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    final lastActivity = state.lastActivityForCrop(crop.id);
    final dateFormat = DateFormat('dd/MM/yyyy', 'es');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CropDetailScreen(cropId: crop.id))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark ? AppColors.cardGradientDark : AppColors.cardGradientLight,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: crop.status.color.withOpacity(0.25)),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.15), AppColors.primary.withOpacity(0.05)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(crop.status.icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(crop.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
                  Text(crop.location, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                  if (lastActivity != null)
                    Text(
                      'Última: ${lastActivity.type.label} • ${dateFormat.format(lastActivity.date)}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusBadge(label: crop.status.label, color: crop.status.color),
                const SizedBox(height: 6),
                const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final Activity activity;
  final AppState state;
  const _ActivityTile({required this.activity, required this.state});

  @override
  Widget build(BuildContext context) {
    final crop = state.crops.where((c) => c.id == activity.cropId).firstOrNull;
    final currency = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy', 'es');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: activity.type.color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: activity.type.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(activity.type.icon, color: activity.type.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.type.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(
                  '${crop?.name ?? ''} • ${dateFormat.format(activity.date)}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            currency.format(activity.cost),
            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
