import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/inspection_model.dart';
import '../widgets/inspection_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  List<Inspection> inspections = [];
  String selectedFilter = 'All';
  late AnimationController _fabController;
  late AnimationController _listController;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    _listController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    // Sample data
    _loadSampleData();
  }

  void _loadSampleData() {
    inspections = [
      Inspection(
        id: '1',
        title: 'Building A - Foundation Check',
        location: 'Downtown, Chicago',
        description: 'Structural assessment of foundation and basement',
        date: DateTime.now(),
        status: 'Completed',
      ),
      Inspection(
        id: '2',
        title: 'Bridge Inspection',
        location: 'Harbor Route, Seattle',
        description: 'Regular maintenance and safety check',
        date: DateTime.now().subtract(const Duration(days: 2)),
        status: 'In Progress',
      ),
    ];
  }

  @override
  void dispose() {
    _fabController.dispose();
    _listController.dispose();
    super.dispose();
  }

  List<Inspection> get filteredInspections {
    if (selectedFilter == 'All') return inspections;
    return inspections.where((i) => i.status == selectedFilter).toList();
  }

  void _addInspection(Inspection inspection) {
    setState(() {
      inspections.add(inspection);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Inspection added successfully'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFED8B00),
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _deleteInspection(String id) {
    setState(() {
      inspections.removeWhere((i) => i.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Inspection deleted'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey[50]!,
              Colors.grey[100]!,
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // MODERN APP BAR
            SliverAppBar(
              expandedHeight: 140,
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFED8B00),
                        const Color(0xFFE67E22),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'Burnham Eye',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Inspection Management Dashboard',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // CONTENT
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // STATS CARDS
                  Row(
                    children: [
                      _statCard(
                        title: 'Total',
                        value: inspections.length.toString(),
                        icon: Icons.assignment_outlined,
                        color: const Color(0xFFED8B00),
                      ),
                      const SizedBox(width: 16),
                      _statCard(
                        title: 'Completed',
                        value: inspections
                            .where((i) => i.status == 'Completed')
                            .length
                            .toString(),
                        icon: Icons.check_circle_outline,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 16),
                      _statCard(
                        title: 'In Progress',
                        value: inspections
                            .where((i) => i.status == 'In Progress')
                            .length
                            .toString(),
                        icon: Icons.hourglass_bottom,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // FILTER SECTION
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filter by Status',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ['All', 'Completed', 'In Progress']
                              .map((filter) => Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() => selectedFilter = filter);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: selectedFilter == filter
                                              ? const Color(0xFFED8B00)
                                              : Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: selectedFilter == filter
                                                ? const Color(0xFFED8B00)
                                                : Colors.transparent,
                                          ),
                                        ),
                                        child: Text(
                                          filter,
                                          style: TextStyle(
                                            color: selectedFilter == filter
                                                ? Colors.white
                                                : Colors.grey[700],
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // INSPECTIONS TABLE
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Inspections',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (filteredInspections.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.assignment_outlined,
                                  size: 64,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No inspections yet',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredInspections.length,
                          itemBuilder: (context, index) {
                            final inspection = filteredInspections[index];
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(1, 0),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: _listController,
                                  curve: Interval(
                                    index * 0.1,
                                    (index * 0.1) + 0.8,
                                    curve: Curves.easeOutCubic,
                                  ),
                                ),
                              ),
                              child: _inspectionCard(inspection),
                            );
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: _fabController, curve: Curves.easeOutBack),
        ),
        child: FloatingActionButton.extended(
          onPressed: () async {
            final result = await showDialog<Inspection>(
              context: context,
              builder: (context) => const InspectionDialog(),
            );
            if (result != null) {
              _addInspection(result);
            }
          },
          backgroundColor: const Color(0xFFED8B00),
          icon: const Icon(Icons.add),
          label: const Text(
            'New Inspection',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inspectionCard(Inspection inspection) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inspection.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            inspection.location,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: inspection.status == 'Completed'
                        ? Colors.green.withOpacity(0.15)
                        : Colors.blue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    inspection.status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: inspection.status == 'Completed'
                          ? Colors.green[700]
                          : Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              inspection.description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMM dd, yyyy').format(inspection.date),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                GestureDetector(
                  onTap: () => _deleteInspection(inspection.id),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Colors.red[600],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}