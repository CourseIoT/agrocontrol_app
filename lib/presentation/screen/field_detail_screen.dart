import 'package:agrocontrol_app/models/activity.dart';
import 'package:agrocontrol_app/models/agricultural_process.dart';
import 'package:agrocontrol_app/models/field.dart';
import 'package:agrocontrol_app/presentation/screen/add_activity_screen.dart';
import 'package:agrocontrol_app/presentation/widgets/custom_loading_indicator.dart';
import 'package:agrocontrol_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class _ProcessData {
  final AgriculturalProcess process;
  final List<Activity> activities;
  _ProcessData(this.process, this.activities);
}

class FieldDetailScreen extends StatefulWidget {
  final Field field;

  const FieldDetailScreen({super.key, required this.field});

  @override
  State<FieldDetailScreen> createState() => _FieldDetailScreenState();
}

class _FieldDetailScreenState extends State<FieldDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<_ProcessData?> _dataFuture;
  List<Activity> _activities = [];
  String? _filterType;
  bool _sortByNewest = true;
  static const Color colorPrimary = Color(0xFF043A3A);
  static const Color colorAccent = Color(0xFF2E8B57);
  static const Color colorError = Color(0xFFD9534F);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _dataFuture = _loadProcessAndActivities();
    });
  }

  Future<_ProcessData?> _loadProcessAndActivities() async {
    await Future.delayed(const Duration(seconds: 1));
    final process = await _apiService.getUnfinishedProcessForField(widget.field.id);
    if (process == null) return null;

    final activities = await _fetchAllActivities(process.id);
    _activities = activities;
    return _ProcessData(process, activities);
  }

  List<Activity> get _visibleActivities {
    List<Activity> filteredActivities = List.from(_activities);
    if (_filterType != null && _filterType!.isNotEmpty) {
      filteredActivities = filteredActivities.where((a) => a.activityType == _filterType).toList();
    }

    filteredActivities.sort((a, b) {
      if (_sortByNewest) {
        return b.id.compareTo(a.id);
      } else {
        return a.id.compareTo(b.id);
      }
    });

    return filteredActivities;
  }

  Future<void> _startProcess() async {
    try {
      await _apiService.createAgriculturalProcess(widget.field.id);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Proceso iniciado con éxito'), backgroundColor: Colors.green));
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al iniciar el proceso'), backgroundColor: Colors.red));
    }
  }

  Future<void> _finishProcess(int processId) async {
    final confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Confirmar Finalización'),
        content: const Text('¿Estás seguro de que quieres finalizar este proceso?'),
        actions: [
          TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.black),
              onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')
          ),          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), style: FilledButton.styleFrom(backgroundColor: colorError), child: const Text('Finalizar')),
        ],
      ),
    ) ?? false;

    if (confirm) {
      try {
        await _apiService.finishAgriculturalProcess(processId);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Proceso finalizado con éxito.'), backgroundColor: colorAccent));
        _loadData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al finalizar el proceso'), backgroundColor: Colors.red));
      }
    }
  }

  void _showAddActivityDialog(int processId) async {
    final selectedActivityType = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Text(
                  'Seleccionar Actividad',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colorPrimary,
                  ),
                ),
              ),
              _buildBottomSheetOption(context, 'Riego', Icons.water_drop_outlined, 'IRRIGATION'),
              _buildBottomSheetOption(context, 'Siembra', Icons.eco_outlined, 'SEEDING'),
              _buildBottomSheetOption(context, 'Tratamiento', Icons.bug_report_outlined, 'CROP_TREATMENT'),
              _buildBottomSheetOption(context, 'Cosecha', Icons.agriculture_outlined, 'HARVEST'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );

    if (selectedActivityType != null) {
      final result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddActivityScreen(agriculturalProcessId: processId, activityType: selectedActivityType)));
      if (result == true) _loadData();
    }
  }

  Widget _buildBottomSheetOption(BuildContext context, String title, IconData icon, String apiType) {
    return ListTile(
      leading: Icon(icon, color: colorAccent, size: 28),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
      onTap: () {
        Navigator.pop(context, apiType);
      },
    );
  }
  Future<List<Activity>> _fetchAllActivities(int processId) async {
    final activityTypes = ['IRRIGATION', 'SEEDING', 'CROP_TREATMENT', 'HARVEST'];
    final futures = activityTypes.map((type) => _apiService.getActivities(processId, type)).toList();
    final results = await Future.wait(futures);
    final allActivities = results.expand((list) => list).toList();
    allActivities.sort((a, b) => b.id.compareTo(a.id));
    return allActivities;
  }

  Future<void> _executeActivityAction({required int activityId, required int agriculturalProcessId, required String action}) async {
    String actionText;
    String newStatus;
    switch (action) {
      case 'start': actionText = 'iniciar'; newStatus = 'IN_PROGRESS'; break;
      case 'finish': actionText = 'finalizar'; newStatus = 'COMPLETED'; break;
      case 'cancel': actionText = 'cancelar'; newStatus = 'CANCELLED'; break;
      default: return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Confirmar Acción'),
        content: Text('¿Estás seguro de que quieres $actionText esta actividad?'),
        actions: [
          TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.black),
              onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')
          ),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), style: FilledButton.styleFrom(backgroundColor: action == 'cancel' ? colorError : colorAccent), child: Text(actionText.toUpperCase())),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    final originalActivities = List<Activity>.from(_activities);
    final activityIndex = _activities.indexWhere((a) => a.id == activityId);
    if (activityIndex != -1) {
      setState(() => _activities[activityIndex] = _activities[activityIndex].copyWith(activityStatus: newStatus));
    }

    try {
      await _apiService.executeActivityAction(activityId: activityId, agriculturalProcessId: agriculturalProcessId, action: action);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Actividad ${actionText}da con éxito'), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al $actionText la actividad: $e'), backgroundColor: Colors.red));
      setState(() => _activities = originalActivities);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> fieldImages = [
      'assets/images/farm_background.png',
      'assets/images/field_1.png',
      'assets/images/field_2.png',
      'assets/images/field_3.png',
      'assets/images/field_4.png',
    ];
    final imagePath = fieldImages[widget.field.id % fieldImages.length];

    return Scaffold(
      appBar: AppBar(title: Text(widget.field.name), backgroundColor: colorPrimary, foregroundColor: Colors.white),
      body: RefreshIndicator(
        backgroundColor: Colors.white,
        color: const Color(0xFF2E8B57),
        strokeWidth: 3.0,
        onRefresh: () async => _loadData(),
        child: FutureBuilder<_ProcessData?>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CustomLoadingIndicator(message: 'Cargando datos del proceso...'));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final processData = snapshot.data;
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Image.asset(imagePath, height: 200, fit: BoxFit.cover),
                ),
                if (processData == null)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(padding: const EdgeInsets.all(20), child: _buildStartProcessButton()),
                  )
                else ...[
                  SliverToBoxAdapter(
                    child: Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 0), child: _buildProcessCard(processData.process)),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Actividades', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                              if (!processData.process.isFinished)
                                TextButton.icon(
                                  onPressed: () => _showAddActivityDialog(processData.process.id),
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('Agregar'),
                                  style: TextButton.styleFrom(foregroundColor: colorAccent),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    delegate: _SliverFilterBarDelegate(child: _buildFilterAndSortControls()),
                    pinned: true,
                  ),
                  if (_visibleActivities.isEmpty)
                    SliverToBoxAdapter(
                      child: Center(
                        child: Padding(padding: const EdgeInsets.symmetric(vertical: 40), child: Text('No hay actividades que coincidan', style: TextStyle(color: Colors.grey.shade600))),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) => _buildActivityItemCard(_visibleActivities[index], processData.process),
                          childCount: _visibleActivities.length,
                        ),
                      ),
                    ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStartProcessButton() {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.play_circle_outline),
        label: const Text('Iniciar Proceso'),
        onPressed: _startProcess,
        style: ElevatedButton.styleFrom(backgroundColor: colorAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
      ),
    );
  }

  Widget _buildFilterAndSortControls() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1.0)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton.icon(
            icon: Icon(_sortByNewest ? Icons.arrow_downward : Icons.arrow_upward, size: 18, color: Colors.grey.shade700),
            label: Text(
              _sortByNewest ? 'Más Recientes' : 'Más Antiguos',
              style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.normal),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              side: BorderSide(color: Colors.grey.shade400, width: 1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
            onPressed: () {
              setState(() {
                _sortByNewest = !_sortByNewest;
              });
            },
          ),

          PopupMenuButton<String?>(
            color: Colors.white,
            surfaceTintColor: Colors.white,
            onSelected: (String? result) {
              setState(() {
                _filterType = result ?? '';
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String?>>[
              PopupMenuItem<String?>(
                value: '',
                child: Row(
                  children: [
                    if (_filterType == null || _filterType!.isEmpty)
                      Icon(Icons.check, color: colorAccent, size: 20)
                    else
                      const SizedBox(width: 24),
                    const SizedBox(width: 8),
                    const Text('Todas las actividades'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              _buildFilterMenuItem('IRRIGATION', 'Riego'),
              _buildFilterMenuItem('SEEDING', 'Siembra'),
              _buildFilterMenuItem('CROP_TREATMENT', 'Tratamiento'),
              _buildFilterMenuItem('HARVEST', 'Cosecha'),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(

                  border: Border.all(color: Colors.grey.shade400, width: 1),
                  borderRadius: BorderRadius.circular(8.0),
                  color: (_filterType != null && _filterType!.isNotEmpty) ? colorAccent.withOpacity(0.1) : Colors.transparent
              ),
              child: Row(children: [
                Icon(
                    Icons.filter_list,
                    color: (_filterType != null && _filterType!.isNotEmpty) ? colorAccent : Colors.grey.shade700,
                    size: 20
                ),
                const SizedBox(width: 6),
                Text(
                    'Filtrar',
                    style: TextStyle(color: (_filterType != null && _filterType!.isNotEmpty) ? colorAccent : Colors.grey.shade700)
                )
              ]),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildFilterMenuItem(String type, String text) {
    final bool isSelected = (type == 'ALL') ? _filterType == null : _filterType == type;

    return PopupMenuItem<String>(
      value: type,
      child: Row(
        children: [
          if (isSelected)
            Icon(Icons.check, color: colorAccent)
          else
            const SizedBox(width: 24),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildProcessCard(AgriculturalProcess process) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: process.isFinished ? Colors.grey.shade200 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Proceso #${process.id}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: process.isFinished ? Colors.grey.shade700 : colorPrimary)),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.calendar_today_outlined, 'Fecha Inicio', dateFormat.format(process.startDate)),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.flag_outlined, 'Estado', process.isFinished ? 'Finalizado el ${dateFormat.format(process.endDate!)}' : 'En progreso', isBold: !process.isFinished),
            if (!process.isFinished) Padding(padding: const EdgeInsets.only(top: 16.0), child: Center(child: OutlinedButton.icon(icon: const Icon(Icons.check_circle_outline, size: 18), label: const Text('Finalizar Proceso'), onPressed: () => _finishProcess(process.id), style: OutlinedButton.styleFrom(foregroundColor: colorError, side: BorderSide(color: colorError))))),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItemCard(Activity activity, AgriculturalProcess process) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final statusText = activity.activityStatus.replaceAll('_', ' ').toLowerCase();
    final statusColor = _getStatusColor(activity.activityStatus);
    String activityTitle = activity.activityType.replaceAll('_', ' ').split(' ').map((str) => str.isEmpty ? '' : '${str[0].toUpperCase()}${str.substring(1).toLowerCase()}').join(' ');
    final String? assetPath = _getActivityAsset(activity.activityType);
    return Card(
      color: Colors.grey.shade50,
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(image: assetPath != null ? DecorationImage(image: AssetImage(assetPath), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.45), BlendMode.darken)) : null, color: assetPath == null ? colorPrimary.withOpacity(0.9) : Colors.transparent),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [Text(activityTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white, shadows: [Shadow(blurRadius: 2, color: Colors.black87)]))]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildActivityDetailRow(Icons.calendar_today_outlined, 'Fecha', dateFormat.format(activity.date)),
                    Chip(label: Text(statusText, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)), backgroundColor: statusColor, side: BorderSide.none, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  ],
                ),
                if (_buildSpecificActivityDetails(activity).isNotEmpty) ...[const Divider(height: 24, thickness: 0.5), ..._buildSpecificActivityDetails(activity)]
              ],
            ),
          ),
          if (!process.isFinished && (activity.activityStatus == 'PENDING' || activity.activityStatus == 'NOT_STARTED' || activity.activityStatus == 'IN_PROGRESS'))
            Container(
              color: Colors.grey.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: _buildActionButtons(activity, process),
            ),
        ],
      ),
    );
  }

  Widget _buildActivityDetailRow(IconData icon, String label, String value) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [Icon(icon, color: colorPrimary.withOpacity(0.7), size: 18), const SizedBox(width: 8), Text('$label:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey.shade700)), const SizedBox(width: 6), Text(value, style: const TextStyle(fontSize: 14, color: Colors.black87))]);
  }

  List<Widget> _buildSpecificActivityDetails(Activity activity) {
    final List<Widget> details = [];
    switch (activity.activityType) {
      case 'IRRIGATION':
        if (activity.hoursIrrigated != null) details.add(_buildActivityDetailRow(Icons.hourglass_bottom_outlined, 'Riego', '${activity.hoursIrrigated}h'));
        break;
      case 'SEEDING':
        if (activity.plantType != null) details.add(_buildActivityDetailRow(Icons.eco_outlined, 'Planta', activity.plantType!));
        if (activity.quantityPlanted != null) details.add(_buildActivityDetailRow(Icons.format_list_numbered_outlined, 'Cantidad', activity.quantityPlanted.toString()));
        break;
      case 'CROP_TREATMENT':
        if (activity.treatmentType != null) details.add(_buildActivityDetailRow(Icons.colorize_outlined, 'Tratamiento', activity.treatmentType!));
        break;
      case 'HARVEST':
        if (activity.quantityInKg != null) details.add(_buildActivityDetailRow(Icons.scale_outlined, 'Cosecha', '${activity.quantityInKg}kg'));
        if (activity.pricePerKg != null) details.add(_buildActivityDetailRow(Icons.attach_money_outlined, 'Precio/Kg', 'S/ ${activity.pricePerKg}'));
        if (activity.totalIncome != null) details.add(_buildActivityDetailRow(Icons.money_outlined, 'Total Ingresos', 'S/ ${activity.totalIncome}'));
        break;
    }
    if (details.isEmpty) return [];
    return [Wrap(spacing: 16.0, runSpacing: 12.0, children: details)];
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'IN_PROGRESS': return Colors.orange.shade700;
      case 'COMPLETED': return colorAccent;
      case 'CANCELLED': return colorError;
      case 'NOT_STARTED':
      case 'PENDING':
      default: return Colors.blueGrey;
    }
  }

  Widget _buildActionButtons(Activity activity, AgriculturalProcess process) {
    switch (activity.activityStatus) {
      case 'NOT_STARTED':
      case 'PENDING':
        return Row(mainAxisAlignment: MainAxisAlignment.end, children: [ElevatedButton.icon(onPressed: () => _executeActivityAction(activityId: activity.id, agriculturalProcessId: process.id, action: 'start'), icon: const Icon(Icons.play_arrow, size: 20), label: const Text('Iniciar'), style: ElevatedButton.styleFrom(backgroundColor: colorAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))]);
      case 'IN_PROGRESS':
        return Row(mainAxisAlignment: MainAxisAlignment.end, children: [OutlinedButton.icon(onPressed: () => _executeActivityAction(activityId: activity.id, agriculturalProcessId: process.id, action: 'cancel'), icon: const Icon(Icons.cancel_outlined, size: 20), label: const Text('Cancelar'), style: OutlinedButton.styleFrom(foregroundColor: colorError, side: BorderSide(color: colorError))), const SizedBox(width: 8), ElevatedButton.icon(onPressed: () => _executeActivityAction(activityId: activity.id, agriculturalProcessId: process.id, action: 'finish'), icon: const Icon(Icons.check_circle_outline, size: 20), label: const Text('Finalizar'), style: ElevatedButton.styleFrom(backgroundColor: colorAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))]);
      default: return const SizedBox.shrink();
    }
  }

  String? _getActivityAsset(String apiType) {
    switch (apiType) {
      case 'IRRIGATION': return 'assets/images/irrigation.png';
      case 'SEEDING': return 'assets/images/seeding.png';
      case 'CROP_TREATMENT': return 'assets/images/treatment.png';
      case 'HARVEST': return 'assets/images/harvest.png';
      default: return null;
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isBold = false}) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: Colors.grey.shade600, size: 18), const SizedBox(width: 10), Text('$label:', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54, fontSize: 14)), const Spacer(), Text(value, style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal), textAlign: TextAlign.right)]);
  }
}

class _SliverFilterBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverFilterBarDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: child,
    );
  }

  @override
  double get maxExtent => 60.0;

  @override
  double get minExtent => 60.0;

  @override
  bool shouldRebuild(covariant _SliverFilterBarDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}
