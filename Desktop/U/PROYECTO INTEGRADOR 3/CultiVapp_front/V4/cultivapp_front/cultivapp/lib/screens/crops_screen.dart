import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';
import '../theme/app_theme.dart';
import 'crop_detail_screen.dart';
import 'add_crop_screen.dart';
import 'harvested_crops_screen.dart';

class CropsScreen extends StatefulWidget {
  const CropsScreen({super.key});

  @override
  State<CropsScreen> createState() => _CropsScreenState();
}

class _CropsScreenState extends State<CropsScreen> with SingleTickerProviderStateMixin {
  CropStatus? _filterStatus;
  String _searchQuery = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    var crops = state.crops.toList();
    if (_filterStatus != null) crops = crops.where((c) => c.status == _filterStatus).toList();
    if (_searchQuery.isNotEmpty) {
      crops = crops.where((c) =>
        c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        c.type.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        c.location.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverToBoxAdapter(
            child: GradientHeader(
              height: 120,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
                child: Row(
                  children: [
                    const Icon(Icons.grass, color: Colors.white, size: 26),
                    const SizedBox(width: 10),
                    const Text('Mis Cultivos', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(12)),
                      child: Text('${state.crops.length} activos', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primary,
              tabs: [
                Tab(text: 'Activos (${state.crops.length})'),
                Tab(text: 'Cosechados (${state.archivedCrops.length})'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            // Active crops tab
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar cultivos...',
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: isDark ? Colors.green.shade900 : Colors.green.shade100),
                      ),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _FilterChip(label: 'Todos', selected: _filterStatus == null, onTap: () => setState(() => _filterStatus = null)),
                      const SizedBox(width: 8),
                      ...[CropStatus.active, CropStatus.growing].map((s) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _FilterChip(label: s.label, selected: _filterStatus == s, color: s.color, onTap: () => setState(() => _filterStatus = _filterStatus == s ? null : s)),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: crops.isEmpty
                      ? EmptyState(
                          message: 'No hay cultivos activos.\nToca + para agregar uno.',
                          icon: Icons.grass,
                          actionLabel: 'Agregar cultivo',
                          onAction: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddCropScreen())),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: crops.length,
                          itemBuilder: (_, i) => _CropListItem(crop: crops[i]),
                        ),
                ),
              ],
            ),
            // Archived/harvested tab
            HarvestedCropsScreen(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddCropScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo cultivo'),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient: selected ? LinearGradient(colors: [c, c.withOpacity(0.8)]) : null,
          color: selected ? null : c.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.withOpacity(0.4)),
          boxShadow: selected ? [BoxShadow(color: c.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))] : null,
        ),
        child: Text(label, style: TextStyle(color: selected ? Colors.white : c, fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }
}

class _CropListItem extends StatelessWidget {
  final Crop crop;
  const _CropListItem({required this.crop});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    final currency = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy', 'es');
    final totalCost = state.totalCostForCrop(crop.id);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CropDetailScreen(cropId: crop.id))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark ? AppColors.cardGradientDark : AppColors.cardGradientLight,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: crop.status.color.withOpacity(0.25)),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.07), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.18), AppColors.primary.withOpacity(0.06)]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(crop.status.icon, color: AppColors.primary, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(crop.name, style: Theme.of(context).textTheme.titleMedium),
                      Text(crop.type, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
                StatusBadge(label: crop.status.label, color: crop.status.color),
              ],
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: crop.status.color.withOpacity(0.2)),
            const SizedBox(height: 10),
            Row(
              children: [
                _InfoItem(icon: Icons.location_on_outlined, text: crop.location),
                const SizedBox(width: 16),
                _InfoItem(icon: Icons.calendar_today_outlined, text: dateFormat.format(crop.sowingDate)),
              ],
            ),
            const SizedBox(height: 4),
            _InfoItem(icon: Icons.monetization_on_outlined, text: 'Invertido: ${currency.format(totalCost)}', color: AppColors.warning),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  const _InfoItem({required this.icon, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.grey;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: c),
        const SizedBox(width: 4),
        Flexible(child: Text(text, style: TextStyle(fontSize: 12, color: c), overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
