import 'package:companyproject/viewmodel/room_viewmodel.dart';
import 'package:companyproject/widget/custom_card.dart';
import 'package:companyproject/widget/statistics_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'add_room_view.dart';
import 'view_rooms_view.dart';
import 'search_filter_view.dart';
import 'allocate_room_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Hostel Room Allocation'),
        centerTitle: true,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _buildWelcomeSection(context),
            const SizedBox(height: 32),

            // Statistics Dashboard
            Consumer<RoomViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.statistics == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistics Overview',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    StatisticsDashboard(statistics: viewModel.statistics!),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildQuickActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return CustomCard(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.dashboard,
              size: 48,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to Admin Dashboard',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage hostel rooms, allocate to students, and track occupancy efficiently',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildActionCard(
              context,
              'Add Room',
              'Create a new room entry',
              Icons.add_home_work,
              Colors.blue,
                  () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddRoomView(),
                  ),
                );
              },
              isWide ? 280.0 : null,
            ),
            _buildActionCard(
              context,
              'View All Rooms',
              'Browse all available rooms',
              Icons.meeting_room,
              Colors.green,
                  () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ViewRoomsView(),
                  ),
                );
              },
              isWide ? 280.0 : null,
            ),
            _buildActionCard(
              context,
              'Search & Filter',
              'Find rooms by criteria',
              Icons.search,
              Colors.orange,
                  () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SearchFilterView(),
                  ),
                );
              },
              isWide ? 280.0 : null,
            ),
            _buildActionCard(
              context,
              'Allocate Room',
              'Assign room to student',
              Icons.person_add,
              Colors.purple,
                  () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AllocateRoomView(),
                  ),
                );
              },
              isWide ? 280.0 : null,
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionCard(
      BuildContext context,
      String title,
      String subtitle,
      IconData icon,
      Color color,
      VoidCallback onTap,
      double? width,
      ) {
    return SizedBox(
      width: width,
      child: CustomCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.arrow_forward,
                  color: color,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}