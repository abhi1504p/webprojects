import 'package:flutter/material.dart';
import 'custom_card.dart';

class StatisticsDashboard extends StatelessWidget {
  final Map<String, dynamic> statistics;

  const StatisticsDashboard({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildStatCard(
              context,
              'Total Rooms',
              statistics['totalRooms'].toString(),
              Icons.meeting_room,
              Colors.blue,
              isWide,
            ),
            _buildStatCard(
              context,
              'Available',
              statistics['availableRooms'].toString(),
              Icons.check_circle_outline,
              Colors.green,
              isWide,
            ),
            _buildStatCard(
              context,
              'Occupied',
              statistics['allocatedRooms'].toString(),
              Icons.person,
              Colors.orange,
              isWide,
            ),
            _buildStatCard(
              context,
              'Occupancy Rate',
              '${statistics['occupancyRate']}%',
              Icons.pie_chart,
              Colors.purple,
              isWide,
            ),
            _buildStatCard(
              context,
              'AC Rooms',
              statistics['acRooms'].toString(),
              Icons.ac_unit,
              Colors.cyan,
              isWide,
            ),
            _buildStatCard(
              context,
              'Total Capacity',
              statistics['totalCapacity'].toString(),
              Icons.people,
              Colors.indigo,
              isWide,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
      BuildContext context,
      String label,
      String value,
      IconData icon,
      Color color,
      bool isWide,
      ) {
    final width = isWide ? 180.0 : 160.0;

    return SizedBox(
      width: width,
      child: CustomCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}